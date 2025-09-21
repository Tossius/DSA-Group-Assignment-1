public type Asset record {
    # the asset tag (unique identifier)
    string assetTag?;
    # the name of the asset
    string name?;
    # the faculty that owns the asset
    string faculty?;
    # the department within the faculty
    string department?;
    # the status of the asset
    AssetStatus status?;
    # the date the asset was acquired
    string acquiredDate?;
    # components of the asset
    Component[] components;
    # maintenance schedules for the asset
    Schedule[] schedules;
    # work orders for the asset
    WorkOrder[] workOrders;
};

public type Component record {
    # unique identifier for the component
    string componentId?;
    # name of the component
    string name?;
    # description of the component
    string description?;
};

public type Schedule record {
    # unique identifier for the schedule
    string scheduleId?;
    # type of maintenance (e.g., quarterly, yearly)
    string maintenanceType?;
    # next due date for maintenance
    string nextDueDate?;
    # description of the maintenance
    string description?;
};

public type WorkOrder record {
    # unique identifier for the work order
    string workOrderId?;
    # description of the issue
    string description?;
    # status of the work order
    WorkOrderStatus status?;
    # date the work order was created
    string createdDate?;
    # tasks associated with this work order
    Task[] tasks;
};

public type Task record {
    # unique identifier for the task
    string taskId?;
    # description of the task
    string description?;
    # status of the task
    TaskStatus status?;
};

public enum AssetStatus {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

public enum WorkOrderStatus {
    OPEN,
    IN_PROGRESS,
    CLOSED
}

public enum TaskStatus {
    PENDING,
    IN_PROGRESS,
    COMPLETED
}