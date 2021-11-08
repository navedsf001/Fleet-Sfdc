public with sharing class BusMaintenanceBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    private static final Integer THRESHOLD_SIZE = 25; // max batch size to take to restrict number of Location based SOQL queries per batch
    private static final Integer SHCEDULE_DAYS_ADDED = 1; // default value to set schedule for maintenance
    
    private static final Datetime scheduleTime = Datetime.now().addDays(SHCEDULE_DAYS_ADDED); // maintenance schedule time

    private static final String BATCH_SIZE = Label.BusMaintenanceBatch_Size; // To configure batch size
    private static final String CLASS_NAME = BusMaintenanceBatch.class.getName();
    private static final String STATUS_SCHEDULED_FOR_MAINTENANCE = Label.Status_Scheduled_for_Maintenance;

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Boolean eligibleForMaintenance = true;
        String busQuery = 'SELECT Id, Odometer_Reading__c, Recorded_Odometer__c, Last_Maintenance_Date__c, Last_Location__c ' + 
                          'FROM Bus__c ' + 
                          'WHERE Eligible_For_Maintenance__c = :eligibleForMaintenance';
        return Database.getQueryLocator(busQuery);
    }

    public void execute(Database.BatchableContext info, List<Bus__c> buses) {
        List<Maintenance__c> maintenanceList = getMaintenanceScheduleList(buses);

        if(!maintenanceList.isEmpty()) {
            String sourceClass = CLASS_NAME + ':' + 'execute(Database.BatchableContext info, List<Bus__c> buses)';
            List<Database.SaveResult> maintenanceSrList = Database.insert(maintenanceList, false);
            List<Database.SaveResult> busSrList = Database.update(buses, false);
            traceForErrors(sourceClass, buses, busSrList, maintenanceList, maintenanceSrList);
        }
    }

    private List<Maintenance__c> getMaintenanceScheduleList(List<Bus__c> buses) {
        List<Maintenance__c> maintenanceList = new List<Maintenance__c>();

        for(Bus__c bus : buses) {
            Garage__c nearestGarage = getNearestGarage(bus.Last_Location__c);

            if(nearestGarage != null) {
                maintenanceList.add(getMaintenance(bus, nearestGarage.Id));
                updateMaintenanceDetailsInBus(bus);
            }
        }

        return maintenanceList;
    }

    private Garage__c getNearestGarage(Location busLastLocation) {
        NearestGarageLocator locator = NearestGarageLocator.newInstance(busLastLocation);
        return locator.getNearestGarage();
    }

    private Maintenance__c getMaintenance(Bus__c bus, Id garageId) {
        return new Maintenance__c(Bus__c = bus.Id, 
                                  Garage__c = garageId, 
                                  Schedule_Time__c = scheduleTime, 
                                  Recorded_Odometer__c = bus.Odometer_Reading__c);
    }

    private void updateMaintenanceDetailsInBus(Bus__c bus) {
        bus.Recorded_Odometer__c = bus.Odometer_Reading__c;
        bus.Last_Maintenance_Date__c = scheduleTime.dateGMT();
        bus.Current_Status__c = STATUS_SCHEDULED_FOR_MAINTENANCE;
    }

    private void traceForErrors(String sourceClass, List<Bus__c> busList, List<Database.SaveResult> busSrList, List<Maintenance__c> maintenanceList, List<Database.SaveResult> maintenanceSrList) {
        Logger.traceForErrors(sourceClass, busList, busSrList);
        Logger.traceForErrors(sourceClass, maintenanceList, maintenanceSrList);
        Logger.persistLogs();
    }

    public void finish( Database.BatchableContext batchableContext) {
        // To handle any post processing logic
    }

    public void execute(SchedulableContext schedulableContext) {
        BusMaintenanceBatch batchJob = new BusMaintenanceBatch();
        Integer batchSize = Integer.valueOf(BATCH_SIZE);
        Database.executeBatch(batchJob, (batchSize > 0 && batchSize <= THRESHOLD_SIZE) ? batchSize : THRESHOLD_SIZE);
    }
}