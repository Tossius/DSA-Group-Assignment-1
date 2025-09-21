import ballerina/io;
import ballerina/lang.runtime;
import ballerina/http;

public function main() returns error? {
    // Display startup message
    io:println("Starting NUST Facilities Asset Management System...");
    
    // Start the HTTP service explicitly
    http:Listener httpListener = check new (9090, config = {host: "localhost"});
    
    // Attach the service to the listener
    check httpListener.attach(assetService, "/api/v1");
    
    // Start the listener
    check httpListener.'start();
    
    io:println("Service started on http://localhost:9090/api/v1");
    
    // Give the service a moment to be fully ready
    runtime:sleep(2);
    
    // Test if service is ready
    http:Client testClient = check new ("http://localhost:9090/api/v1");
    json|error healthCheck = testClient->get("/assets");
    
    if healthCheck is error {
        io:println("Service health check failed:", healthCheck.message());
        return healthCheck;
    }
    
    io:println("Service is ready!");
    io:println("Starting client interface...\n");

    // Run the client menu loop
    check clientMain();
    
    io:println("\nThank you for using NUST Asset Management System!");
    
    // Stop the service gracefully
    check httpListener.gracefulStop();
}