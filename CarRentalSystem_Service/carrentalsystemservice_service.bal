import ballerina/grpc;
import ballerina/log;
import ballerina/time;

// Data Structures
public type Car record {
    string plate;
    string make;
    string model;
    int year;
    decimal dailyPrice;
    int mileage;
    CarStatus availability;
};

public type User record {
    string userID;
    string name;
    string email;
    UserRole role;
};

public type Reservation record{
    string reservationID;
    string customerID;
    string plate;
    string start_date;
    string end_date;
    decimal total_price;
    string status;
};

public enum CarStatus {
    CAR_AVAILABLE,
    CAR_UNAVAILABLE
}

public enum UserRole {
    USER_CUSTOMER,
    USER_ADMIN
}

map<Car> cars = {};
map<User> users = {};
map<string[]> customer_carts = {}; // customer_id -> car plates
map<Reservation> reservations = {};
int reservation_counter = 1000;

// Functions 
function generateReservationId() returns string {
    reservation_counter += 1;
    return string `RES${reservation_counter}`;
}

function calculatePrice(string plate, string startDate, string endDate) returns float {
    if !cars.hasKey(plate) {
        return 0.0;
    }
    Car car = cars.get(plate);
    // Simplified: assume 5 days rental
    return car.dailyPrice * 5.00;
}



listener grpc:Listener ep = new (9090);

# Description.
@grpc:Descriptor {value: CARRENTALSYSTEM_DESC}
service "CarRentalSystemService" on ep {

    remote function AddCar(Car car) returns AddCarResponse|error {
        log:printInfo("Adding car: " + car.plate);
        
        if cars.hasKey(car.plate) {
            return {
                plate: car.plate,
                message: "Car already exists",
                success: false
            };

        }cars[car.plate] = car;
        
        return {
            plate: car.plate,
            message: "Car added successfully",
            success: true
        };
    }
    remote function CreateUsers(CreateUsersRequest request) returns CreateUsersResponse|error {
         log:printInfo("Creating multiple users...");
        
        int count = 0;
        int errors = 0;
        
        foreach User user in request.users {
            // Basic validation
            if user.userID.trim() == "" {
                errors += 1;
                continue;
            }
            
            if users.hasKey(user.userID) {
                errors += 1;
                log:printInfo("User already exists: " + user.userID);
                continue;
            }
            
            // Add user
            users[user.userID] = user;
            count += 1;
            log:printInfo(string `Created user: ${user.name} (${user.role})`);
        }
        
        string message = string `Successfully created ${count} users`;
        if errors > 0 {
            message = string `${message}. ${errors} users failed (duplicates or invalid data)`;
        }
        
        return {
            message: message,
            success: count > 0,
            usersCreated: count
        };

    }

    remote function UpdateCar(UpdateCarRequest request) returns UpdateCarResponse|error {
        log:printInfo("Updating car: " + request.plate);
        
        if !cars.hasKey(request.plate) {
            return {
                message:"Car not found",
                success:false
            };
        }
        
        cars[request.plate] = request.updatedCar;
        
        return {
            message:"Car updated successfully",
            success:true
        };

    }

    remote function RemoveCar(RemoveCarRequest request) returns RemoveCarResponse|error {
        log:printInfo("Removing car: " + request.plate);
        
        if !cars.hasKey(request.plate) {
            return {
                message:"Car not found",
                success:false
            };
        }
        
        Car removedCar = cars.remove(request.plate);
        return {
            message:"Car removed successfully",
            success:true
        };
    }

    remote function SearchCar(SearchCarRequest request) returns SearchCarResponse|error {
         log:printInfo("Searching for car: " + request.plate);

         if !cars.hasKey(request.plate) {
            return {
                car : {
                    plate: "",
                    make: "",
                    model: "",
                    year: 0,
                    dailyPrice: 0.0,
                    mileage: 0,
                    availability:CAR_UNAVAILABLE
                },
                available: false,
                message: "Car not found"
            };
        {
            Car car = cars.get(request.plate);
            return {
                car: car,
                available: car.availability == CAR_AVAILABLE? true : false,
                message: "Car found"
            };
        } 
    }
    }
    remote function AddToCart(AddToCartRequest request) returns AddToCartResponse|error {
         log:printInfo("Adding to cart for customer: " + request.customerID);
        
        if !cars.hasKey(request.plate) {
            return {
                message: "Car not found",
                success: false
            };
        }
        
        Car car = cars.get(request.plate);
        if car.availability != CAR_AVAILABLE {
            return {
                message: "Car is not available",
                success: false
            };
        }
        if !customer_carts.hasKey(request.customerID) {
            customer_carts[request.customerID] = [];
        }
        customer_carts.get(request.customerID).push(request.plate);

        return {
            message: "Car added to cart successfully",
            success: true
        };

    }

    remote function PlaceReservation(PlaceReservationRequest request) returns PlaceReservationResponse|error {
    }

    remote function ListAvailableCars(ListAvailableCarsRequest filter) returns stream<Car, error?>|error {
        string textFilter = filter.filter;
        log:printInfo("Listing available cars with filter: " + textFilter);
        
        
        Car[] availableCars = [];
        foreach Car car in cars {
            if car.availability == CAR_AVAILABLE {
                if textFilter == "" || 
                   car.make.toLowerAscii().includes(textFilter.toLowerAscii()) ||
                   car.model.toLowerAscii().includes(textFilter.toLowerAscii()) ||
                   car.year.toString().includes(textFilter) {
                    availableCars.push(car);
                }
            }
        }
        
        return availableCars.toStream();
    }
}


