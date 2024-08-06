public with sharing class JobTriggerHandler {
    
    public static void handleBeforeUpdate(Map<Id,Job__c> newMap, Map<Id,Job__c> oldMap){
        List<Id> jobIdForApprovalSubmission = new List<Id>();
        
        for(Job__c job : newMap.values()){
            if(!String.isBlank(job.Job_Status__c) && job.Job_Status__c !=oldMap.get(job.Id).Job_Status__c){
                if(job.Job_Status__c=='Ready to be Submitted for Approval'){
                    jobIdForApprovalSubmission.add(job.Id);
                } 
                else if(job.Job_Status__c=='Ready to be Published' && job.Auto_publish_after_approval__c){
                    job.Job_Status__c ='Published';
                }          
                else if(job.Job_Status__c=='Published' && job.Job_Status__c !=oldMap.get(job.Id).Job_Status__c && oldMap.get(job.Id).Job_Status__c!='Ready to be Published'){
                    job.addError('Job can be published only when it has been approved.');
                }
            }
            if(job.Auto_publish_after_approval__c && job.Auto_publish_after_approval__c!=oldMap.get(job.Id).Auto_publish_after_approval__c && job.Job_Status__c=='Ready to be Published'){
                job.Job_Status__c ='Published';
            }
        }
        
        if(!jobIdForApprovalSubmission.isEmpty()){
            for(Job__c job: [Select Id, (Select Id from Required_Skills__r) from Job__c where Id in:jobIdForApprovalSubmission]){
                if(job.Required_Skills__r==null || job.Required_Skills__r.size()==0){
                    newMap.get(job.Id).addError('Please add skills before submitting for approval');
                }
            }
        }
    }
    
    
    public static void handleAfterUpdate(List<Job__c> newJobList){
        List<Job__c> jobListToSendForApproval = new List<Job__c>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Job__c job : newJobList){
            if(job.Job_Status__c == 'Ready to be Submitted for Approval'){
                jobListToSendForApproval.add(job);
                contactIdSet.add(job.Hiring_Manger__c);
            }
        }
        if(!jobListToSendForApproval.isEmpty()){
           // Set<Id> contactIdSet = new Set<Id>();
            Map<Id,Id> contactIdWithUserIdMap = new Map<Id,Id>();
           /* for(Job__c job : jobListToSendForApproval){ //this can be removed and ids collected at above loop
                contactIdSet.add(job.Hiring_Manger__c);
            } */
            contactIdSet.remove(null);
            if(!contactIdSet.isEmpty()){
                for(User usr : [Select Id, ContactId from User where ContactId In:contactIdSet]){
                    contactIdWithUserIdMap.put(usr.ContactId, usr.Id);
                }
            }
            
            List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest>();
            for(Job__c job : jobListToSendForApproval){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(job.Id);
                
                // Submit on behalf of a specific submitter
                req.setSubmitterId(UserInfo.getUserId()); 
                
                // Submit the record to specific process and skip the criteria evaluation
                req.setProcessDefinitionNameOrId('Job_Posting_Approval_Process');
                req.setSkipEntryCriteria(false);
                if(String.isNotEmpty(job.Approver__c)){
                    req.setNextApproverIds(new List<Id>{job.Approver__c});
                    approvalList.add(req);
                } else if(String.isNotEmpty(job.Hiring_Manger__c)){
                	//req.setNextApproverIds(new List<Id>{job.Hiring_Manger__c});
                	Id userId = !contactIdWithUserIdMap.isEmpty() && contactIdWithUserIdMap.containsKey(job.Hiring_Manger__c) ? contactIdWithUserIdMap.get(job.Hiring_Manger__c) : null;
                    if(userId!=null){
                        req.setNextApproverIds(new List<Id>{userId});
                    	approvalList.add(req);
                    }   
                }
            }
            if(!approvalList.isEmpty()){
                // Submit the approval request for the account
                for(Approval.ProcessSubmitRequest req:approvalList){
                    Approval.ProcessResult result = Approval.process(req);  
                } 
            } 
        } 
    }
}