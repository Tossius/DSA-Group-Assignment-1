import ballerina/http;
import ballerina/time;

public map<Asset> assets = {
    "EQ-001": {
        "assetTag": "EQ-001",
        "name": "3D Printer",
        "faculty": "Computing & Informatics",
        "department": "Software Engineering",
        "status": ACTIVE,
        "acquiredDate": "2024-03-10",
        "components": [
            {
                "componentId": "C001",
                "name": "Print Head",
                "description": "Main printing component"
            }
        ],
        "schedules": [
            {
                "scheduleId": "S001",
                "maintenanceType": "Quarterly",
                "nextDueDate": "2024-12-01",
                "description": "Regular maintenance check"
            }
        ],
        "workOrders": []
    },
    "EQ-002": {
        "assetTag": "EQ-002",
        "name": "Server",
        "faculty": "Computing & Informatics",
        "department": "Information Systems",
        "status": ACTIVE,
        "acquiredDate": "2024-01-15",
        "components": [
            {
                "componentId": "C002",
                "name": "Hard Drive",
                "description": "Storage component"
            }
        ],
        "schedules": [
            {
                "scheduleId": "S002",
                "maintenanceType": "Yearly",
                "nextDueDate": "2024-10-01",
                "description": "Annual system check"
            }
        ],
        "workOrders": []
    }
};

public http:Service assetService = service object {
    
    # Get all assets
    resource function get assets() returns Asset[] {
        return assets.toArray();
    }
    
    # Create a new asset
    resource function post assets(@http:Payload Asset payload) returns json {
        if (payload.assetTag is string) {
            assets[<string>payload.assetTag] = payload;
            return {message: "Asset has been successfully created", assetTag: payload.assetTag};
        }
        return {message: "Asset tag is required"};
    }
    
    # Get a single asset by asset tag
    resource function get asset/[string assetTag]() returns json|Asset {
        if (assets.hasKey(assetTag)) {
            return assets[assetTag];
        }
        return {message: "No asset with that tag found"};
    }
    
    # Update an existing asset
    resource function put asset/[string assetTag](@http:Payload Asset payload) returns json|Asset {
        if (assets.hasKey(assetTag)) {
            Asset? existingAssetOptional = assets[assetTag];
            if (existingAssetOptional is Asset) {
                Asset existingAsset = existingAssetOptional;
                existingAsset.name = payload.name;
                existingAsset.faculty = payload.faculty;
                existingAsset.department = payload.department;
                existingAsset.status = payload.status;
                existingAsset.acquiredDate = payload.acquiredDate;
                
                return existingAsset;
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Delete an asset
    resource function delete asset/[string assetTag]() returns json {
        if (assets.hasKey(assetTag)) {
            Asset removedAsset = assets.remove(assetTag);
            return {message: removedAsset.name.toString() + " has been removed"};
        }
        return {message: "No asset with that tag found"};
    }
    
    # Get assets by faculty
    resource function get faculty/[string faculty]() returns Asset[] {
        Asset[] facultyAssets = [];
        foreach Asset asset in assets {
            if (faculty == asset.faculty) {
                facultyAssets.push(asset);
            }
        }
        return facultyAssets;
    }
    
    # Get overdue assets (assets with maintenance schedules past due date)
    resource function get overdue() returns Asset[] {
        Asset[] overdueAssets = [];
        string currentDate = time:utcToString(time:utcNow()).substring(0, 10); // Get current date in YYYY-MM-DD format
        
        foreach Asset asset in assets {
            boolean hasOverdue = false;
            foreach Schedule schedule in asset.schedules {
                if (schedule.nextDueDate is string && schedule.nextDueDate < currentDate) {
                    hasOverdue = true;
                    break;
                }
            }
            if (hasOverdue) {
                overdueAssets.push(asset);
            }
        }
        return overdueAssets;
    }
    
    # Add a component to an asset
    resource function post asset/[string assetTag]/components(@http:Payload Component payload) returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                asset.components.push(payload);
                return {message: "Component added successfully"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Remove a component from an asset
    resource function delete asset/[string assetTag]/components/[string componentId]() returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                foreach int i in 0 ..< asset.components.length() {
                    if (asset.components[i].componentId == componentId) {
                        Component removedComponent = asset.components.remove(i);
                        return {message: "Component " + removedComponent.name.toString() + " removed"};
                    }
                }
                return {message: "Component not found"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Add a schedule to an asset
    resource function post asset/[string assetTag]/schedules(@http:Payload Schedule payload) returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                asset.schedules.push(payload);
                return {message: "Schedule added successfully"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Remove a schedule from an asset
    resource function delete asset/[string assetTag]/schedules/[string scheduleId]() returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                foreach int i in 0 ..< asset.schedules.length() {
                    if (asset.schedules[i].scheduleId == scheduleId) {
                        Schedule removedSchedule = asset.schedules.remove(i);
                        return {message: "Schedule " + removedSchedule.maintenanceType.toString() + " removed"};
                    }
                }
                return {message: "Schedule not found"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Create a work order for an asset
    resource function post asset/[string assetTag]/workorders(@http:Payload WorkOrder payload) returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                asset.workOrders.push(payload);
                return {message: "Work order created successfully"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Update work order status
    resource function put asset/[string assetTag]/workorders/[string workOrderId](@http:Payload WorkOrder payload) returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                foreach WorkOrder workOrder in asset.workOrders {
                    if (workOrder.workOrderId == workOrderId) {
                        workOrder.status = payload.status;
                        workOrder.description = payload.description;
                        return {message: "Work order updated successfully"};
                    }
                }
                return {message: "Work order not found"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Add a task to a work order
    resource function post asset/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task payload) returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                foreach WorkOrder workOrder in asset.workOrders {
                    if (workOrder.workOrderId == workOrderId) {
                        workOrder.tasks.push(payload);
                        return {message: "Task added successfully"};
                    }
                }
                return {message: "Work order not found"};
            }
        }
        return {message: "No asset with that tag found"};
    }
    
    # Remove a task from a work order
    resource function delete asset/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns json {
        if (assets.hasKey(assetTag)) {
            Asset? assetOptional = assets[assetTag];
            if (assetOptional is Asset) {
                Asset asset = assetOptional;
                foreach WorkOrder workOrder in asset.workOrders {
                    if (workOrder.workOrderId == workOrderId) {
                        foreach int i in 0 ..< workOrder.tasks.length() {
                            if (workOrder.tasks[i].taskId == taskId) {
                                Task removedTask = workOrder.tasks.remove(i);
                                return {message: "Task " + removedTask.description.toString() + " removed"};
                            }
                        }
                        return {message: "Task not found"};
                    }
                }
                return {message: "Work order not found"};
            }
        }
        return {message: "No asset with that tag found"};
    }
};