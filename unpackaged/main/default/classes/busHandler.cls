public with sharing class busHandler {
   
    //Method will be called on before insert or update of bus record.
    public  static void busHandlerLogic(list<Bus__c>lstBus){

        list<Bus__c>lstBusRecord = new list<Bus__c>();
        for(Bus__c objbus : lstBus){
            //check if buses are ready to use
            if(objbus.Current_Status__c == 'Ready For Use') {
                lstBusRecord.add(objbus);

            }
            else {
                //Set 0 if the status of bus is not set to ready for use.
                objbus.Resale_Value__c	= 0;
            }
        }
        //Check if the list has any records.
        if(!lstBusRecord.isEmpty()){
            setResaleValue(lstBusRecord);
        }
    }

    public static void setResaleValue(list<Bus__c>lstBus){
        for(Bus__c objbus : lstBus){
            //Get record from custom metadata
            Bus_Starting_Selling_Price_Mapping__mdt selprice = Bus_Starting_Selling_Price_Mapping__mdt.getInstance('Capacity_'+objbus.Maximum_Capacity__c);
            //set Resale value based on Maximum capcity
            objbus.Resale_Value__c = selprice.Starting_Selling_Price__c;
            //Check if the Bus has air condition
            if(objBus.Has_Air_Conditioning__c){
                objbus.Resale_Value__c =objbus.Resale_Value__c * 0.03;
            }
            //Check for historical bus
            if(objbus.Year__c	< 1972){

                objbus.Resale_Value__c =objbus.Resale_Value__c * 0.34;
            }
            //Check Odometer Status
            if(objBus.Odometer_Reading__c > 10000){
                
                objbus.Resale_Value__c =objbus.Resale_Value__c - 10000 * 0.1;
            }
        }

    }
}