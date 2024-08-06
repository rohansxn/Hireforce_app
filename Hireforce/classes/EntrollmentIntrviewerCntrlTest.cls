@isTest
public class EntrollmentIntrviewerCntrlTest {
	
    @testSetup 
    static void setup() {
        // Create common test records
        Skill__c skill = new Skill__c(Name='Code Analysis');
        insert skill;
        List<String> title = new List<String>{'Applicant','Interviewer','Hiring manager','recruiter'};
        list<Contact> conLst = new list<Contact>();
        for(Integer i=0;i<4;i++) {
            conLst.add(new Contact(LastName = 'TestCon'+i, Title = title[i],email='test@gmail.com'));
        }
        insert conLst;
        
        Hiring_Event__c hevt = new Hiring_Event__c(Name= 'testevt',Event_Date__c =system.today(),Organizer_Name__c = conLst[2].Id,
                                                  	Start_Time__c = '8:00 AM',End_Time__c = '9:00 AM');
        insert hevt;
        
        Interviewer__c intrvw = new Interviewer__c(Name='interviwer', Employee__c =conLst[1].Id,Interviewing_Rounds__c = 'Phone Interview', 
                                                   Hiring_Manager__c= conLst[2].Id,Available_Slots__c='9:00 AM - 10:00 AM');
        insert intrvw; 
        Skill_Entry__c se = new Skill_Entry__c(Skill__c = skill.Id,Acquired_By__c = conLst[1].Id);
        insert se;
    }
    
    @isTest 
    static void retrieveInterviewersTest() {
        Hiring_Event__c hrevt = [select id from Hiring_Event__c limit 1];
        Interviewer__c intrvw = [select id,Employee__c from Interviewer__c];
        List<String> selIds = new List<String>{intrvw.Id+'@@'+intrvw.Employee__c};
        EntrollmentIntrviewerCntrl.retrieveInterviewers('Code Analysis',hrevt.Id);
        EntrollmentIntrviewerCntrl.getInterviewersEnrolled(hrevt.Id,selIds);
    }
}