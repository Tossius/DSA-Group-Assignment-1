import ballerina/grpc;
import ballerina/io;

// Global variables for user session
string currentUserID = "";
string currentUserRole = "";

public function main() returns error? {
	CarRentalSystemServiceClient svcClient = check new ("http://localhost:9090");
	
	// Login system
	check loginUser(svcClient);
	
	// Main interactive loop based on user role
	if currentUserRole == "ADMIN" {
		check adminInteractiveSession(svcClient);
	} else {
		check customerInteractiveSession(svcClient);
	}
}

function loginUser(CarRentalSystemServiceClient svcClient) returns error? {
	io:println("=== Car Rental System Login ===");
	
	// Create sample users if they don't exist
	check createSampleUsers(svcClient);
	
	io:println("Available users:");
	io:println("1. ADMIN (admin@example.com) - Full access");
	io:println("2. CUSTOMER1 (john@example.com) - Customer access");
	io:println("3. CUSTOMER2 (jane@example.com) - Customer access");
	
	string choice = io:readln("Select user (1-3): ");
	
	match choice.trim() {
		"1" => {
			currentUserID = "admin1";
			currentUserRole = "ADMIN";
			io:println("Logged in as Admin");
		}
		"2" => {
			currentUserID = "customer1";
			currentUserRole = "CUSTOMER";
			io:println("Logged in as Customer (John)");
		}
		"3" => {
			currentUserID = "customer2";
			currentUserRole = "CUSTOMER";
			io:println("Logged in as Customer (Jane)");
		}
		_ => {
			io:println("Invalid choice. Defaulting to customer.");
			currentUserID = "customer1";
			currentUserRole = "CUSTOMER";
		}
	}
}

function adminInteractiveSession(CarRentalSystemServiceClient svcClient) returns error? {
	boolean running = true;
	
	while running {
		io:println("\n=== ADMIN DASHBOARD ===");
		io:println("1. Add a new car");
		io:println("2. Update car details");
		io:println("3. Remove a car");
		io:println("4. List all cars");
		io:println("5. Search for a car");
		io:println("6. Create new users");
		io:println("7. Exit");
		
		string choice = io:readln("Your choice (1-7): ");
		
		match choice.trim() {
			"1" => { check addNewCar(svcClient); }
			"2" => { check updateCar(svcClient); }
			"3" => { check removeCar(svcClient); }
			"4" => { check listCars(svcClient); }
			"5" => { check searchCar(svcClient); }
			"6" => { check createUsers(svcClient); }
			"7" => { 
				io:println("Thank you for using Car Rental System!");
				running = false;
			}
			_ => { io:println("Invalid choice. Please enter 1-7."); }
		}
		
		if running {
			io:println("\nPress Enter to continue...");
			_ = io:readln("");
		}
	}
}

function customerInteractiveSession(CarRentalSystemServiceClient svcClient) returns error? {
	boolean running = true;
	
	while running {
		io:println("\n=== CUSTOMER DASHBOARD ===");
		io:println("1. List available cars");
		io:println("2. Search for a car");
		io:println("3. Rent a car");
		io:println("4. Exit");
		
		string choice = io:readln("Your choice (1-4): ");
		
		match choice.trim() {
			"1" => { check listCars(svcClient); }
			"2" => { check searchCar(svcClient); }
			"3" => { check rentCar(svcClient); }
			"4" => { 
				io:println("Thank you for using Car Rental System!");
				running = false;
			}
			_ => { io:println("Invalid choice. Please enter 1-4."); }
		}
		
		if running {
			io:println("\nPress Enter to continue...");
			_ = io:readln("");
		}
	}
}

// Admin-only functions
function addNewCar(CarRentalSystemServiceClient svcClient) returns error? {
	if currentUserRole != "ADMIN" {
		io:println("❌ Access denied. Admin privileges required.");
		return;
	}
	
	io:println("=== Add New Car ===");
	string plate = io:readln("Car Plate: ");
	string make = io:readln("Make: ");
	string model = io:readln("Model: ");
	
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
	AddCarResponse response = check svcClient->AddCar(request);
	
	if response.success {
		io:println(string `✅ Success: ${response.message}`);
	} else {
		io:println(string `❌ Error: ${response.message}`);
	}
}

function updateCar(CarRentalSystemServiceClient svcClient) returns error? {
	if currentUserRole != "ADMIN" {
		io:println("❌ Access denied. Admin privileges required.");
		return;
	}
	
	io:println("=== Update Car ===");
	string plate = io:readln("Enter car plate to update: ");
	
	// First search for the car to get current details
	SearchCarRequest searchReq = {plate: plate.trim()};
	SearchCarResponse searchResp = check svcClient->SearchCar(searchReq);
	
	if !searchResp.available {
		io:println(string `❌ ${searchResp.message}`);
		return;
	}
	
	RentalCar currentCar = searchResp.car;
	io:println("Current car details:");
	io:println(string `  Make: ${currentCar.make}`);
	io:println(string `  Model: ${currentCar.model}`);
	io:println(string `  Year: ${currentCar.year}`);
	io:println(string `  Daily Price: $${currentCar.dailyPrice}`);
	io:println(string `  Mileage: ${currentCar.mileage}km`);
	
	io:println("\nEnter new details (press Enter to keep current value):");
	
	string newMake = io:readln(string `New Make (current: ${currentCar.make}): `);
	if newMake.trim() == "" {
		newMake = currentCar.make;
	}
	
	string newModel = io:readln(string `New Model (current: ${currentCar.model}): `);
	if newModel.trim() == "" {
		newModel = currentCar.model;
	}
	
	string newYearInput = io:readln(string `New Year (current: ${currentCar.year}): `);
	int newYear = newYearInput.trim() == "" ? currentCar.year : check int:fromString(newYearInput.trim());
	
	string newPriceInput = io:readln(string `New Daily Price (current: $${currentCar.dailyPrice}): `);
	float newPrice = newPriceInput.trim() == "" ? currentCar.dailyPrice : check float:fromString(newPriceInput.trim());
	
	string newMileageInput = io:readln(string `New Mileage (current: ${currentCar.mileage}): `);
	int newMileage = newMileageInput.trim() == "" ? currentCar.mileage : check int:fromString(newMileageInput.trim());
	
	RentalCar updatedCar = {
		plate: plate.trim(),
		make: newMake.trim(),
		model: newModel.trim(),
		year: newYear,
		dailyPrice: newPrice,
		mileage: newMileage,
		availability: currentCar.availability
	};
	
	UpdateCarRequest request = {plate: plate.trim(), updatedCar: updatedCar};
	UpdateCarResponse response = check svcClient->UpdateCar(request);
	
	if response.success {
		io:println(string `✅ ${response.message}`);
	} else {
		io:println(string `❌ ${response.message}`);
	}
}

function removeCar(CarRentalSystemServiceClient svcClient) returns error? {
	if currentUserRole != "ADMIN" {
		io:println("❌ Access denied. Admin privileges required.");
		return;
	}
	
	io:println("=== Remove Car ===");
	string plate = io:readln("Enter car plate to remove: ");
	
	// First search for the car to confirm it exists
	SearchCarRequest searchReq = {plate: plate.trim()};
	SearchCarResponse searchResp = check svcClient->SearchCar(searchReq);
	
	if !searchResp.available {
		io:println(string `❌ ${searchResp.message}`);
		return;
	}
	
	RentalCar carToRemove = searchResp.car;
	io:println("Car to be removed:");
	io:println(string `  Make: ${carToRemove.make}`);
	io:println(string `  Model: ${carToRemove.model}`);
	io:println(string `  Plate: ${carToRemove.plate}`);
	
	string confirm = io:readln("Are you sure you want to remove this car? (y/n): ");
	if confirm.trim().toLowerAscii() == "y" {
		RemoveCarRequest request = {plate: plate.trim()};
		RemoveCarResponse response = check svcClient->RemoveCar(request);
		
		if response.success {
			io:println(string `✅ ${response.message}`);
			io:println(string `Remaining cars: ${response.remaining_cars.length()}`);
		} else {
			io:println(string `❌ ${response.message}`);
		}
	} else {
		io:println("Car removal cancelled.");
	}
}

function createUsers(CarRentalSystemServiceClient svcClient) returns error? {
	if currentUserRole != "ADMIN" {
		io:println("❌ Access denied. Admin privileges required.");
		return;
	}
	
	io:println("=== Create New Users ===");
	
	RentalUser[] newUsers = [];
	boolean addMore = true;
	
	while addMore {
		io:println("\nEnter user details:");
		string userID = io:readln("User ID: ");
		string name = io:readln("Name: ");
		string email = io:readln("Email: ");
		
		io:println("Role:");
		io:println("1. Customer");
		io:println("2. Admin");
		string roleChoice = io:readln("Select role (1-2): ");
		
		RentalUserRole role = CUSTOMER;
		if roleChoice.trim() == "2" {
			role = ADMIN;
		}
		
		RentalUser newUser = {
			userID: userID.trim(),
			name: name.trim(),
			email: email.trim(),
			role: role
		};
		
		newUsers.push(newUser);
		
		string continueChoice = io:readln("Add another user? (y/n): ");
		addMore = continueChoice.trim().toLowerAscii() == "y";
	}
	
	if newUsers.length() > 0 {
		CreateUsersRequest request = {users: newUsers};
		CreateUsersResponse response = check svcClient->CreateUsers(request);
		io:println(string `✅ ${response.message}`);
	}
}

// Customer functions
function listCars(CarRentalSystemServiceClient svcClient) returns error? {
	io:println("=== Available Cars ===");
	
	string filter = io:readln("Filter by make/model (or Enter for all): ");
	
	ListAvailableCarsRequest request = {filter: filter.trim()};
	stream<RentalCar, grpc:Error?> carStream = check svcClient->ListAvailableCars(request);
	
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

function searchCar(CarRentalSystemServiceClient svcClient) returns error? {
	io:println("=== Search Car ===");    
	string plate = io:readln("Enter car plate: ");
	
	SearchCarRequest request = {plate: plate.trim()};
	SearchCarResponse response = check svcClient->SearchCar(request);
	
	if response.available {
		RentalCar car = response.car;
		io:println("✅ Car found!");
		io:println(string `Make: ${car.make}`);
		io:println(string `Model: ${car.model}`);
		io:println(string `Year: ${car.year}`);
		io:println(string `Daily Price: $${car.dailyPrice}`);
		io:println(string `Mileage: ${car.mileage}km`);
		io:println("Status: Available");
	} else {
		io:println(string `❌ ${response.message}`);
	}
}

function rentCar(CarRentalSystemServiceClient svcClient) returns error? {
	io:println("=== Rent a Car ===");
	
	string plate = io:readln("Car Plate to rent: ");
	string startDate = io:readln("Start Date (YYYY-MM-DD, default 2025-11-01): ");
	if startDate.trim() == "" {
		startDate = "2025-11-01";
	}
	
	string endDate = io:readln("End Date (YYYY-MM-DD, default 2025-11-05): ");
	if endDate.trim() == "" {
		endDate = "2025-11-05";
	}
	
	// Add Car to cart
	AddToCartRequest cartReq = {
		customerID: currentUserID,
		plate: plate.trim(),
		startDate: startDate.trim(),
		endDate: endDate.trim()
	};
	
	AddToCartResponse cartResp = check svcClient->AddToCart(cartReq);
	
	if !cartResp.success {
		io:println(string `❌ Cannot add to cart: ${cartResp.message}`);
		return;
	}
	
	io:println(string `✅ ${cartResp.message}`);
	
	string confirm = io:readln("Confirm reservation? (y/n): ");
	if confirm.trim().toLowerAscii() == "y" {
		// Place reservation for car
		PlaceReservationRequest resReq = {customerID: currentUserID};
		PlaceReservationResponse resResp = check svcClient->PlaceReservation(resReq);
		
		if resResp.success {
			CarReservation reservation = resResp.reservation;
			io:println("🎉 RESERVATION CONFIRMED!");
			io:println(string `Reservation ID: ${reservation.reservationID}`);
			io:println(string `Car: ${reservation.plate}`);
			io:println(string `Dates: ${reservation.start_date} to ${reservation.end_date}`);
			io:println(string `Total Cost: $${reservation.total_price}`);
		} else {
			io:println(string `❌ Reservation failed: ${resResp.message}`);
		}
	} else {
		io:println("Reservation cancelled");
	}
}

// Helper function to create sample users
function createSampleUsers(CarRentalSystemServiceClient svcClient) returns error? {
	RentalUser[] sampleUsers = [
		{userID: "admin1", name: "Admin User", email: "admin@example.com", role: ADMIN},
		{userID: "customer1", name: "John Doe", email: "john@example.com", role: CUSTOMER},
		{userID: "customer2", name: "Jane Smith", email: "jane@example.com", role: CUSTOMER}
	];
	
	CreateUsersRequest request = {users: sampleUsers};
	CreateUsersResponse response = check svcClient->CreateUsers(request);
	io:println(string `Users initialized: ${response.usersCreated} users created`);
	return;
}