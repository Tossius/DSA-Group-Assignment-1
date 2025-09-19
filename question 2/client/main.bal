import ballerina/grpc;
import ballerina/io;

public function main() returns error? {
	CarRentalServiceClient svcClient = check new ("http://localhost:9090");
	check testAdminOperations(svcClient);
	check testCustomerOperations(svcClient);
}

function testAdminOperations(CarRentalServiceClient svcClient) returns error? {
	io:println("=== Testing Admin Operations ===");
	check createSampleUsers(svcClient);
	
	Car car1 = {plate: "ABC-123", make: "Toyota", model: "Camry", year: 2022, daily_price: 50.0, mileage: 25000, status: AVAILABLE};
	var addResponse = check svcClient->AddCar({car: car1});
	io:println("Add car response: ", addResponse.message);
	
	Car car2 = {plate: "XYZ-789", make: "Honda", model: "Accord", year: 2023, daily_price: 55.0, mileage: 15000, status: AVAILABLE};
	_ = check svcClient->AddCar({car: car2});
	io:println("Second car added successfully");
}

function testCustomerOperations(CarRentalServiceClient svcClient) returns error? {
	io:println("\n=== Testing Customer Operations ===");
	
	stream<Car, grpc:Error?> carStream = check svcClient->ListAvailableCars({filter: ""});
	io:println("Available cars:");
	check carStream.forEach(function(Car car) {
		io:println(string `  - ${car.make} ${car.model} (${car.plate}) - $${car.daily_price}/day`);
	});
	
	var searchResponse = check svcClient->SearchCar({plate: "ABC-123"});
	io:println("Search result: ", searchResponse.message);
	
	var cartResponse = check svcClient->AddToCart({
		customer_id: "customer1",
		plate: "ABC-123",
		start_date: "2025-10-01",
		end_date: "2025-10-05"
	});
	io:println("Add to cart response: ", cartResponse.message);
	
	var reservationResponse = check svcClient->PlaceReservation({customer_id: "customer1"});
	io:println("Reservation response: ", reservationResponse.message);
	io:println("Total cost: $", reservationResponse.total_cost);
	return;
}

function createSampleUsers(CarRentalServiceClient svcClient) returns error? {
	User[] sampleUsers = [
		{user_id: "admin1", name: "Admin User", email: "admin@example.com", role: CUSTOMER},
		{user_id: "customer1", name: "John Doe", email: "john@example.com", role: CUSTOMER}
	];
	
	CreateUsersStreamingClient sClient = check svcClient->CreateUsers();
	foreach var u in sampleUsers {
		check sClient->sendUser(u);
	}
	check sClient->complete();
	var respOrNil = check sClient->receiveCreateUsersResponse();
	if respOrNil is CreateUsersResponse {
		io:println("Users created: ", respOrNil.users_created);
	}
	return;
}