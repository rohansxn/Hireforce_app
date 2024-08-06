public class InterviewTriggerHandler {
    
    public static void handleBefore(List<Interview__c> newInterviewList){
        validateDateTimeEntries(newInterviewList);
        populateDateTimeOnInterview(newInterviewList); 
    }
    
    public static void validateDateTimeEntries(List<Interview__c> newInterviewList){
        for(Interview__c interviewRecord : newInterviewList){
            if(interviewRecord.Interview_Date__c==null && (interviewRecord.Start_Time__c != null || interviewRecord.End_Time__c!= null)){
                interviewRecord.addError('Please select a date for the interview');
            }
            else if(interviewRecord.Interview_Date__c!=null && interviewRecord.Start_Time__c != null && interviewRecord.End_Time__c!= null && parseTime(interviewRecord.Start_Time__c) > parseTime(interviewRecord.End_Time__c)){
                interviewRecord.addError('Interview start time cannot be more than end time.');
            }
        }
        
    }
    
    public static void populateDateTimeOnInterview(List<Interview__c> newInterviewList){
        for(Interview__c interviewRecord : newInterviewList){
            if (interviewRecord.Interview_Date__c != null) { 
                if(interviewRecord.Start_Time__c != null){
                    interviewRecord.Scheduled_Start_Time__c = getDateTime(interviewRecord.Interview_Date__c, interviewRecord.Start_Time__c); 
                }
                if(interviewRecord.End_Time__c!= null){
                    interviewRecord.Scheduled_End_Time__c = getDateTime(interviewRecord.Interview_Date__c, interviewRecord.End_Time__c);                    
                }
            } 
        }
    }
    
    private static DateTime getDateTime(Date scheduleDate, String scheduleTime){
        Datetime interviewDatetime;
        // Assume startTime is in the format "h:mm a" (e.g., "8:00 AM")
        Time parsedTime = parseTime(scheduleTime);
        if (parsedTime != null) {
            Date date1 = scheduleDate;
            interviewDatetime = DateTime.newInstance(date1.year(), date1.month(), date1.day(), parsedTime.hour(), parsedTime.minute(), 0);
        }
        return interviewDatetime;
    }
    
    private static Time parseTime(String timeStr) {
        
        // Example time format: "8:00 AM"
        List<String> parts = timeStr.split(' ');
        if (parts.size() != 2) return null; // Invalid format
        
        String timePart = parts[0];
        String periodPart = parts[1];
        
        List<String> timeComponents = timePart.split(':');
        if (timeComponents.size() != 2) return null; // Invalid format
        
        Integer hour = Integer.valueOf(timeComponents[0]);
        Integer minute = Integer.valueOf(timeComponents[1]);
        
        if (periodPart == 'PM' && hour != 12) { hour += 12; } 
        else if (periodPart == 'AM' && hour == 12) { hour = 0; }  
        
        return Time.newInstance(hour, minute, 0, 0);
    }
    
    public static void handleAfter(List<Interview__c> newInterviewList){
        if(Trigger.isInsert){
            createEventRecords(newInterviewList,null);    
        } else if(Trigger.isUpdate){
            createEventRecords(newInterviewList,Trigger.oldMap);
        }
        
    }
    
    public static void createEventRecords(List<Interview__c> newInterviewList,Map<Id,SObject> oldInterviewMap){
        
        Savepoint sp = Database.setSavepoint();
        Map<String,Event> intrvEventMap = new Map<String,Event>();
        List<EventRelation> evtInvitees = new List<EventRelation>();
        for(Interview__c intrv : newInterviewList) {
            Interview__c oldIntrv;
            if(oldInterviewMap != null && oldInterviewMap.containsKey(intrv.Id)) {
                oldIntrv = (Interview__c) oldInterviewMap.get(intrv.Id);
            }
            if(isEligibleforAddingEvent(intrv,oldIntrv)){
                event evt = new Event(
                    OwnerId = UserInfo.getUserId(),
                    WhatId = intrv.Id,
                    StartDateTime = intrv.Scheduled_Start_Time__c,
                    EndDateTime = intrv.Scheduled_End_Time__c,
                    ActivityDateTime = intrv.Scheduled_Start_Time__c, 
                    Subject = 'Interview is Scheduled for round : '+intrv.Round_Name__c
                );
                intrvEventMap.put(intrv.Id,evt);
            }
        }
        try{
            if(intrvEventMap.values().size() > 0){
                insert intrvEventMap.values();    
            }
            for(Interview__c intrv : [Select id,Application__r.Contact__c,Application__r.Recruiter__c,Interviewer__r.Employee__c from Interview__c where Id IN: intrvEventMap.keySet()]){
                event tempEvt = intrvEventMap.get(intrv.Id);
                if(intrv.Application__r.Contact__c != null){
                    EventRelation er = new EventRelation(
                        EventId = tempEvt.Id,
                        RelationId = intrv.Application__r.Contact__c,
                        IsInvitee = true
                    );
                    evtInvitees.add(er);
                }
                if(intrv.Application__r.Recruiter__c != null){
                    EventRelation er = new EventRelation(
                        EventId = tempEvt.Id,
                        RelationId = intrv.Application__r.Recruiter__c,
                        IsInvitee = true
                    );
                    evtInvitees.add(er);
                }
                if(intrv.Interviewer__r.Employee__c != null){
                    EventRelation er = new EventRelation(
                        EventId = tempEvt.Id,
                        RelationId = intrv.Interviewer__r.Employee__c,
                        IsInvitee = true
                    );
                    evtInvitees.add(er);
                }
            }
            
            if(evtInvitees.size() > 0){
                insert evtInvitees;    
            }
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            Database.rollback(sp);
        }
    }
    
    public static boolean isEligibleforAddingEvent(Interview__c intrv,Interview__c oldIntrv){
        if(intrv.Interview_Date__c != null && String.isNotEmpty(intrv.Start_Time__c) && String.isNotEmpty(intrv.End_Time__c) &&
               (oldIntrv == null || (oldIntrv != null && (intrv.Interview_Date__c != oldIntrv.Interview_Date__c || 
                                                          intrv.Start_Time__c != oldIntrv.Start_Time__c || 
                                                          intrv.End_Time__c != oldIntrv.End_Time__c))))
        {
            return true;
        }
        return false;
    }
    
    
}