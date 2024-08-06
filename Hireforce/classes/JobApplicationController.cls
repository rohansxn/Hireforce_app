public with sharing class JobApplicationController {
    
    @AuraEnabled(cacheable=true)
    public static List<Job__c> getJobDetails() {
        return [SELECT Id,Name,Country__c,State_province__c,Department__c,Job_Description__c,Job_Level__c,Job_Title__c,Job_Type__c,Language_Requirement__c,Job_Status__c, Employment_Status__c  FROM Job__c WHERE Job_Status__c='Published' AND Employment_Status__c ='Open'];
    }

    @AuraEnabled(cacheable=true)
    public static Job__c getJobRecords(Id jobId) {
        return [SELECT Id,Name,Country__c,State_province__c,Department__c,Job_Description__c,Job_Level__c,Job_Title__c,Job_Type__c,Language_Requirement__c,Job_Status__c, Employment_Status__c, Role_And_Responsibilities__c, (Select id, Skill__c, Skill__r.name from Required_Skills__r)  FROM Job__c WHERE Id =:jobId WITH SYSTEM_MODE LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,List<picklistValueWrapper>> getPickListValueWrapper(String objectName, List<String> picklistFieldApiList) {
        Map<String,List<picklistValueWrapper>> mapOfPicklistApiWithValues = new Map<String,List<picklistValueWrapper>>();
        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        for(String picklistFieldApi : picklistFieldApiList){            
            // if(objectName == 'Job__c' && picklistFieldApi=='Country__c'){
            //     continue;
            // }
            List <picklistValueWrapper> customObjWrapper = new List <picklistValueWrapper> ();
            List <Schema.PicklistEntry> picklistFields = mapFields.get(picklistFieldApi).getDescribe().getPicklistValues();            
            for (Schema.PicklistEntry myCustPick: picklistFields) {
                if(myCustPick.isActive()){
                    picklistValueWrapper selectOptionValueWrapper = new picklistValueWrapper();
                    selectOptionValueWrapper.label = myCustPick.getLabel();
                    selectOptionValueWrapper.value = myCustPick.getValue();
                    selectOptionValueWrapper.isDefaultValue = myCustPick.isDefaultValue();
                    customObjWrapper.add(selectOptionValueWrapper);
                }
            }
            system.debug('');
            mapOfPicklistApiWithValues.put(picklistFieldApi,customObjWrapper);
        }       
        return mapOfPicklistApiWithValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<Application__c> getApplicationsByUserEmail(String userEmail, Id jobId) {
        if (String.isEmpty(userEmail)) {
            return new List<Application__c>();
        }
        String queryStr = 'SELECT Id, Name, Applicant_Email__c, Phone_Number__c, Application_Date__c, Job__r.Name, Job__r.Country__c, Job__r.State_province__c, Status__c '+
                          'FROM Application__c WHERE Applicant_Email__c = :userEmail ';
        if(jobId!=null){
            queryStr+=' AND Job__c=:jobId';
        }
        queryStr+=' order by Application_Date__c DESC';
        return (List<Application__c>)Database.query(queryStr);
    }

    @AuraEnabled
    public static void uploadFileAndLinkToRecord(Id recordId, String fileName, String base64Data, String contentType) {
        // Decode the Base64 data
        Blob fileContent = EncodingUtil.base64Decode(base64Data);
        
        // Create the ContentVersion object
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileContent;
        contentVersion.IsMajorVersion = true;
        insert contentVersion;
        
        // Retrieve the ContentDocumentId
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id WITH SYSTEM_MODE].ContentDocumentId;
        contentDocumentLink.LinkedEntityId = recordId;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;
    }

    @AuraEnabled(cacheable=true)
    public static List<Interviewer__c> getInterviewers(String hiringEventId) {
        system.debug('@@hiringEventId: '+hiringEventId);
        List<Interviewer__c> interviewerList = [SELECT Id, Name, Available_Slots__c, Interviewing_Rounds__c FROM Interviewer__c where Hiring_Event__c=:hiringEventId];
        system.debug('@@interviewerList: '+interviewerList);
        return interviewerList;
    }

    @AuraEnabled
    public static void updateInterviewerAvailability(Id interviewerId) {
        Interviewer__c interviewer = [SELECT Id, Hiring_Event__c FROM Interviewer__c WHERE Id = :interviewerId LIMIT 1];
        interviewer.Hiring_Event__c = null;
        update interviewer;
    } 

    //wrapper class for picklist options
    public with sharing class picklistValueWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public Boolean isDefaultValue {get;set;}
    }
}