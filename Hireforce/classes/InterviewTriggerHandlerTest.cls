@isTest
public class InterviewTriggerHandlerTest {
    
    @testSetup
    static void setup() {
        Contact userContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert userContact;
        
        Contact interviewerContact = new Contact(FirstName = 'Interviewer', LastName = 'Contact');
        insert interviewerContact;
        
        Application__c app = new Application__c();
        app.Name = 'Test User';
        app.Applicant_Email__c = 'test@user.com';
        app.Contact__c = userContact.Id;
        app.Recruiter__c = interviewerContact.Id; 
        insert app;
    }
    
    @isTest
    static void testHandleBefore() {
        
        Application__c app= [Select id from Application__c where Name = 'Test User' LIMIT 1];
        
        
        // Test with both Start_Time__c and End_Time__c null
        Interview__c interview1 = new Interview__c();
        interview1.Application__c = app.Id;
        insert interview1;

        // Test with valid Interview_Date__c, Start_Time__c, and End_Time__c
        Interview__c interview2 = new Interview__c(
            Interview_Date__c = Date.today(),
            Start_Time__c = '8:00 AM',
            End_Time__c = '10:00 AM'
        );
        interview2.Application__c = app.Id;
        insert interview2;

        // Test with Interview_Date__c null but Start_Time__c and End_Time__c provided
        Interview__c interview3 = new Interview__c(
            Start_Time__c = '8:00 AM',
            End_Time__c = '10:00 AM'
        );
        interview3.Application__c = app.Id;
        try {
            insert interview3;
            System.assert(false, 'Expected exception due to missing Interview_Date__c');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Please select a date for the interview'));
        }

        // Test with Interview_Date__c provided but Start_Time__c greater than End_Time__c
        Interview__c interview4 = new Interview__c(
            Interview_Date__c = Date.today(),
            Start_Time__c = '10:00 AM',
            End_Time__c = '8:30 AM'
        );
        interview4.Application__c = app.Id;
        try {
            insert interview4;
            System.assert(false, 'Expected exception due to invalid time range');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Interview start time cannot be more than end time.'));
        }
    }

    @isTest
    static void testPopulateDateTimeOnInterview() {
        Application__c app= [Select id,Recruiter__c from Application__c where Name = 'Test User' LIMIT 1];
        
        Interviewer__c interviewer = new Interviewer__c();
        interviewer.Employee__c = app.Recruiter__c;
        interviewer.Interviewing_Rounds__c ='Behavioural Interview;Coding Challenge';
        insert interviewer;

 		Interview__c interview = new Interview__c(
            Interview_Date__c = Date.today(),
            Start_Time__c = '8:00 AM',
            End_Time__c = '10:00 AM'
        );
        interview.Application__c = app.Id;   
        interview.Interviewer__c = interviewer.Id;
        insert interview; 

        // Verify Scheduled_Start_Time__c and Scheduled_End_Time__c are populated correctly
        interview = [SELECT Scheduled_Start_Time__c, Scheduled_End_Time__c FROM Interview__c WHERE Id = :interview.Id];
        Datetime expectedStartTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 8, 0, 0);
        Datetime expectedEndTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 10, 0, 0);
        System.assertEquals(expectedStartTime, interview.Scheduled_Start_Time__c, 'Scheduled_Start_Time__c should be correct');
        System.assertEquals(expectedEndTime, interview.Scheduled_End_Time__c, 'Scheduled_End_Time__c should be correct');
    }
}