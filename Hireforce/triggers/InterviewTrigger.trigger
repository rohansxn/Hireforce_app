trigger InterviewTrigger on Interview__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            InterviewTriggerHandler.handleBefore(Trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            InterviewTriggerHandler.handleAfter(Trigger.new);
        }
    }
    
}