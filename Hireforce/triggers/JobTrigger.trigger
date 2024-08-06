trigger JobTrigger on Job__c (after insert, after update, before update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        JobTriggerHandler.handleAfterUpdate(Trigger.new);
    }
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
           JobTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}