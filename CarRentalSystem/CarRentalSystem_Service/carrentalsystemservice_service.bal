import ballerina/grpc;
import ballerina/log;

// Data Structures

map<RentalCar> carDatabase = {};
map<RentalUser> userDatabase = {};
map<string[]> customerCarts = {};
map<CarReservation> reservationDatabase = {};
int reservationCounter = 1000;

// Helper functions
function generateReservationId() returns string {
    lock {
        reservationCounter += 1;
        return string `RES${reservationCounter}`;
    }
}

function calculateRentalPrice(string plate, string startDate, string endDate) returns float {
    lock {
        if !carDatabase.hasKey(plate) {
            return 0.0;
        }
        RentalCar targetCar = carDatabase.get(plate);
        return targetCar.dailyPrice * 5.0;
    }
}

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CARRENTALSYSTEM_DESC}
service "CarRentalSystemService" on ep {
//Add a new car
    remote function AddCar(AddCarRequest request) returns AddCarResponse {
        log:printInfo("AddCar request for plate: " + request.car.plate);
        
        RentalCar newCar = request.car;
        
        //Check if car already exists
        lock {
            if carDatabase.hasKey(newCar.plate) {
                return {
                    plate: newCar.plate,
                    message: "Car with this plate already exists",
                    success: false
                };
            }
        }
        
        //Basic validation
        if newCar.make.trim() == "" || newCar.model.trim() == "" {
            return {
                plate: newCar.plate,
                message: "Car make and model cannot be empty",
                success: false
            };
        }
        
        if newCar.year < 1990 || newCar.year > 2025 {
            return {
                plate: newCar.plate,
                message: "Invalid year. Must be between 1990 and 2025",
                success: false
            };
        }
        
        if newCar.dailyPrice <= 0.0 {
            return {
                plate: newCar.plate,
                message: "Daily price must be greater than 0",
                success: false
            };
        }
        
        //Add the car
        lock {
            carDatabase[newCar.plate] = newCar;
        }
        
        log:printInfo(string `Successfully added: ${newCar.make} ${newCar.model} (${newCar.plate})`);
        
        return {
            plate: newCar.plate,
            message: string `${newCar.make} ${newCar.model} added successfully`,
            success: true
        };
    }

    //Create multiple users (Admin operation)
    remote function CreateUsers(CreateUsersRequest request) returns CreateUsersResponse {
        log:printInfo("CreateUsers request for " + request.users.length().toString() + " users");
        
        int successCount = 0;
        int errorCount = 0;
        
        foreach RentalUser newUser in request.users {
            // Validation
            if newUser.userID.trim() == "" {
                errorCount += 1;
                log:printError("Empty user ID provided");
                continue;
            }
            
            if newUser.name.trim() == "" {
                errorCount += 1;
                log:printError("Empty name for user: " + newUser.userID);
                continue;
            }
            
            if newUser.email.trim() == "" {
                errorCount += 1;
                log:printError("Empty email for user: " + newUser.userID);
                continue;
            }
            
            //Check for duplicates
            lock {
                if userDatabase.hasKey(newUser.userID) {
                    errorCount += 1;
                    log:printError("User already exists: " + newUser.userID);
                    continue;
                }
                
                // Add user to database
                userDatabase[newUser.userID] = newUser;
                successCount += 1;
            }
            
            string userRole = newUser.role == CUSTOMER ? "Customer" : "Admin";
            log:printInfo(string `Created user: ${newUser.name} (${userRole})`);
        }
        
        string resultMessage = string `Successfully created ${successCount} users`;
        if errorCount > 0 {
            resultMessage = string `${resultMessage}. ${errorCount} users failed validation`;
        }
        
        return {
            message: resultMessage,
            success: successCount > 0,
            usersCreated: successCount
        };
    }

    // Update car details (Admin operation)
    remote function UpdateCar(UpdateCarRequest request) returns UpdateCarResponse {
        log:printInfo("UpdateCar request for plate: " + request.plate);
        
        lock {
            if !carDatabase.hasKey(request.plate) {
                return {
                    message: "Car not found",
                    success: false
                };
            }
        }
        
        RentalCar updatedCarData = request.updatedCar;
        
        // Validate updated car data
        if updatedCarData.dailyPrice <= 0.0 {
            return {
                message: "Daily price must be greater than 0",
                success: false
            };
        }
        
        if updatedCarData.mileage < 0 {
            return {
                message: "Mileage cannot be negative",
                success: false
            };
        }
        
        // Update the car
        lock {
            carDatabase[request.plate] = updatedCarData;
        }
        
        log:printInfo(string `Successfully updated car: ${updatedCarData.plate}`);
        
        return {
            message: "Car updated successfully",
            success: true
        };
    }

    // Remove a car (Admin operation)
    remote function RemoveCar(RemoveCarRequest request) returns RemoveCarResponse {
        log:printInfo("RemoveCar request for plate: " + request.plate);
        
        lock {
            if !carDatabase.hasKey(request.plate) {
                return {
                    remaining_cars: carDatabase.toArray(),
                    message: "Car not found",
                    success: false
                };
            }
        }
        
        // Check for active reservations
        boolean hasActiveBookings = false;
        lock {
            foreach CarReservation booking in reservationDatabase {
                if booking.plate == request.plate && booking.status == "CONFIRMED" {
                    hasActiveBookings = true;
                    break;
                }
            }
        }
        
        if hasActiveBookings {
            lock {
                return {
                    remaining_cars: carDatabase.toArray(),
                    message: "Cannot remove car with active reservations",
                    success: false
                };
            }
        }
        
        // Remove the car
        RentalCar removedCar;
        lock {
            removedCar = carDatabase.remove(request.plate);
        }
        
        log:printInfo(string `Successfully removed: ${removedCar.make} ${removedCar.model}`);
        
        lock {
            return {
                remaining_cars: carDatabase.toArray(),
                message: string `${removedCar.make} ${removedCar.model} removed successfully`,
                success: true
            };
        }
    }

    // List available cars (Customer operation - streaming response)
    remote function ListAvailableCars(ListAvailableCarsRequest request) returns stream<RentalCar, error?> {
        log:printInfo("ListAvailableCars request with filter: " + request.filter);
        
        RentalCar[] availableCarsList = [];
        string filterText = request.filter.toLowerAscii();
        
        lock {
            foreach RentalCar currentCar in carDatabase {
                if currentCar.availability == CAR_AVAILABLE {
                    boolean matchesFilter = true;
                    
                    if request.filter != "" {
                        matchesFilter = currentCar.make.toLowerAscii().includes(filterText) ||
                                      currentCar.model.toLowerAscii().includes(filterText) ||
                                      currentCar.year.toString().includes(request.filter) ||
                                      currentCar.plate.toLowerAscii().includes(filterText);
                    }
                    
                    if matchesFilter {
                        availableCarsList.push(currentCar);
                    }
                }
            }
        }
        
        log:printInfo(string `Returning ${availableCarsList.length()} available cars`);
        return availableCarsList.toStream();
    }

    // Search for a specific car (Customer operation)
    remote function SearchCar(SearchCarRequest request) returns SearchCarResponse {
        log:printInfo("SearchCar request for plate: " + request.plate);
        
        lock {
            if !carDatabase.hasKey(request.plate) {
                // Create empty car for "not found" response
                RentalCar emptyCar = {
                    plate: "",
                    make: "",
                    model: "",
                    year: 0,
                    dailyPrice: 0.0,
                    mileage: 0,
                    availability: CAR_UNAVAILABLE
                };
                
                return {
                    car: emptyCar,
                    available: false,
                    message: "Car not found"
                };
            }
            
            RentalCar foundCar = carDatabase.get(request.plate);
            boolean isAvailable = foundCar.availability == CAR_AVAILABLE;
            
            string statusMsg = isAvailable ? "Car is available for rental" : 
                              "Car is currently unavailable";
            
            return {
                car: foundCar,
                available: isAvailable,
                message: statusMsg
            };
        }
    }

    // Add car to customer's cart (Customer operation)
    remote function AddToCart(AddToCartRequest request) returns AddToCartResponse {
        log:printInfo(string `AddToCart request - Customer: ${request.customerID}, Car: ${request.plate}`);
        
        // Validate customer exists
        lock {
            if !userDatabase.hasKey(request.customerID) {
                return {
                    message: "Customer not found",
                    success: false
                };
            }
            
            RentalUser customer = userDatabase.get(request.customerID);
            if customer.role != CUSTOMER {
                return {
                    message: "Only customers can add items to cart",
                    success: false
                };
            }
        }
        
        // Validate car exists and is available
        lock {
            if !carDatabase.hasKey(request.plate) {
                return {
                    message: "Car not found",
                    success: false
                };
            }
            
            RentalCar targetCar = carDatabase.get(request.plate);
            if targetCar.availability != CAR_AVAILABLE {
                return {
                    message: "Car is currently unavailable",
                    success: false
                };
            }
        }
        
        // Basic date validation
        if request.startDate.trim() == "" || request.endDate.trim() == "" {
            return {
                message: "Start date and end date are required",
                success: false
            };
        }
        
        // Add to cart
        lock {
            if !customerCarts.hasKey(request.customerID) {
                customerCarts[request.customerID] = [];
            }
            customerCarts.get(request.customerID).push(request.plate);
        }
        
        string carInfo;
        lock {
            RentalCar cartCar = carDatabase.get(request.plate);
            carInfo = string `${cartCar.make} ${cartCar.model}`;
        }
        
        log:printInfo(string `Added ${carInfo} to cart for customer ${request.customerID}`);
        
        return {
            message: string `${carInfo} added to cart successfully`,
            success: true
        };
    }

    // Place reservation from cart (Customer operation)
    remote function PlaceReservation(PlaceReservationRequest request) returns PlaceReservationResponse {
        log:printInfo("PlaceReservation request for customer: " + request.customerID);
        
        // Validate customer
        lock {
            if !userDatabase.hasKey(request.customerID) {
                CarReservation emptyRes = createFailedReservation(request.customerID);
                return {
                    reservation: emptyRes,
                    message: "Customer not found",
                    success: false
                };
            }
            
            RentalUser customer = userDatabase.get(request.customerID);
            if customer.role != CUSTOMER {
                CarReservation emptyRes = createFailedReservation(request.customerID);
                return {
                    reservation: emptyRes,
                    message: "Only customers can place reservations",
                    success: false
                };
            }
        }

   // List all cars (admin funtion)
     remote function ListAllCars() returns RentalCar[] {
    RentalCar[] allCars = [];
    lock {
        foreach RentalCar car in carDatabase {
            allCars.push(car);
        }
    }
    log:printInfo(string `Admin requested all cars: ${allCars.length()} cars`);
    return allCars;
            }

         // List all reservations (admin funtion)
remote function ListReservations() returns CarReservation[] {
    CarReservation[] allReservations = [];
    lock {
        foreach CarReservation res in reservationDatabase {
            allReservations.push(res);
        }
    }
    log:printInfo(string `Admin requested all reservations: ${allReservations.length()} bookings`);
    return allReservations;
         }

        // Cancel a reservation (admin function)
      remote function CancelReservation(string reservationId) returns string {
    lock {
        if !reservationDatabase.hasKey(reservationId) {
            return "Reservation not found!";
        }
        CarReservation res = reservationDatabase.get(reservationId);
        if res.status != "CONFIRMED") {
            return "Reservation is not active!";
        }
        
        // Set reservation as canceled
        res.status = "CANCELED";
        reservationDatabase[reservationId] = res;
        
        // Make car available again
        if carDatabase.hasKey(res.plate) {
            RentalCar car = carDatabase.get(res.plate);
            car.availability = CAR_AVAILABLE;
            carDatabase[res.plate] = car;
        }
        
        log:printInfo(string `Reservation ${reservationId} canceled by admin`);
        return string `Reservation ${reservationId} canceled successfully.`;
    }
  }
 
         // List all users (admin function))
    remote function ListUsers() returns RentalUser[] {
     RentalUser[] allUsers = [];
     lock {
        foreach RentalUser user in userDatabase {
            allUsers.push(user);
         }
     }
     log:printInfo(string `Admin requested all users: ${allUsers.length()} users`);
      return allUsers;
                 }

        // View my reservations (customer function)
 remote function ViewMyReservations(string customerId) returns CarReservation[] {
    CarReservation[] myReservations = [];
    lock {
        foreach CarReservation res in reservationDatabase {
            if res.customerID == customerId {
                myReservations.push(res);
             }
         }
     }
    log:printInfo(string `Customer ${customerId} requested their reservations: ${myReservations.length()} bookings`);
    return myReservations;
     }     
        
        // Check cart
        lock {
            if !customerCarts.hasKey(request.customerID) || customerCarts.get(request.customerID).length() == 0 {
                CarReservation emptyRes = createFailedReservation(request.customerID);
                return {
                    reservation: emptyRes,
                    message: "Cart is empty",
                    success: false
                };
            }
        }
        
        string[] cartItems;
        lock {
            cartItems = customerCarts.get(request.customerID);
        }
        string firstCarPlate = cartItems[0]; // Process first item
        
        // Re-validate car availability
        lock {
            if !carDatabase.hasKey(firstCarPlate) {
                CarReservation emptyRes = createFailedReservation(request.customerID);
                return {
                    reservation: emptyRes,
                    message: "Car no longer exists",
                    success: false
                };
            }
            
            RentalCar reservationCar = carDatabase.get(firstCarPlate);
            if reservationCar.availability != CAR_AVAILABLE {
                CarReservation emptyRes = createFailedReservation(request.customerID);
                return {
                    reservation: emptyRes,
                    message: "Car is no longer available",
                    success: false
                };
            }
        }
        
        // Create reservation
        string newReservationId = generateReservationId();
        string bookingStartDate = "2025-11-01";
        string bookingEndDate = "2025-11-05";
        float bookingTotalPrice = calculateRentalPrice(firstCarPlate, bookingStartDate, bookingEndDate);
        
        CarReservation newReservation = {
            reservationID: newReservationId,
            customerID: request.customerID,
            plate: firstCarPlate,
            start_date: bookingStartDate,
            end_date: bookingEndDate,
            total_price: bookingTotalPrice,
            status: "CONFIRMED"
        };
        
        // Update database
        lock {
            reservationDatabase[newReservationId] = newReservation;
            
            // Update car status
            RentalCar bookedCar = carDatabase.get(firstCarPlate);
            bookedCar.availability = CAR_UNAVAILABLE;
            carDatabase[firstCarPlate] = bookedCar;
            
            // Clear customer cart
            customerCarts[request.customerID] = [];
        }
        
        string customerName;
        lock {
            RentalUser customer = userDatabase.get(request.customerID);
            customerName = customer.name;
        }
        
        log:printInfo(string `Reservation ${newReservationId} confirmed for ${customerName}`);
        
        return {
            reservation: newReservation,
            message: string `Reservation confirmed! ID: ${newReservationId}`,
            success: true
        };
    }
}

// Helper function to create failed reservation
function createFailedReservation(string customerId) returns CarReservation {
    return {
        reservationID: "",
        customerID: customerId,
        plate: "",
        start_date: "",
        end_date: "",
        total_price: 0.0,
        status: "FAILED"
    };
}
public function main() {
    log:printInfo("Car Rental System Server Starting...");
}