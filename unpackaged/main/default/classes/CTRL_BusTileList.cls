public with sharing class CTRL_BusTileList {

    private static final Integer DEFAULT_PAGE_SIZE = 12;
    
    @AuraEnabled(cacheable=true)
    public static PageResultWrapper getBusPageResultWrapper(Integer pageSize, Integer pageNumber) {
        Integer safePageSize = (pageSize == null) ? DEFAULT_PAGE_SIZE : pageSize;
        Integer safePageNumber = (pageNumber == null) ? 1 : pageNumber;

        Integer offset = (safePageNumber - 1) * safePageSize;

        PageResultWrapper wrapperInstance = new PageResultWrapper();
        wrapperInstance.pageSize = safePageSize;
        wrapperInstance.pageNumber = safePageNumber;

        wrapperInstance.totalItemCount = [SELECT count() FROM Bus__c];
        wrapperInstance.busRecords = [SELECT Id, Name, Garage__c, Year__c, Has_Air_Conditioning__c, Image_URL__c, Thumbnail_URL__c, 
                                      Maximum_Capacity__c, Odometer_Reading__c, Resale_Value__c, Current_Status__c
                                      FROM Bus__c
                                      LIMIT :safePageSize
                                      OFFSET :offset];

        return wrapperInstance;
    }

    private with sharing class PageResultWrapper {
        @AuraEnabled public Integer pageSize {get; set;}
        @AuraEnabled public Integer pageNumber {get; set;}
        @AuraEnabled public Integer totalItemCount {get; set;}
        @AuraEnabled public List<Bus__c> busRecords {get; set;}
    }
    
}