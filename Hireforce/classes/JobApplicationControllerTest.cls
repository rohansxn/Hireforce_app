@isTest
public class JobApplicationControllerTest {
    
    @testSetup
    static void setup() {
        // Setup test data for Job__c
        List<Job__c> jobs = new List<Job__c>();
        for(Integer i = 0; i < 5; i++) {
            jobs.add(new Job__c(
                Name = 'Job ' + i,
                Country__c = 'IN',
                Department__c = 'Data',
                Job_Description__c = 'Description ' + i,
                Job_Level__c = 'Entry Level',
                Job_Title__c = 'Title ' + i,
                Job_Type__c = 'Full-Time',
                Language_Requirement__c = 'Language ' + i,
                Job_Status__c = 'Draft',
                Employment_Status__c = 'Open'
            ));
        }
        insert jobs;
        
        Contact interviewerContact = new Contact(FirstName = 'Interviewer', LastName = 'Contact');
        insert interviewerContact;
        
        // Setup test data for Interviewer__c
        List<Interviewer__c> interviewers = new List<Interviewer__c>();
        for(Integer i = 0; i < 3; i++) {
            interviewers.add(new Interviewer__c(
                Name = 'Interviewer ' + i,
                Employee__c = interviewerContact.id,
                Interviewing_Rounds__c = 'Behavioural Interview;Coding Challenge'
            ));
        }
        insert interviewers;
        
        // Setup test data for Application__c
        List<Application__c> applications = new List<Application__c>();
        for(Integer i = 0; i < 3; i++) {
            applications.add(new Application__c(
                Applicant_Email__c = 'applicant' + i + '@example.com',
                Phone_Number__c = '123456789' + i,
                Application_Date__c = Date.today(),
                Job__c = jobs[0].Id,
                Status__c = 'Applied'
            ));
        }
        insert applications;
    }

    @isTest
    static void testGetJobRecords() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        
        Test.startTest();
        List<Job__c> jobs = JobApplicationController.getJobDetails();
        Job__c result = JobApplicationController.getJobRecords(job.Id);
        Test.stopTest();
        
        System.assert(result != null, 'Job record should be returned');
    }

    @isTest
    static void testGetPickListValueWrapper() {
        Test.startTest();
        Map<String, List<JobApplicationController.picklistValueWrapper>> result = JobApplicationController.getPickListValueWrapper('Job__c', new List<String>{'Country__c', 'Job_Level__c'});
        Test.stopTest();
        
        System.assert(result.size() == 2, 'Picklist values should be returned for two fields');
    }

    @isTest
    static void testGetApplicationsByUserEmail() {
        String email = 'applicant0@example.com';
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        
        Test.startTest();
        List<Application__c> applications = JobApplicationController.getApplicationsByUserEmail(email, job.Id);
        List<Application__c> applications2 = JobApplicationController.getApplicationsByUserEmail('', job.Id);
        Test.stopTest();
        
        System.assert(applications.size() > 0, 'Applications should be returned for the given email and job');
    }

    @isTest
    static void testUploadFileAndLinkToRecord() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String fileName = 'testfile.txt';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test content'));
        String contentType = 'text/plain';
        
        Test.startTest();
        JobApplicationController.uploadFileAndLinkToRecord(job.Id, fileName, base64Data, contentType);
        Test.stopTest();
        
        ContentDocumentLink[] cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :job.Id];
        System.assert(cdl.size() > 0, 'File should be uploaded and linked to the job record');
    }

    @isTest
    static void testGetInterviewers() {
        Test.startTest();
        List<Interviewer__c> interviewers = JobApplicationController.getInterviewers(null);
        Test.stopTest();
        
        System.assert(interviewers.size() > 0, 'Interviewers should be returned');
    }

    @isTest
    static void testUpdateInterviewerAvailability() {
        Interviewer__c interviewer = [SELECT Id FROM Interviewer__c LIMIT 1];
        
        Test.startTest();
        JobApplicationController.updateInterviewerAvailability(interviewer.Id);
        Test.stopTest();
        
        Interviewer__c updatedInterviewer = [SELECT Id, Hiring_Event__c FROM Interviewer__c WHERE Id = :interviewer.Id];
        System.assert(updatedInterviewer.Hiring_Event__c == null, 'Interviewer availability should be updated');
    }
}