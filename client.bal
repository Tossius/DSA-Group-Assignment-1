import ballerina/io;
import ballerina/lang.'int as ints;
import ballerina/http;

final http:Client clientEndpoint = check new ("http://localhost:9090/api/v1");

function GetAssetRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    json|string resp = check clientEndpoint->get("/asset/" + assetTag);
    
    io:println("Asset Details:");
    io:println("================");
    io:println(resp.toJsonString());
    io:println("");
}

function GetAllAssetsRequest() returns error? {
    io:println("");
    json resp = check clientEndpoint->get("/assets");
    
    io:println("All Assets:");
    io:println("============");
    
    if (resp is json[]) {
        int count = 1;
        foreach json asset in resp {
            io:println("Asset " + count.toString() + ":");
            io:println("-------------");
            io:println(asset.toJsonString());
            io:println("");
            count = count + 1;
        }
    } else {
        io:println(resp.toJsonString());
    }
    io:println("");
}

function CreateAssetRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    string name = io:readln("Enter Asset Name: ");
    string faculty = io:readln("Enter Faculty: ");
    string department = io:readln("Enter Department: ");
    string statusInput = io:readln("Enter Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
    string acquiredDate = io:readln("Enter Acquired Date (YYYY-MM-DD): ");

    AssetStatus status = ACTIVE;
    if (statusInput == "UNDER_REPAIR") {
        status = UNDER_REPAIR;
    } else if (statusInput == "DISPOSED") {
        status = DISPOSED;
    }

    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];

    Asset postAsset = {
        assetTag: assetTag,
        name: name,
        faculty: faculty,
        department: department,
        status: status,
        acquiredDate: acquiredDate,
        components: components,
        schedules: schedules,
        workOrders: workOrders
    };

    io:println("");
    io:println("Creating Asset...");
    io:println("==================");
    json resp = check clientEndpoint->post("/assets", postAsset);
    io:println(resp.toJsonString());
    io:println("");
}

function UpdateAssetRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag to Update: ");
    string name = io:readln("Enter New Asset Name: ");
    string faculty = io:readln("Enter New Faculty: ");
    string department = io:readln("Enter New Department: ");
    string statusInput = io:readln("Enter New Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
    string acquiredDate = io:readln("Enter New Acquired Date (YYYY-MM-DD): ");

    AssetStatus status = ACTIVE;
    if (statusInput == "UNDER_REPAIR") {
        status = UNDER_REPAIR;
    } else if (statusInput == "DISPOSED") {
        status = DISPOSED;
    }

    Asset updateAsset = {
        assetTag: assetTag,
        name: name,
        faculty: faculty,
        department: department,
        status: status,
        acquiredDate: acquiredDate,
        components: [],
        schedules: [],
        workOrders: []
    };

    io:println("");
    io:println("Updating Asset...");
    io:println("==================");
    json resp = check clientEndpoint->put("/asset/" + assetTag, updateAsset);
    io:println(resp.toJsonString());
    io:println("");
}

function DeleteAssetRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag to Delete: ");
    
    io:println("");
    io:println("Deleting Asset...");
    io:println("==================");
    json|string resp = check clientEndpoint->delete("/asset/" + assetTag);
    io:println(resp.toJsonString());
    io:println("");
}

function GetAssetsByFacultyRequest() returns error? {
    io:println("");
    string faculty = io:readln("Enter Faculty Name: ");
    
    json resp = check clientEndpoint->get("/faculty/" + faculty);
    
    io:println("");
    io:println("Assets in Faculty: " + faculty);
    io:println("================================");
    io:println(resp.toJsonString());
    io:println("");
}

function GetOverdueAssetsRequest() returns error? {
    io:println("");
    json resp = check clientEndpoint->get("/overdue");
    
    io:println("Overdue Assets:");
    io:println("================");
    io:println(resp.toJsonString());
    io:println("");
}

function AddComponentRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    string componentId = io:readln("Enter Component ID: ");
    string componentName = io:readln("Enter Component Name: ");
    string description = io:readln("Enter Component Description: ");

    Component component = {
        componentId: componentId,
        name: componentName,
        description: description
    };

    io:println("");
    io:println("Adding Component...");
    io:println("===================");
    json resp = check clientEndpoint->post("/asset/" + assetTag + "/components", component);
    io:println(resp.toJsonString());
    io:println("");
}

function AddScheduleRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    string scheduleId = io:readln("Enter Schedule ID: ");
    string maintenanceType = io:readln("Enter Maintenance Type: ");
    string nextDueDate = io:readln("Enter Next Due Date (YYYY-MM-DD): ");
    string description = io:readln("Enter Schedule Description: ");

    Schedule schedule = {
        scheduleId: scheduleId,
        maintenanceType: maintenanceType,
        nextDueDate: nextDueDate,
        description: description
    };

    io:println("");
    io:println("Adding Schedule...");
    io:println("==================");
    json resp = check clientEndpoint->post("/asset/" + assetTag + "/schedules", schedule);
    io:println(resp.toJsonString());
    io:println("");
}

function CreateWorkOrderRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    string workOrderId = io:readln("Enter Work Order ID: ");
    string description = io:readln("Enter Description: ");
    string statusInput = io:readln("Enter Status (OPEN/IN_PROGRESS/CLOSED): ");
    string createdDate = io:readln("Enter Created Date (YYYY-MM-DD): ");

    WorkOrderStatus status = OPEN;
    if (statusInput == "IN_PROGRESS") {
        status = IN_PROGRESS;
    } else if (statusInput == "CLOSED") {
        status = CLOSED;
    }

    WorkOrder workOrder = {
        workOrderId: workOrderId,
        description: description,
        status: status,
        createdDate: createdDate,
        tasks: []
    };

    io:println("");
    io:println("Creating Work Order...");
    io:println("=======================");
    json resp = check clientEndpoint->post("/asset/" + assetTag + "/workorders", workOrder);
    io:println(resp.toJsonString());
    io:println("");
}

function UpdateWorkOrderRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    string workOrderId = io:readln("Enter Work Order ID to Update: ");
    string description = io:readln("Enter New Description: ");
    string statusInput = io:readln("Enter New Status (OPEN/IN_PROGRESS/CLOSED): ");

    WorkOrderStatus status = OPEN;
    if (statusInput == "IN_PROGRESS") {
        status = IN_PROGRESS;
    } else if (statusInput == "CLOSED") {
        status = CLOSED;
    }

    WorkOrder workOrder = {
        workOrderId: workOrderId,
        description: description,
        status: status,
        createdDate: "",
        tasks: []
    };

    io:println("");
    io:println("Updating Work Order...");
    io:println("=======================");
    json resp = check clientEndpoint->put("/asset/" + assetTag + "/workorders/" + workOrderId, workOrder);
    io:println(resp.toJsonString());
    io:println("");
}

function AddTaskRequest() returns error? {
    io:println("");
    string assetTag = io:readln("Enter Asset Tag: ");
    string workOrderId = io:readln("Enter Work Order ID: ");
    string taskId = io:readln("Enter Task ID: ");
    string description = io:readln("Enter Task Description: ");
    string statusInput = io:readln("Enter Task Status (PENDING/IN_PROGRESS/COMPLETED): ");

    TaskStatus status = PENDING;
    if (statusInput == "IN_PROGRESS") {
        status = IN_PROGRESS;
    } else if (statusInput == "COMPLETED") {
        status = COMPLETED;
    }

    Task task = {
        taskId: taskId,
        description: description,
        status: status
    };

    io:println("");
    io:println("Adding Task...");
    io:println("==============");
    json resp = check clientEndpoint->post("/asset/" + assetTag + "/workorders/" + workOrderId + "/tasks", task);
    io:println(resp.toJsonString());
    io:println("");
}

// Fixed main function - removed unreachable code
public function clientMain() returns error? {
    boolean cont = true;

    while cont {
        io:println("========== NUST Facilities Asset Management System ==========");
        io:println("Choose one of the Following Options: ");
        io:println("1. Get All Assets (GET)");
        io:println("2. Get A Single Asset (GET)");
        io:println("3. Create an Asset (POST)");
        io:println("4. Update an Asset (PUT)");
        io:println("5. Delete an Asset (DELETE)");
        io:println("6. Get Assets by Faculty (GET)");
        io:println("7. Get Overdue Assets (GET)");
        io:println("8. Add Component to Asset (POST)");
        io:println("9. Add Schedule to Asset (POST)");
        io:println("10. Create Work Order (POST)");
        io:println("11. Update Work Order (PUT)");
        io:println("12. Add Task to Work Order (POST)");
        string ans = io:readln("Which Option Would you like: ");
        io:println("");
        
        int|error res1 = ints:fromString(ans);
        if (res1 is error) {
            io:println("Please enter a valid number");
            continue;
        }

        if res1 == 1 {
            _ = check GetAllAssetsRequest();
        } else if res1 == 2 {
            _ = check GetAssetRequest();
        } else if res1 == 3 {
            _ = check CreateAssetRequest();
        } else if res1 == 4 {
            _ = check UpdateAssetRequest();
        } else if res1 == 5 {
            _ = check DeleteAssetRequest();
        } else if res1 == 6 {
            _ = check GetAssetsByFacultyRequest();
        } else if res1 == 7 {
            _ = check GetOverdueAssetsRequest();
        } else if res1 == 8 {
            _ = check AddComponentRequest();
        } else if res1 == 9 {
            _ = check AddScheduleRequest();
        } else if res1 == 10 {
            _ = check CreateWorkOrderRequest();
        } else if res1 == 11 {
            _ = check UpdateWorkOrderRequest();
        } else if res1 == 12 {
            _ = check AddTaskRequest();
        } else {
            io:println("Please pick a number from 1-12");
        }

        string answer1 = io:readln("Do you want to call another function? y/n: ");
        if answer1 != "y" {
            cont = false;
        }
    }
}