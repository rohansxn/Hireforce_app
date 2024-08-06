public class InterviewSchedulerController {
    public final static List<String> employmentStatusesToConsiderJobs = 
        Scheduler_Configuration__mdt.getInstance('EmploymentStatusesToConsiderJobs').PickList_Values__c.split(',');//new Set<String>{'Open'};
    public final static List<String> jobStatusesToConsiderJobs = 
        Scheduler_Configuration__mdt.getInstance('Job_Statuses_To_Consider_Jobs').PickList_Values__c.split(','); //new Set<String>{'Published'};
    public final static List<String> interviewStatusesToSkipApplications =
        Scheduler_Configuration__mdt.getInstance('InterviewStatusesToSkipApplications').PickList_Values__c.split(','); //new Set<String>{'Invite Sent','Confirmed','In Progress'};
    public final static List<String> StatusestoshowApplications =
        Scheduler_Configuration__mdt.getInstance('Statuses_to_show_Applications').PickList_Values__c.split(',');   
    public final static Integer Interviewers_Per_page = Integer.valueOf(Scheduler_Configuration__mdt.getInstance('Number_Of_Interviewers_Per_page').Page_Size__c);
    public final static List<String> rejectionDecisionVals = 
        Scheduler_Configuration__mdt.getInstance('Decision_Statuses_to_reject_Application').PickList_Values__c.split(',');
    public final static String intrvScheduledAppStatus =
        Scheduler_Configuration__mdt.getInstance('Application_Status_interview_scheduled').Specific_Value__c;
    public final static List<String> intrvRescheduleStatuses = 
        Scheduler_Configuration__mdt.getInstance('Interview_Rescheduling_Statuses').PickList_Values__c.split(',');
    
    @AuraEnabled
    public static String getNavigationDecision(String objectNme,String objId){
        if(objectNme.containsIgnoreCase('Hiring_Event__c')) {
        	Hiring_Event__c hevt = [select id,Event_Date__c, (select id from Interviewers__r) from Hiring_Event__c where id =: objId]; 
            if(hevt.Event_Date__c < system.today()){
            	return 'hide';    
            } else if(hevt.Interviewers__r.size() == 0){
                return 'Please assign interviewers for the hiring event to facilitate the scheduling of interviews.'; 
            }
        } else if(objectNme.containsIgnoreCase('Job__c')) {
            String hrmngrId = '';
            Boolean ishide = true;
            for(Job__c jb : [select id,Hiring_Manger__c,(select id from Applications__r where Status__c IN: StatusestoshowApplications) from Job__c where Employment_Status__c IN :employmentStatusesToConsiderJobs AND Job_Status__c IN :jobStatusesToConsiderJobs AND Id =: objId]){
                ishide = false;
                hrmngrId = jb.Hiring_Manger__c;
                if(jb.Applications__r.size() == 0){
                	return 'No eligible applications found to facilitate interview scheduling.';    
                }
            }
            return getInterviwerCount(hrmngrId,ishide);
            
        } else if(objectNme.containsIgnoreCase('Application__c')) {
            String hrmngrId = '';
            Boolean ishide = true;
            for(Application__c app : [select id,Job__r.Hiring_Manger__c from Application__c where Job__r.Employment_Status__c IN :employmentStatusesToConsiderJobs AND Job__r.Job_Status__c IN :jobStatusesToConsiderJobs AND Status__c IN: StatusestoshowApplications AND Id =: objId]) {
            	ishide = false;
                hrmngrId = app.Job__r.Hiring_Manger__c;   
            }
            return getInterviwerCount(hrmngrId,ishide);
        }
        return 'ok';
    }
    
    @AuraEnabled
    public static String getInterviwerCount(String hrmngrId,Boolean ishide){ 
        if(String.isNotEmpty(hrmngrId) && [select count() from Interviewer__c where Hiring_Manager__c =: hrmngrId] == 0) {
            return 'Please assign interviewers to the hiring manager for the job to facilitate interview scheduling.'; 
        }
        if(ishide){
            return 'hide';    
        }
        return 'ok';
    }
    
    @AuraEnabled
    public static list<jobWrap> getApplicantsList(String serchtxt,String navigatedFrom,String appOrJobOrHiringEvntId,String status)
    {
        if(String.isEmpty(status)){
        	status = StatusestoshowApplications[0];     
        }
        map<String,jobWrap> jbWrpMap = new map<String,jobWrap>();
        String serch = '%'+serchtxt+'%';
        String searcStatus = '%'+status+'%';
        String searchquery = 'select id,Name,Job__c,Job__r.Name,Job__r.Job_Description__c,Job__r.Job_Level__c,Applicant_Email__c,Application_Date__c,Status__c,Application_Id__c, (Select Id from Interviews__r Where Status__c IN: interviewStatusesToSkipApplications) from Application__c where';
        list<Application__c> applicantList = new list<Application__c>();
        String whereclause = ' Job__r.Employment_Status__c IN :employmentStatusesToConsiderJobs AND Job__r.Job_Status__c IN :jobStatusesToConsiderJobs';
        if(String.isNotEmpty(status)){
            whereclause += ' AND Status__c like: searcStatus';
        }
        if(String.isNotEmpty(serchtxt))
        {
            whereclause += ' AND (Job__r.Job_Title__c like :serch or Job__r.Job_Type__c like :serch or Job__r.Name like :serch)';
        }
        if(navigatedFrom.equalsIgnoreCase('application')){
            whereclause += ' AND Id =: appOrJobOrHiringEvntId';
        } else if(navigatedFrom.equalsIgnoreCase('job')){
        	whereclause += ' AND Job__c =: appOrJobOrHiringEvntId';
        }
        searchquery += whereclause+' limit 49999';
        for(Application__c app : Database.query(searchquery)){
            if(app.Interviews__r.size() == 0){
                if(applicantList.size() > 20){
                    break;
                }
            	applicantList.add(app);
                jobWrap tempJb = new jobWrap();
                if(jbWrpMap.containsKey(app.Job__c))
                {
                	tempJb = jbWrpMap.get(app.Job__c);
                }
                tempJb.jobb = new Job__c(Id = app.Job__c,Name = app.Job__r.Name,
                                         Job_Description__c = app.Job__r.Job_Description__c,
                                         Job_Level__c = app.Job__r.Job_Level__c); 
                tempJb.appList.add(app);
                jbWrpMap.put(app.Job__c,tempJb);
            }		    
        }
        return jbWrpMap.Values();
    }
    
    @AuraEnabled
    public static fsldaywrap getFslDaywrap(string yr,string mnth,string day,string currentornextorprevspecifier,String navigatedFrom,
                                           String appOrJobOrHiringEvntId,String pagNum,String roundOrHiringMngrName)
    {
        String hiringManagerId = '';
        integer yrr = integer.valueOf(yr);
        integer mnthh = integer.valueOf(mnth);
        integer dyy = integer.valueOf(day);
        date selectdt = date.newinstance(yrr,mnthh,dyy);
        if(navigatedFrom.equalsIgnoreCase('hiringevent')){
        	selectdt = [select id,Event_Date__c from Hiring_Event__c where id =: appOrJobOrHiringEvntId].Event_Date__c;	    
        }
        if(currentornextorprevspecifier == 'next')
        {
            selectdt = selectdt.addDays(1);
        }
        if(currentornextorprevspecifier == 'previous')
        {
            selectdt = selectdt.addDays(-1);
        }
        Set<String> timeslotss = new Set<String>();
        Time Timee = Time.newInstance(0, 0, 0, 0);
        datetime strtdttme = datetime.newinstance(selectdt,Timee);
        fsldaywrap fsdywrp = new fsldaywrap();
        fsdywrp.presentdatee = selectdt;
        fsdywrp.weekdayy = strtdttme.format('EEEE');
        string strtdatemnth = strtdttme.format('MMM');
        string strtdaystrng = string.valueOf(strtdttme.day());
        Scheduler_Configuration__mdt oprthr = Scheduler_Configuration__mdt.getInstance('Interviewing_Hours');
        Time oprtStartTime = getTimeFromReadableAmPMValue(oprthr.Start_Time__c);
        integer optstrthr = oprtStartTime.hour();
        Time oprtEndTime = getTimeFromReadableAmPMValue(oprthr.End_Time__c);
        integer optendhr = oprtEndTime.hour();
        integer totalopthrs = optendhr-optstrthr;
        strtdttme = strtdttme.addHours(optstrthr);
        datetime enddttime = strtdttme.addHours(totalopthrs);
        fsdywrp.dsplyhdng = strtdatemnth+' '+strtdaystrng;
        integer pageNumber = integer.valueOf(pagNum);
        integer recordsToSkip = 0;
        integer nxtPageRecordsToSkip = 0;
        if(pageNumber > 1){
            recordsToSkip = (pageNumber-1)*Interviewers_Per_page;
            nxtPageRecordsToSkip = pageNumber*Interviewers_Per_page;
        }
        
        String intrvQuery = 'SELECT id,Name,Available_Slots__c,Employee__r.Name,Interviewing_Rounds__c,Employee__c from Interviewer__c'; 
        String condition = '';
        if(navigatedFrom.equalsIgnoreCase('application')){
        	hiringManagerId = getApplication(appOrJobOrHiringEvntId).Job__r.Hiring_Manger__c;
            condition = ' Where Hiring_Manager__c =: hiringManagerId';
        } else if(navigatedFrom.equalsIgnoreCase('job')){
        	hiringManagerId = getJobInfo(appOrJobOrHiringEvntId).Hiring_Manger__c;
            condition = ' Where Hiring_Manager__c =: hiringManagerId';
        } else if(navigatedFrom.equalsIgnoreCase('hiringevent')){
            condition = ' Where Hiring_Event__c =: appOrJobOrHiringEvntId';
        } else if(navigatedFrom.equalsIgnoreCase('Interviewer')){
            condition = ' Where Id =: appOrJobOrHiringEvntId';
        }
        if(String.isNotEmpty(roundOrHiringMngrName)){
            String includeClause = '';
            List<String> intrvwngRounds = getpickvls('Interviewer__c','Interviewing_Rounds__c',roundOrHiringMngrName);
            if(intrvwngRounds.size() > 0){
                includeClause = String.join(intrvwngRounds, ';');
            } else{
                includeClause = roundOrHiringMngrName;
            }
            String serchtxt = '%'+roundOrHiringMngrName+'%';
            if(String.isNotEmpty(condition)){
            	condition += ' AND (Name like :serchtxt OR Hiring_Manager__r.Name like :serchtxt OR Interviewing_Rounds__c includes (:includeClause))';    
            } else {
                condition += ' Where (Name like :serchtxt OR Hiring_Manager__r.Name like :serchtxt OR Interviewing_Rounds__c includes (:includeClause))';
            }
           
        }
        if(String.isNotEmpty(condition)){
           intrvQuery += condition;
        }
        intrvQuery += ' ORDER BY Name LIMIT '+String.valueOf(Interviewers_Per_page);
        String nxtIntrvQuery = intrvQuery+' OFFSET '+String.valueOf(nxtPageRecordsToSkip);
        intrvQuery += ' OFFSET '+String.valueOf(recordsToSkip);
        List<Interviewer__c> nxtIntvwrList = new List<Interviewer__c>();
        nxtIntvwrList = Database.query(nxtIntrvQuery);
        if(nxtIntvwrList.size() == 0){
        	fsdywrp.isLastInterviewerSet = true;    
        }    
        
        List<Interviewer__c> intvwrList = new List<Interviewer__c>();
        intvwrList = Database.query(intrvQuery);
        map<string,Interviewer__c> intrvwrMap = new map<string,Interviewer__c>(intvwrList);
        
        Map<string,list<Interview__c>> intervwrIntervwsMap = new Map<string,list<Interview__c>>();
        for(Interview__c intrvv : [select id,Name,Application__c,Application__r.Name,Application__r.Job__r.Name,Interviewer__c,Interviewer__r.Name,Status__c,Round_Name__c,
                                          Start_Time__c,End_Time__c,Scheduled_Start_Time__c,Scheduled_End_Time__c,Interview_Date__c,Interview_Type__c from Interview__c where
                                          Scheduled_Start_Time__c >=: strtdttme and Scheduled_Start_Time__c <: enddttime and Interviewer__c IN: intrvwrMap.keySet()])
        {
            list<Interview__c> lstIntrvws;
            if(intervwrIntervwsMap.containsKey(intrvv.Interviewer__c)){
                lstIntrvws = intervwrIntervwsMap.get(intrvv.Interviewer__c);
            }else{
                lstIntrvws = new list<Interview__c>();    
            }
            lstIntrvws.add(intrvv);
            intervwrIntervwsMap.put(intrvv.Interviewer__c,lstIntrvws);
        }
        
        Map<String,List<String>> roundNamesWithInterviewrs = new Map<String,List<String>>(); 
        map<string,list<hourwrap>> intrvwrHoursWrapLst = new map<string,list<hourwrap>>();
        
        for(Interviewer__c intrvwr : intrvwrMap.values())
        {
            List<String> roundNames = new List<String>();
            if(intrvwr.Interviewing_Rounds__c.contains(';')){
            	roundNames = intrvwr.Interviewing_Rounds__c.split(';');    
            } else {
                if(String.isNotEmpty(intrvwr.Interviewing_Rounds__c)){
                	roundNames.add(intrvwr.Interviewing_Rounds__c);     
                }
            }
            for(String roundName : roundNames){
                List<String> intrvrsIds;
                if(roundNamesWithInterviewrs.containsKey(roundName)){
                	intrvrsIds = roundNamesWithInterviewrs.get(roundName); 
                } else {
                    intrvrsIds = new List<String>();
                }
                intrvrsIds.add(intrvwr.Id);
                roundNamesWithInterviewrs.put(roundName,intrvrsIds);
            }
            integer avallength = totalopthrs;
            list<hourwrap> temphorwrplstt = new list<hourwrap>();
            for(Integer i=0;i<=23;i++)
            {
                if(i == 0)
                {
                    avallength = totalopthrs;
                }
                hourwrap hr = new hourwrap();
                hr.starttime = Time.newInstance(i, 0, 0, 0);
                hr.strthr = Time.newInstance(i, 0, 0, 0).hour();
                hr.readableStarttm = gethringentimmings(hr.strthr);
                hr.readableEndtm = gethringentimmings(hr.strthr+1);
                hr.endtime = Time.newInstance(i+1, 0, 0, 0);
                hr.maxavillength = 0;
                if(hr.starttime >= oprtStartTime && hr.endtime <= oprtEndTime && i != 23)
                {
                    hr.maxavillength = 1;
                    hr.isoperatinghour = true;
                    if(String.isNotEmpty(intrvwr.Available_Slots__c)){
                        List<String> avlSlots = new List<String>();
                        if(intrvwr.Available_Slots__c.contains(';')){
                           avlSlots = intrvwr.Available_Slots__c.split(';'); 
                        } else{
                            avlSlots.add(intrvwr.Available_Slots__c);
                        }
                        for(String slot : avlSlots){
                            List<String> startEndHours = slot.split('-');
                            if(hr.starttime == getTimeFromReadableAmPMValue(startEndHours[0]) && navigatedFrom.equalsIgnoreCase('hiringevent')){
                                hr.isInterviwerAvailableSlot = true;    
                            }
                        }
                    }
                    timeslotss.add(gethringentimmings(hr.strthr));
                    avallength = avallength - 1;
                }
                temphorwrplstt.add(hr);
            }
            if(intervwrIntervwsMap.containsKey(intrvwr.Id)){
                for(Interview__c tempintrv : intervwrIntervwsMap.get(intrvwr.Id))
                {
                    date tempscdlstrtdt = tempintrv.Scheduled_Start_Time__c.date();
                    date tempschenddte = tempintrv.Scheduled_End_Time__c.date();
                    integer sechstrthr = tempintrv.Scheduled_Start_Time__c.hour();
                    integer secstrtmints = tempintrv.Scheduled_Start_Time__c.minute();
                    integer secendhr = tempintrv.Scheduled_End_Time__c.hour();
                    integer secendmnts = tempintrv.Scheduled_End_Time__c.minute();
                    integer hrdiff = secendhr-sechstrthr;
                    integer maxindexnum = hrdiff;
                    if(tempschenddte > tempscdlstrtdt)
                    {
                        integer tempppdiff = 24-sechstrthr;
                        integer tempdiff2 = secendhr-0;
                        hrdiff = tempppdiff+tempdiff2;
                        maxindexnum = tempppdiff;
                    }
                    integer mindiff = 0;
                    if(secendmnts > secstrtmints)
                    {
                        mindiff = secendmnts-secstrtmints;
                    }
                    if(secstrtmints > secendmnts)
                    {
                        hrdiff = hrdiff-1;
                        mindiff = secstrtmints-secendmnts;
                    }
                    intrvwWrap intrvwrp = new intrvwWrap();
                    intrvwrp.intrvw = tempintrv;
                    intrvwrp.intrvDtStrng = tempintrv.Interview_Date__c.format();
                    intrvwrp.hourrdurationn = hrdiff;
                    intrvwrp.mindurationn = mindiff;
                    if(!intrvRescheduleStatuses.contains(tempintrv.Status__c)){
                       intrvwrp.isReschedulable = false;
                    }
                    for(integer i=0;i<maxindexnum;i++)
                    {
                        integer reqindx = sechstrthr+i;
                        hourwrap temphrwrp = new hourwrap();
                        temphrwrp = temphorwrplstt.get(reqindx);
                        list<intrvwWrap> tempinterviewLst = temphrwrp.interviewLst;
                        tempinterviewLst.add(intrvwrp);
                        temphrwrp.interviewLst = tempinterviewLst;
                        if(reqindx == sechstrthr)
                        {
                            list<intrvwWrap> tempinterviewScheduledstartthishour = temphrwrp.interviewScheduledstartthishour;
                            tempinterviewScheduledstartthishour.add(intrvwrp);
                            temphrwrp.interviewScheduledstartthishour = tempinterviewScheduledstartthishour;
                        }
                        temphorwrplstt.set(reqindx,temphrwrp);
                    }
                }
            }
            intrvwrHoursWrapLst.put(intrvwr.id,temphorwrplstt);
        }
        fsdywrp.tmlblslst.addAll(timeslotss);
        list<interviewRoundWrap> tempintrvwRoundWrapLst = new list<interviewRoundWrap>();
       	for(String tempRoundName : roundNamesWithInterviewrs.keySet())
        {
            interviewRoundWrap irw = new interviewRoundWrap();
            irw.roundName = tempRoundName;
            list<intrvwRoundInterviewersWrap> temproundIntervwrslst = new list<intrvwRoundInterviewersWrap>();
            for(String intrvwrId : roundNamesWithInterviewrs.get(tempRoundName))
            {
                Interviewer__c intrvwr = intrvwrMap.get(intrvwrId);
                intrvwRoundInterviewersWrap temproundIntrvwr = new intrvwRoundInterviewersWrap();
                list<hourwrap> temphrwraplst = new list<hourwrap>();
                temphrwraplst = (intrvwrHoursWrapLst.get(intrvwr.Id)).clone();
                temproundIntrvwr.interviewer = intrvwr;
                temproundIntrvwr.interviewerName = intrvwr.Employee__r.Name;
                temproundIntrvwr.intervwrId = intrvwrId;
                system.debug('hourwrap '+temphrwraplst);
                temproundIntrvwr.hrwraplst = temphrwraplst;
                string sngldt = selectdt.format();
                temproundIntrvwr.wekdatee = sngldt;
                temproundIntrvwr.wkdat = Date.parse(sngldt);
                temproundIntervwrslst.add(temproundIntrvwr);
            }
            irw.intrvwRndInterviewrsWrpLst = temproundIntervwrslst;
            tempintrvwRoundWrapLst.add(irw);
        } 
        
        fsdywrp.intrvwRoundWrapLst = tempintrvwRoundWrapLst;
        return fsdywrp;
    }
    
    public static Time getTimeFromReadableAmPMValue(string readableHour)
    {
        list<string> timestring = readableHour.split(' ');
        if(timestring[0].contains(':')){
            list<string> subtimestring = timestring[0].split(':');
            timestring[0] = subtimestring[0];
        }
        integer hourr = gethr(timestring[0].trim(),timestring[1].trim());
        Time slottime = Time.newInstance(hourr,0,0,0);
        return slottime;
    }
    
    public static integer gethr(string hr,string appmspecifier)
    {
        integer hrr = 0;
        if(appmspecifier == 'AM')
        {
            if(hr == '12')
            {
                return hrr;
            }
            hrr = integer.valueOf(hr);
            return hrr;
        }
        if(appmspecifier == 'PM')
        {
            if(hr == '1')
            {
                return 13;
            }
            if(hr == '2')
            {
                return 14;
            }
            if(hr == '3')
            {
                return 15;
            }
            if(hr == '4')
            {
                return 16;
            }
            if(hr == '5')
            {
                return 17;
            }
            if(hr == '6')
            {
                return 18;
            }
            if(hr == '7')
            {
                return 19;
            }
            if(hr == '8')
            {
                return 20;
            }
            if(hr == '9')
            {
                return 21;
            }
            if(hr == '10')
            {
                return 22;
            }
            if(hr == '11')
            {
                return 23;
            }
            if(hr == '12')
            {
                return 12;
            }
        }
        return null;
    }
    
    public static string gethringentimmings(integer num)
    {
        if(num < 12)
        {
            return string.valueOf(num)+' AM';
        }
        else if(num == 12)
        {
            return '12 PM';
        }
        else if(num == 13)
        {
            return '1 PM';
        }
        else if(num == 14)
        {
            return '2 PM';
        }
        else if(num == 15)
        {
            return '3 PM';
        }
        else if(num == 16)
        {
            return '4 PM';
        }
        else if(num == 17)
        {
            return '5 PM';
        }
        else if(num == 18)
        {
            return '6 PM';
        }
        else if(num == 19)
        {
            return '7 PM';
        }
        else if(num == 20)
        {
            return '8 PM';
        }
        else if(num == 21)
        {
            return '9 PM';
        }
        else if(num == 22)
        {
            return '10 PM';
        }
        else if(num == 23)
        {
            return '11 PM';
        }
        else if(num == 24)
        {
            return '12 AM';
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String,list<String>> getneededPickListVals()
    {
    	Map<String,list<String>> pickmap = new Map<String,list<String>>();
        pickmap.put('appStatuses',getAppststypvls());
        pickmap.put('decision',getpickvls('Interview__c','Decision__c',''));
        pickmap.put('interview',getpickvls('Interview__c','Status__c',''));
        return pickmap; 
    }
    
    @AuraEnabled
    public static list<string> getAppststypvls()
    {
        return StatusestoshowApplications;
    }
    
    public static List<string> getpickvls(String objName,String fldname,String filternme)
    {
        Schema.DescribeFieldResult stagesFR = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fldname).getDescribe();
        List<Schema.PicklistEntry> stagesPle = stagesFR.getPicklistValues();
        list<string> valuesList = new list<string>();
        for( Schema.PicklistEntry s : stagesPle){
            if(String.isNotEmpty(filternme)){
                if(s.getValue().containsIgnoreCase(filternme)){
                	valuesList.add(s.getValue());    
                }
            } else {
            	valuesList.add(s.getValue());    
            }
        } 
        return valuesList;
    }
    
    
    @AuraEnabled
    public static void getIntrvwDeleted(string intrvwId)
    {
        Interview__c intrvw = [select id,name from Interview__c where id=: intrvwId];
        delete intrvw;
    }
    
    @AuraEnabled
    public static void getIntrvwStsUpdated(string intrvwId,string selctdsts)
    {
        Interview__c intrvw = [select id,name,Status__c from Interview__c where id=: intrvwId];
        intrvw.Status__c = selctdsts;
        update intrvw;
    }
    
    @AuraEnabled
    public static void getIntrvwFeedbackUpdated(string intrvwId,string seldecsn,string feedbck)
    {
        Interview__c intrvw = [select id,name,Decision__c,Status__c,Application__c,Feedback__c from Interview__c where id=: intrvwId];
        intrvw.Decision__c = seldecsn;
        intrvw.Feedback__c = feedbck;
        intrvw.Status__c = 'Completed';
        update intrvw;
        if(rejectionDecisionVals.contains(seldecsn)){
            Application__c app = new Application__c();
            app.Status__c = 'Rejected';
            app.Id = intrvw.Application__c;
            update app;    
        }
    }
    
    @AuraEnabled
    public static void getInterviewupdated(string datee,string intrvWrpStr,string drpstrthr,string intervrId)
    {
        intrvwWrap intvWrp = new intrvwWrap();
        intvWrp = (intrvwWrap)System.JSON.deserialize(intrvWrpStr,intrvwWrap.class);
        Interview__c intv = intvWrp.intrvw;
        integer srhr = integer.valueOf(drpstrthr);
        Time strttime = Time.newInstance(srhr,0,0,0);
        list<string> dtlst = datee.split('/');
        date schdate = date.newInstance(integer.valueOf(dtlst[2]),integer.valueOf(dtlst[0]), integer.valueOf(dtlst[1]));
        date strtdate = schdate;
        date enddate = schdate;
        integer totalstrthrduration = srhr+intvWrp.hourrdurationn;
        integer endhr = totalstrthrduration;
        if(totalstrthrduration >= 24)
        {
            enddate = schdate.addDays(1);
            integer temp = totalstrthrduration - 24;
            endhr = temp;
        }
        String starttimestr = gethringentimmings(srhr);
        String endtimestr = gethringentimmings(endhr);
        if(!starttimestr.contains(':')){
        	List<String> strlst = starttimestr.split(' ');
            strlst[0] = strlst[0]+':00';
            starttimestr = strlst[0]+' '+strlst[1];
        }
        if(!endtimestr.contains(':')){
            List<String> strlst = endtimestr.split(' ');
            strlst[0] = strlst[0]+':00';
            endtimestr = strlst[0]+' '+strlst[1];
        }
        intv.Start_Time__c = starttimestr;
        intv.End_Time__c = endtimestr;
        Time endtime = Time.newInstance(endhr,0,0,0);
        DateTime schdlustrttime = DateTime.newInstance(strtdate, strttime);
        DateTime schdlendtime = DateTime.newInstance(enddate, endtime);
        intv.Scheduled_Start_Time__c = schdlustrttime;
        intv.Scheduled_End_Time__c = schdlendtime;
        intv.Interviewer__c = intervrId;
        update intv;
    }
    
    @AuraEnabled
    public static string getInterviewSlotverified(string datee,string drpstrthr,string intrvwrid,string
                                            duratt,Interview__c intrvw)
    {
        try
        {
            list<string> dtlst = datee.split('/');
            date schdate = date.newInstance(integer.valueOf(dtlst[2]),integer.valueOf(dtlst[0]), integer.valueOf(dtlst[1]));
            integer srhr = integer.valueOf(drpstrthr);
            Time strttime = Time.newInstance(srhr,0,0,0);
            date tempdate = schdate;
            date strtdate = tempdate;
            date enddate = tempdate;
            integer totalstrthrduration = srhr+integer.valueOf(duratt);
            integer endhr = totalstrthrduration;
            if(totalstrthrduration >= 24)
            {
                enddate = tempdate.addDays(1);
                integer temp = totalstrthrduration - 24;
                endhr = temp;
            }
            Time endtime = Time.newInstance(endhr,0,0,0);
            DateTime schdlustrttime = DateTime.newInstance(strtdate, strttime);
            DateTime schdlendtime = DateTime.newInstance(enddate, endtime);
            if([select count() from Interview__c where Interviewer__c =: intrvwrid AND
                	((Scheduled_Start_Time__c >=: schdlustrttime and Scheduled_Start_Time__c <:
                      schdlendtime) or (Scheduled_End_Time__c >: schdlustrttime and Scheduled_End_Time__c <=: schdlendtime) or
                     (Scheduled_Start_Time__c <: schdlustrttime and Scheduled_End_Time__c >: schdlendtime) or
                     (Scheduled_Start_Time__c >: schdlustrttime and Scheduled_End_Time__c <: schdlendtime))] > 0)
            {
                Interview__c intervw = new Interview__c();
                intervw = [select id from Interview__c where Interviewer__c =: intrvwrid AND
                           ((Scheduled_Start_Time__c >=: schdlustrttime and Scheduled_Start_Time__c <:
                             schdlendtime) or (Scheduled_End_Time__c >: schdlustrttime and Scheduled_End_Time__c <=: schdlendtime) or
                            (Scheduled_Start_Time__c <: schdlustrttime and Scheduled_End_Time__c >: schdlendtime) or
                            (Scheduled_Start_Time__c >: schdlustrttime and Scheduled_End_Time__c <: schdlendtime)) limit 1];
                return intervw.Id;
            }
            else
            {
                return 'notfound';
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getTypeName()+'$$$$$$'+e.getMessage()+'$$$$$$'+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static intrvwWrap getnewInterviewSent(string datee,string drpstrthr,string intrvwrid,string duratt,
                                                 Interview__c intrvw,String navigatedFrom,String appOrJobOrHiringEvntId)
    {
        if(navigatedFrom.equalsIgnoreCase('hiringevent')){
        	intrvw.Hiring_Event__c = appOrJobOrHiringEvntId;   
        }
        list<string> dtlst = datee.split('/');
        date schdate = date.newInstance(integer.valueOf(dtlst[2]),integer.valueOf(dtlst[0]), integer.valueOf(dtlst[1]));
        integer srhr = integer.valueOf(drpstrthr);
        Time strttime = Time.newInstance(srhr,0,0,0);
        date tempdate = schdate;
        date strtdate = tempdate;
        date enddate = tempdate;
        integer totalstrthrduration = srhr+integer.valueOf(duratt);
        integer endhr = totalstrthrduration;
        if(totalstrthrduration >= 24)
        {
            enddate = tempdate.addDays(1);
            integer temp = totalstrthrduration - 24;
            endhr = temp;
        }
        Time endtime = Time.newInstance(endhr,0,0,0);
        DateTime schdlustrttime = DateTime.newInstance(strtdate, strttime);
        DateTime schdlendtime = DateTime.newInstance(enddate, endtime);
        intrvwWrap intrvwWrp = new intrvwWrap();
        date dteee = system.today();
        string formtdt = schdate.format();
        intrvw.Interview_Date__c = schdate;
        intrvw.Status__c = 'Invite Sent';
        String starttimestr = gethringentimmings(srhr);
        String endtimestr = gethringentimmings(endhr);
        if(!starttimestr.contains(':')){
        	List<String> strlst = starttimestr.split(' ');
            strlst[0] = strlst[0]+':00';
            starttimestr = strlst[0]+' '+strlst[1];
        }
        if(!endtimestr.contains(':')){
            List<String> strlst = endtimestr.split(' ');
            strlst[0] = strlst[0]+':00';
            endtimestr = strlst[0]+' '+strlst[1];
        }
        intrvw.Start_Time__c = starttimestr;
        intrvw.End_Time__c = endtimestr;
        intrvw.Scheduled_Start_Time__c = schdlustrttime;
        intrvw.Scheduled_End_Time__c = schdlendtime;
        intrvw.Interviewer__c = intrvwrid;
        Application__c app = getApplication(intrvw.Application__c);
        intrvw.name = app.Name+' - '+app.Job__r.Name;
        upsert intrvw;
        app.Status__c = intrvScheduledAppStatus;
        update app;
        Interview__c interview = getInterview(intrvw.Id);
        intrvwWrp.intrvw = interview;
        intrvwWrp.intrvDtStrng = datee;
        intrvwWrp.hourrdurationn = integer.valueOf(duratt);
        return intrvwWrp;
    }
    public static Application__c getApplication(string applctnId)
    {
        Application__c app = [Select id,name,Status__c,Job__r.Name,Job__r.Hiring_Manger__c from Application__c where id =: applctnId];
        return app;
    }
    
    public static Job__c  getJobInfo(string jobId){
        Job__c job = [Select id,Name,Hiring_Manger__c from Job__c where id =: jobId];
        return job; 
    }
    
    public static Interview__c getInterview(string intvwId)
    {
        Interview__c intrvw = new Interview__c();
        intrvw = [select id,Name,Application__c,Application__r.Name,Application__r.Job__r.Name,Interviewer__c,Interviewer__r.Name,Status__c,
                  Round_Name__c,Start_Time__c,End_Time__c,Scheduled_Start_Time__c,Scheduled_End_Time__c,Interview_Date__c,Interview_Type__c 
                  from Interview__c where id =: intvwId];
        return intrvw;
    }
    
    public class fsldaywrap{
        @AuraEnabled public Boolean isLastInterviewerSet{set;get;}
        @AuraEnabled public list<interviewRoundWrap> intrvwRoundWrapLst{set;get;}
        @AuraEnabled public date presentdatee{set;get;}
        @AuraEnabled public string weekdayy{set;get;}
        @AuraEnabled public string dsplyhdng{set;get;}
        @AuraEnabled public list<string> tmlblslst{set;get;}
        public fsldaywrap()
        {
            intrvwRoundWrapLst = new list<interviewRoundWrap>();
            tmlblslst = new list<string>();
            isLastInterviewerSet = false;
        }
    }
    public class interviewRoundWrap{
        @AuraEnabled public list<intrvwRoundInterviewersWrap> intrvwRndInterviewrsWrpLst{set;get;}
        @AuraEnabled public String roundName{set;get;}
        @AuraEnabled public boolean showRoundInterviewrs{set;get;}
        public interviewRoundWrap()
        {
            intrvwRndInterviewrsWrpLst = new list<intrvwRoundInterviewersWrap>();
            roundName = '';
            showRoundInterviewrs = true;
        }
    }
    public class intrvwRoundInterviewersWrap{
        @AuraEnabled public list<hourwrap> hrwraplst{set;get;}
        @AuraEnabled public Interviewer__c interviewer{set;get;}
        @AuraEnabled public String interviewerName{set;get;}
        @AuraEnabled public String intervwrId{set;get;}
        @AuraEnabled public string wekdatee{set;get;}
        @AuraEnabled public date wkdat{set;get;}
        public intrvwRoundInterviewersWrap()
        {
            hrwraplst = new list<hourwrap>();
            interviewer = new Interviewer__c();
        }
    }
    public class hourwrap{
        @AuraEnabled public time starttime{set;get;}
        @AuraEnabled public time endtime{set;get;}
        @AuraEnabled public boolean isoperatinghour{set;get;}
        @AuraEnabled public integer strthr{set;get;}
        @AuraEnabled public boolean isInterviwerAvailableSlot{set;get;}
        @AuraEnabled public integer maxavillength{set;get;}
        @AuraEnabled public list<intrvwWrap> interviewLst{set;get;}
        @AuraEnabled public list<intrvwWrap> interviewScheduledstartthishour{set;get;}
        @AuraEnabled public String readableStarttm{set;get;}
        @AuraEnabled public String readableEndtm{set;get;}    
        public hourwrap()
        {
            interviewLst =new list<intrvwWrap>();
            interviewScheduledstartthishour = new list<intrvwWrap>();
            isoperatinghour = false;
            isInterviwerAvailableSlot = false;
        }
    }
    public class intrvwWrap{
        @AuraEnabled public Interview__c intrvw{set;get;}
        @AuraEnabled public boolean showIntrvw{set;get;}
        @AuraEnabled public boolean isReschedulable{set;get;}
        @AuraEnabled public string intrvDtStrng{set;get;}
        @AuraEnabled public integer hourrdurationn{set;get;}
        @AuraEnabled public integer mindurationn{set;get;}
        public intrvwWrap()
        {
            intrvw = new Interview__c();
            showIntrvw = true;
            isReschedulable = true;
        }
    }
    
    public class jobWrap{
        @AuraEnabled public list<Application__c> appList{set;get;}
        @AuraEnabled public boolean showapps{set;get;}
        @AuraEnabled public Job__c jobb{set;get;}
        
        public jobWrap()
        {
            appList = new list<Application__c>();
            jobb = new Job__c();
            showapps = true;
        }
    }
    
    
}