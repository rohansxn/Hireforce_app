@isTest
public class InterviewSchedulerControllerTest {

    @testSetup static void setup() {
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
                                                   Hiring_Manager__c= conLst[2].Id,Hiring_Event__c=hevt.id,Available_Slots__c='9:00 AM - 10:00 AM');
        insert intrvw;  
        
        Job__c jb = new Job__c(name='job',Approver__c = UserInfo.getUserId(),Hiring_Manger__c = conLst[2].Id,
                              Auto_publish_after_approval__c = true,Employment_Status__c='Open',Job_Status__c = 'Draft');
        insert jb;
        
        Skill_Entry__c se = new Skill_Entry__c(Skill__c = skill.Id,Required_for__c=jb.Id);
        insert se;
        
        jb.Job_Status__c = 'Ready to be Submitted for Approval';
        update jb;
        Set<Id> targetObjectIdSet = new Set<Id>{jb.Id};
        
        Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId 
                                                              FROM ProcessInstance 
                                                              where Status='Pending' 
                                                              AND TargetObjectId in : targetObjectIdSet])).keySet();
        for(ProcessInstanceWorkitem processInstanceWorkItems:  [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds]){
            Approval.ProcessWorkitemRequest singleApprovalProcess = new Approval.ProcessWorkitemRequest();
            singleApprovalProcess.setComments('Reason here.');
            singleApprovalProcess.setAction('Approve');
            singleApprovalProcess.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            singleApprovalProcess.setWorkitemId(processInstanceWorkItems.Id);
            Approval.ProcessResult result = Approval.process(singleApprovalProcess); 
        }
        
        Application__c app = new Application__c(name='jhon', Applicant_Email__c ='abc@gmail.com',Contact__c = conLst[0].id,
                                               Job__c =jb.Id,Phone_Number__c = '234567890',Recruiter__c = conLst[3].id,Status__c = 'Initial Screening Done');
        insert app;
    }
    
    @isTest 
    static void getNavigationDecisionTest() {
        Job__c jb = [Select id from Job__c limit 1];
        Hiring_Event__c hrevt = [select id from Hiring_Event__c limit 1];
        Application__c app = [select id from Application__c limit 1];
    	InterviewSchedulerController.getNavigationDecision('Job__c',jb.Id);
        InterviewSchedulerController.getNavigationDecision('Hiring_Event__c',hrevt.Id);
        InterviewSchedulerController.getNavigationDecision('Application__c',app.Id);
    }
    
    @isTest 
    static void getApplicantsListTest() {
        Job__c jb = [Select id from Job__c limit 1];
    	InterviewSchedulerController.getApplicantsList('job','job',jb.Id,'Initial Screening Done');    
    }
    
    @isTest 
    static void getFslDaywrapTest(){
        Job__c jb = [Select id from Job__c limit 1];
        Hiring_Event__c hrevt = [select id from Hiring_Event__c limit 1];
        Application__c app = [select id from Application__c limit 1];
        Interviewer__c intrvw = [select id from Interviewer__c limit 1];
        String day = String.valueOf(system.today().day());
        String mnth = String.valueOf(system.today().month());
        String yearr = String.valueOf(system.today().year());
        Interview__c interview = new Interview__c(Application__c=app.id);
        string datestr = mnth+'/'+day+'/'+yearr;
        InterviewSchedulerController.getneededPickListVals();
        InterviewSchedulerController.getInterviewSlotverified(datestr,'10',intrvw.Id,'1',interview);
        InterviewSchedulerController.intrvwWrap intvWrp = InterviewSchedulerController.getnewInterviewSent(datestr,'10',intrvw.Id,'1',interview,'job',jb.Id);
        InterviewSchedulerController.getInterviewSlotverified(datestr,'9',intrvw.Id,'3',interview);
        InterviewSchedulerController.getInterviewupdated(datestr,JSON.serialize(intvWrp),'8',intrvw.Id);
        InterviewSchedulerController.getIntrvwFeedbackUpdated(intvWrp.intrvw.Id,'Reject','text');
        InterviewSchedulerController.getIntrvwStsUpdated(intvWrp.intrvw.Id,'Confirmed');
        InterviewSchedulerController.getFslDaywrap(yearr,mnth,day,'current','job',jb.Id,'1','Test');
        InterviewSchedulerController.getFslDaywrap(yearr,mnth,day,'current','hiringevent',hrevt.Id,'1','Test');
        InterviewSchedulerController.getFslDaywrap(yearr,mnth,day,'current','application',app.Id,'1','Test');
        InterviewSchedulerController.gethr('12','AM');
        InterviewSchedulerController.gethr('1','PM');
        InterviewSchedulerController.gethr('2','PM');
        InterviewSchedulerController.gethr('3','PM');
        InterviewSchedulerController.gethr('4','PM');
        InterviewSchedulerController.gethr('5','PM');
        InterviewSchedulerController.gethr('6','PM');
        InterviewSchedulerController.gethr('7','PM');
        InterviewSchedulerController.gethr('8','PM');
        InterviewSchedulerController.gethr('9','PM');
        InterviewSchedulerController.gethr('10','PM');
        InterviewSchedulerController.gethr('11','PM');
        InterviewSchedulerController.gethr('12','PM');
    }
    
    @isTest 
    static void getFslDaywrapTest2(){
        Job__c jb = [Select id from Job__c limit 1];
        Hiring_Event__c hrevt = [select id from Hiring_Event__c limit 1];
        Application__c app = [select id from Application__c limit 1];
        Interviewer__c intrvw = [select id from Interviewer__c limit 1];
        String day = String.valueOf(system.today().day());
        String mnth = String.valueOf(system.today().month());
        String yearr = String.valueOf(system.today().year());
        Interview__c interview = new Interview__c(Application__c=app.id);
        string datestr = mnth+'/'+day+'/'+yearr;
        InterviewSchedulerController.getInterviewSlotverified(datestr,'18',intrvw.Id,'10',interview);
        //InterviewSchedulerController.getnewInterviewSent(datestr,'18',intrvw.Id,'20',interview,'job',jb.Id);
        
    }
}