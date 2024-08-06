@isTest
public class JobTriggerHandlerTest {
    @testSetup
    static void setup() {
        
        List<Job__c> jobs = new List<Job__c>();
        for (Integer i = 0; i < 5; i++) {
            Job__c job = new Job__c( Name = 'Test Job ' + i, Job_Status__c = 'Draft', Auto_publish_after_approval__c = false);
            jobs.add(job);
        }
        insert jobs;
        
        Skill__c skill = new Skill__c();
        skill.name='Data';
        insert skill;
        
        List<Skill_Entry__c> skillsEntry = new List<Skill_Entry__c>();
        for (Job__c job : jobs) {
            Skill_Entry__c  sE = new Skill_Entry__c(Skill__c = skill.Id, Required_for__c = job.Id);
            skillsEntry.add(sE);
        }
        insert skillsEntry;
    }
    
    @isTest
    static void testHandleBeforeUpdate() {
        List<Job__c> jobs = [SELECT Id, Job_Status__c, Auto_publish_after_approval__c FROM Job__c];
        
        // Update job status to trigger the handleBeforeUpdate logic
        for (Job__c job : jobs) {
            job.Job_Status__c = 'Ready to be Submitted for Approval';
        }
        
        Test.startTest();
        update jobs;
        Test.stopTest();
        
        // Validate that jobs with status 'Ready to be Submitted for Approval' are handled correctly
        for (Job__c job : jobs) {
            job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :job.Id];
            System.assertEquals('Ready to be Submitted for Approval', job.Job_Status__c);
        }
    }
    
    @isTest
    static void testHandleAfterUpdate() {
        List<Job__c> jobs = [SELECT Id, Job_Status__c, Auto_publish_after_approval__c, Approver__c FROM Job__c];
        
        // Update job status to trigger the handleAfterUpdate logic
        for (Job__c job : jobs) {
            job.Job_Status__c = 'Ready to be Submitted for Approval';
            job.Approver__c = UserInfo.getUserId(); // Assign current user as approver for testing
        }
        
        Test.startTest();
        update jobs;
        Test.stopTest();
        
        // Validate that approval process is triggered correctly
        for (Job__c job : jobs) {
            job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :job.Id];
            System.assertEquals('In Review', job.Job_Status__c);
        }
        
        List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :jobs[0].Id];
        if (!processInstances.isEmpty()) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :processInstances[0].Id];
            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                approveRequest.setComments('Approving request.');
                approveRequest.setAction('Approve');
                approveRequest.setWorkitemId(workItems[0].Id);
                Approval.ProcessResult approvalResult = Approval.process(approveRequest);
                System.assert(approvalResult.isSuccess(), 'The approval request should be successful.');
            }
        }
        
        Job__c job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :jobs[0].Id];
        System.assertEquals('Ready to be Published', job.Job_Status__c);  
        
        job.Auto_publish_after_approval__c = true;
        update job;
        
        job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :jobs[0].Id];
        System.assertEquals('Published', job.Job_Status__c);
        
    }
    
    
    @isTest
    static void testHandleAfterUpdateAutoPublish() {
        List<Job__c> jobs = [SELECT Id, Job_Status__c, Auto_publish_after_approval__c, Approver__c FROM Job__c];
        
        // Update job status to trigger the handleAfterUpdate logic
        for (Job__c job : jobs) {
            job.Auto_publish_after_approval__c = true;
            job.Job_Status__c = 'Ready to be Submitted for Approval';
            job.Approver__c = UserInfo.getUserId(); // Assign current user as approver for testing
        }
        
        Test.startTest();
        update jobs;
        Test.stopTest();
        
        // Validate that approval process is triggered correctly
        for (Job__c job : jobs) {
            job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :job.Id];
            System.assertEquals('In Review', job.Job_Status__c);
        }
        
        List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :jobs[0].Id];
        if (!processInstances.isEmpty()) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :processInstances[0].Id];
            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                approveRequest.setComments('Approving request.');
                approveRequest.setAction('Approve');
                approveRequest.setWorkitemId(workItems[0].Id);
                Approval.ProcessResult approvalResult = Approval.process(approveRequest);
                System.assert(approvalResult.isSuccess(), 'The approval request should be successful.');
            }
        }
        
        Job__c job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :jobs[0].Id];
        System.assertEquals('Published', job.Job_Status__c);        
    }
    
    
    @isTest
    static void testHandleAfterUpdateReject() {
        List<Job__c> jobs = [SELECT Id, Job_Status__c, Auto_publish_after_approval__c, Approver__c FROM Job__c];
        
        // Update job status to trigger the handleAfterUpdate logic
        for (Job__c job : jobs) {
            job.Job_Status__c = 'Ready to be Submitted for Approval';
            job.Approver__c = UserInfo.getUserId(); // Assign current user as approver for testing
        }
        
        Test.startTest();
        update jobs;
        Test.stopTest();
        
        // Validate that approval process is triggered correctly
        for (Job__c job : jobs) {
            job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :job.Id];
            System.assertEquals('In Review', job.Job_Status__c);
            // Further validation can be done by querying Approval records, if needed
        }
        
        List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :jobs[1].Id];
        if (!processInstances.isEmpty()) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :processInstances[0].Id];
            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                approveRequest.setComments('Rejecting request.');
                approveRequest.setAction('Reject');
                approveRequest.setWorkitemId(workItems[0].Id);
                Approval.ProcessResult approvalResult = Approval.process(approveRequest);
            }
        }  
        
        Job__c job = [SELECT Id, Job_Status__c FROM Job__c WHERE Id = :jobs[1].Id];
        System.assertEquals('Sent back for Correction', job.Job_Status__c);        
    }
    
    
    @isTest
    static void testValidationErrors() {
        List<Job__c> jobs = [SELECT Id, Job_Status__c, Auto_publish_after_approval__c FROM Job__c LIMIT 1];
        
        // Test validation errors for job status
        Job__c job = jobs[0];
        job.Job_Status__c = 'Published';
        
        Test.startTest();
        try {
            update job;
            System.assert(false, 'Expected an error to be thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Job can be published only when it has been approved.'));
        }

        // Test validation errors for missing required skills
        job.Job_Status__c = 'Ready to be Submitted for Approval';
        // Delete required skills to trigger the error
        delete [SELECT Id FROM Skill_Entry__c WHERE Required_for__c  = :job.Id];

        try {
            update job;
            System.assert(false, 'Expected an error to be thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Please add skills before submitting for approval'));
        }
        Test.stopTest();
    }
}