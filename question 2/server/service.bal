import ballerina/grpc;
import ballerina/log;
import ballerina/uuid;
import ballerina/time;
// (no additional imports)

// Data structures
map<Car> carInventory = {};
map<User> users = {};
map<CartItem[]> userCarts = {}; // customer_id -> cart items
Reservation[] reservations = [];

// Car service implementation
@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on new grpc:Listener(9090) {

    // Add car (Admin only)
    remote function AddCar(AddCarRequest request) returns AddCarResponse|error {
        Car car = request.car;
        
        if carInventory.hasKey(car.plate) {
            return {
                plate: car.plate,
                message: "Car with this plate already exists"
            };
        }
        
        carInventory[car.plate] = car;
        log:printInfo("Car added: " + car.plate);
        
        return {
            plate: car.plate,
            message: "Car successfully added"
        };
    }

    // Update car (Admin only)
    remote function UpdateCar(UpdateCarRequest request) returns UpdateCarResponse|error {
        string plate = request.plate;
        
        if !carInventory.hasKey(plate) {
            Car emptyCar = {plate: "", make: "", model: "", year: 0, daily_price: 0.0, mileage: 0, status: UNAVAILABLE};
            return {success: false, message: "Car not found", car: emptyCar};
        }
        
        Car updatedCar = request.updated_car;
        carInventory[plate] = updatedCar;
        
        return {
            success: true,
            message: "Car updated successfully",
            car: updatedCar
        };
    }

    // Remove car (Admin only)
    remote function RemoveCar(RemoveCarRequest request) returns RemoveCarResponse|error {
        string plate = request.plate;
        
        if !carInventory.hasKey(plate) {
            return {
                success: false,
                message: "Car not found",
                remaining_cars: carInventory.toArray()
            };
        }
        
        _ = carInventory.remove(plate);
        
        return {
            success: true,
            message: "Car removed successfully",
            remaining_cars: carInventory.toArray()
        };
    }

    // Create users (streaming)
    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        int userCount = 0;
        
        check clientStream.forEach(function(User user) {
            users[user.user_id] = user;
            userCarts[user.user_id] = []; // Initialize empty cart
            userCount += 1;
            log:printInfo("User created: " + user.user_id);
        });
        
        return {
            users_created: userCount,
            message: string `${userCount} users created successfully`
        };
    }

    // List available cars (streaming response)
    remote function ListAvailableCars(ListAvailableCarsRequest request) returns stream<Car, error?>|error {
        Car[] availableCars = [];
        string filter = request.filter.toLowerAscii();
        
        foreach Car car in carInventory {
            if car.status == AVAILABLE {
                if filter == "" || 
                   car.make.toLowerAscii().includes(filter) || 
                   car.model.toLowerAscii().includes(filter) || 
                   car.year.toString().includes(filter) {
                    availableCars.push(car);
                }
            }
        }
        
        return availableCars.toStream();
    }

    // Search for specific car
    remote function SearchCar(SearchCarRequest request) returns SearchCarResponse|error {
        string plate = request.plate;
        
        if !carInventory.hasKey(plate) {
            Car emptyCar = {plate: "", make: "", model: "", year: 0, daily_price: 0.0, mileage: 0, status: UNAVAILABLE};
            return {available: false, car: emptyCar, message: "Car not found"};
        }
        
        Car car = <Car>carInventory[plate];
        
        if car.status != AVAILABLE {
            return {
                available: false,
                car: car,
                message: "Car is not available"
            };
        }
        
        return {
            available: true,
            car: car,
            message: "Car is available"
        };
    }

    // Add car to customer cart
    remote function AddToCart(AddToCartRequest request) returns AddToCartResponse|error {
        string customerId = request.customer_id;
        string plate = request.plate;
        string startDate = request.start_date;
        string endDate = request.end_date;
        
        // Validate customer exists
        if !users.hasKey(customerId) {
            return {
                success: false,
                message: "Customer not found"
            };
        }
        
        // Validate car exists and is available
        if !carInventory.hasKey(plate) {
            return {
                success: false,
                message: "Car not found"
            };
        }
        
        Car car = <Car>carInventory[plate];
        if car.status != AVAILABLE {
            return {
                success: false,
                message: "Car is not available"
            };
        }
        
        // Basic lexical validation (YYYY-MM-DD). Detailed date validation is done later
        if startDate.length() != 10 || endDate.length() != 10 || startDate >= endDate {
            return {success: false, message: "Invalid or out-of-order dates"};
        }
        
        // Add to cart
        CartItem cartItem = {
            plate: plate,
            start_date: startDate,
            end_date: endDate
        };
        
        CartItem[] currentCart = userCarts[customerId] ?: [];
        currentCart.push(cartItem);
        userCarts[customerId] = currentCart;
        
        return {
            success: true,
            message: "Car added to cart successfully"
        };
    }

    // Place reservation
    remote function PlaceReservation(PlaceReservationRequest request) returns PlaceReservationResponse|error {
        string customerId = request.customer_id;
        
        // Check if customer exists
        if !users.hasKey(customerId) {
            return {
                success: false,
                message: "Customer not found",
                reservations: [],
                total_cost: 0.0
            };
        }
        
        CartItem[] cart = userCarts[customerId] ?: [];
        
        if cart.length() == 0 {
            return {
                success: false,
                message: "Cart is empty",
                reservations: [],
                total_cost: 0.0
            };
        }
        
        Reservation[] newReservations = [];
        float totalCost = 0.0;
        
        // Process each cart item
        foreach CartItem item in cart {
            if !carInventory.hasKey(item.plate) {
                continue; // Skip if car no longer exists
            }
            
            Car car = <Car>carInventory[item.plate];
            if car.status != AVAILABLE {
                continue; // Skip if car is no longer available
            }
            
            // Check for date conflicts with existing reservations
            boolean hasConflict = false;
            foreach Reservation existingReservation in reservations {
                if existingReservation.plate == item.plate && 
                   datesOverlap(item.start_date, item.end_date, 
                               existingReservation.start_date, existingReservation.end_date) {
                    hasConflict = true;
                    break;
                }
            }
            
            if hasConflict {
                continue; // Skip if there's a date conflict
            }
            
            // Calculate rental cost (naive: assume 1 day minimum)
            float cost = car.daily_price;
            
            // Create reservation
            string reservationId = uuid:createType1AsString();
            Reservation reservation = {
                reservation_id: reservationId,
                customer_id: customerId,
                plate: item.plate,
                start_date: item.start_date,
                end_date: item.end_date,
                total_price: cost,
                status: "CONFIRMED",
                created_date: time:utcToString(time:utcNow())
            };
            
            reservations.push(reservation);
            newReservations.push(reservation);
            totalCost += cost;
            
            // Mark car as rented for the period
            car.status = RENTED;
            carInventory[item.plate] = car;
        }
        
        // Clear the cart
        userCarts[customerId] = [];
        
        return {
            success: true,
            message: string `${newReservations.length()} reservations created successfully`,
            reservations: newReservations,
            total_cost: totalCost
        };
    }

    // List all reservations (Admin only)
    remote function ListReservations() returns stream<Reservation, error?>|error {
        return reservations.toStream();
    }
}

// Helper function to check date overlap (lexical compare for simplicity)
function datesOverlap(string start1, string end1, string start2, string end2) returns boolean {
    return !(end1 < start2 || end2 < start1);
}