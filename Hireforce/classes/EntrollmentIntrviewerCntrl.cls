public with sharing class EntrollmentIntrviewerCntrl {
    
    @AuraEnabled
    public static List<Interviewer__c> retrieveInterviewers(String serchtxt,String hringEvtId){
        date today = System.today();
        String serch = '%'+serchtxt+'%';
        String searchquery = 'select id,Name,Employee__c,Hiring_Manager__c,Hiring_Manager__r.Name,Hiring_Event__c,Interviewing_Rounds__c,Employee__r.Name from Interviewer__c';
        
        if(String.isNotEmpty(serchtxt) && !serchtxt.containsIgnoreCase('null'))
        {
            Set<String> conids = new Set<String>(); 
            for(Skill_Entry__c skill : [select id,Acquired_By__c,Skill__c from Skill_Entry__c where Skill__r.Name like :serchtxt AND Acquired_By__c != null])
            {
                conids.add(skill.Acquired_By__c);
            }
            String includeClause = '';
            List<String> intrvwngRounds = InterviewSchedulerController.getpickvls('Interviewer__c','Interviewing_Rounds__c',serchtxt);
            if(intrvwngRounds.size() > 0){
                includeClause = String.join(intrvwngRounds, ';');
            } else{
                includeClause = serchtxt;
            }
            searchquery += ' Where (Name like :serch OR Hiring_Manager__r.Name like :serch OR Employee__c IN: conids OR Interviewing_Rounds__c includes (:includeClause))';
            searchquery += ' And ((Hiring_Event__c != null AND Hiring_Event__c !=: hringEvtId AND Hiring_Event__r.Event_Date__c <: today) OR Hiring_Event__c = null) LIMIT 50';
        } else {
            searchquery += ' Where ((Hiring_Event__c != null AND Hiring_Event__c !=: hringEvtId AND Hiring_Event__r.Event_Date__c <: today) OR Hiring_Event__c = null) LIMIT 50';
        }
        
        List<Interviewer__c> searchList = Database.query(searchquery);
        return searchList;
    }
	
    @AuraEnabled
    public static String getInterviewersEnrolled(String hringEvtId,List<String> selIds){
        Hiring_Event__c hevt = [select id,Name,Event_Date__c from Hiring_Event__c where id =: hringEvtId];
        List<Interviewer__c> intvrList = new List<Interviewer__c>();
        List<Task> tList = new List<Task>(); 
        for(String selId : selIds){
            List<String> idslist = selId.split('@@');
            intvrList.add(new Interviewer__c(Id = idslist[0],Hiring_Event__c = hringEvtId));
            
            Task t = new Task();
            t.OwnerId = UserInfo.getUserId();
            t.Subject = 'Please provide details : '+hevt.Name;
            t.Status = 'Open';
            t.Priority = 'Normal';
            t.WhatId = idslist[0];
            t.WhoId = idslist[1];
            t.ActivityDate = System.today().addDays(1); 
            t.Description = 'Please open Interviewer record associated to this task and provide "Available for Hiring Event" and "Available Slots" details.';
            tList.add(t);
        }
        if(intvrList.size() > 0){
        	update intvrList;	    
        }
        if(tList.size() > 0){
        	insert tList;	    
        }
        return 'done';
    }
}