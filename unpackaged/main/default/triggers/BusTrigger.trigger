trigger BusTrigger on Bus__c (before insert,before update) {

    if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore){

         busHandler.busHandlerLogic(trigger.new);

    }
}