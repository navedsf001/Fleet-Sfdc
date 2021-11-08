public with sharing class NearestGarageLocator {
    
    private Location location {get; set;}
    private Decimal latitude {get; set;}
    private Decimal longitude {get; set;}

    private Garage__c nearestGarage {get; set;}
    
    private NearestGarageLocator() {}

    private NearestGarageLocator(Location location) {
        this.location = location;
        this.latitude = location.latitude;
        this.longitude = location.longitude;
    }

    public Double getLatitude() {
        return location.latitude;
    }

    public Double getLongitude() {
        return location.longitude;
    }

    public static NearestGarageLocator newInstance(Location fromLocation) {
        return new NearestGarageLocator(fromLocation);
    }

    public Garage__c getNearestGarage() {
        nearestGarage = [SELECT Id, Location__c 
                         FROM Garage__c 
                         ORDER BY DISTANCE(Location__c, GEOLOCATION(:latitude, :longitude), 'mi') 
                         LIMIT 1];
        return nearestGarage;
    }
}