
import ballerina/grpc;
import ballerina/io;
CarRentalSystemServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    io:println("Welcome to Car Rental System!");
    
    // Quick setup option
    string setupChoice = io:readln("Do you want to run initial setup? (y/n): ");
    if setupChoice.trim().toLowerAscii() == "y" {
        check initialSetup();
    }
    
    // Main interactive loop
    check interactiveSession();
}

function initialSetup() returns error? {
    io:println("Setting up initial data...");
    
    //Create admin user
    RentalUser admin = {
        userID: "ADMIN",
        name: "System Admin",
        email: "admin@rental.com",
        role: ADMIN
    };
    
    //Create customer user  
    RentalUser customer = {
        userID: "CUSTOMER1", 
        name: "John Customer",
        email: "customer@email.com",
        role: CUSTOMER
    };
    
    CreateUsersRequest userReq = {users: [admin, customer]};
    CreateUsersResponse userResp = check ep->CreateUsers(userReq);
    io:println(string `✅ Users: ${userResp.message}`);
    
    //Adds Sample cars to an array for storage
    RentalCar[] cars = [
        {
            plate: "CAR001",
            make: "Toyota", 
            model: "Camry",
            year: 2023,
            dailyPrice: 50.0,
            mileage: 15000,
            availability: CAR_AVAILABLE
        },
        {
            plate: "CAR002",
            make: "Honda",
            model: "Civic", 
            year: 2022,
            dailyPrice: 40.0,
            mileage: 20000,
            availability: CAR_AVAILABLE
        }
    ];
    
    foreach RentalCar car in cars {
        AddCarRequest carReq = {car: car};
        AddCarResponse carResp = check ep->AddCar(carReq);
        io:println(string `Car: ${carResp.message}`);
    }
    
    io:println("Initial setup completed!");
}

function interactiveSession() returns error? {
    boolean running = true;
    
    while running {
        io:println("What would you like to do?");
        io:println("1. Add a new car");
        io:println("2. List all available cars"); 
        io:println("3. Search for a car");
        io:println("4. Rent a car");
        io:println("5. Exit");
        
        string choice = io:readln("Your choice (1-5): ");
        
        match choice.trim() {
            "1" => { check addNewCar(); }
            "2" => { check listCars(); }
            "3" => { check searchCar(); }  
            "4" => { check rentCar(); }
            "5" => { 
                io:println("Thank you for using Car Rental System!");
                running = false;
            }
            _ => { io:println("Invalid choice. Please enter 1-5."); }
        }
        
        if running {
            io:println("\nPress Enter to continue...");
            _ = io:readln("");
            io:println("--------------------------------------------------\n");
        }
    }
}

function addNewCar() returns error? {
    io:println("Add New Car");
    string plate = io:readln("Car Plate: ");
    string make = io:readln("Make: ");
    string model = io:readln("Model: ");
    
    // Inpur car details
    string yearInput = io:readln("Year (default 2023): ");
    int year = yearInput.trim() == "" ? 2023 : check int:fromString(yearInput.trim());
    
    string priceInput = io:readln("Daily Price (default 50.0): ");  
    float price = priceInput.trim() == "" ? 50.0 : check float:fromString(priceInput.trim());
    
    string mileageInput = io:readln("Mileage (default 10000): ");
    int mileage = mileageInput.trim() == "" ? 10000 : check int:fromString(mileageInput.trim());
    
    RentalCar car = {
        plate: plate.trim(),
        make: make.trim(), 
        model: model.trim(),
        year: year,
        dailyPrice: price,
        mileage: mileage,
        availability: CAR_AVAILABLE
    };
    
    AddCarRequest request = {car: car};
    AddCarResponse response = check ep->AddCar(request);
    
    if response.success {
        io:println(string `Success: ${response.message}`);
    } else {
        io:println(string `Error: ${response.message}`);
    }
}

function listCars() returns error? {
    io:println("Available Cars");
    
    string filter = io:readln("Filter by make/model (or Enter for all): ");
    
    ListAvailableCarsRequest request = {filter: filter.trim()};
    stream<RentalCar, grpc:Error?> carStream = check ep->ListAvailableCars(request);
    
    int count = 0;
    check carStream.forEach(function(RentalCar car) {
        count += 1;
        io:println(string `${count}. ${car.make} ${car.model} (${car.plate})`);
        io:println(string `   Year: ${car.year} | Price: $${car.dailyPrice}/day | Mileage: ${car.mileage}km`);
    });
    
    if count == 0 {
        io:println("No available cars found.");
    } else {
        io:println(string `Found ${count} available cars`);
    }
}

function searchCar() returns error? {
    io:println("Search Car");    
    string plate = io:readln("Enter car plate: ");
    
    SearchCarRequest request = {plate: plate.trim()};
    SearchCarResponse response = check ep->SearchCar(request);
    
    if response.available {
        RentalCar car = response.car;
        io:println("Car found!");
        io:println(string `Make: ${car.make}`);
        io:println(string `Model: ${car.model}`);
        io:println(string `Year: ${car.year}`);
        io:println(string `Daily Price: $${car.dailyPrice}`);
        io:println(string `Mileage: ${car.mileage}km`);
        io:println("Status: Available");
    } else {
        io:println(string `${response.message}`);
    }
}

function rentCar() returns error? {
    io:println("Rent a Car");
    
    string customerId = io:readln("Your Customer ID (default CUSTOMER1): ");
    if customerId.trim() == "" {
        customerId = "CUSTOMER1";
    }
    
    string plate = io:readln("Car Plate to rent: ");
    string startDate = io:readln("Start Date (YYYY-MM-DD, default 2025-11-01): ");
    if startDate.trim() == "" {
        startDate = "2025-11-01";
    }
    
    string endDate = io:readln("End Date (YYYY-MM-DD, default 2025-11-05): ");
    if endDate.trim() == "" {
        endDate = "2025-11-05";
    }
    
    //Add Car to cart
    AddToCartRequest cartReq = {
        customerID: customerId.trim(),
        plate: plate.trim(),
        startDate: startDate.trim(),
        endDate: endDate.trim()
    };
    
    AddToCartResponse cartResp = check ep->AddToCart(cartReq);
    
    if !cartResp.success {
        io:println(string `Cannot add to cart: ${cartResp.message}`);
        return;
    }
    
    io:println(string `${cartResp.message}`);
    
    string confirm = io:readln("Confirm reservation? (y/n): ");
    if confirm.trim().toLowerAscii() == "y" {
        //Place reservation for car
        PlaceReservationRequest resReq = {customerID: customerId.trim()};
        PlaceReservationResponse resResp = check ep->PlaceReservation(resReq);
        
        if resResp.success {
            CarReservation reservation = resResp.reservation;
            io:println("RESERVATION CONFIRMED!");
            io:println(string `Reservation ID: ${reservation.reservationID}`);
            io:println(string `Car: ${reservation.plate}`);
            io:println(string `Dates: ${reservation.start_date} to ${reservation.end_date}`);
            io:println(string `Total Cost: $${reservation.total_price}`);
        } else {
            io:println(string `Reservation failed: ${resResp.message}`);
        }
    } else {
        io:println("Reservation cancelled");
    }
}
