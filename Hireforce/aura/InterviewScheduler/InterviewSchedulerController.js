({
    doInit : function(component, event, helper) {
        component.set("v.navFrom", "tab");
        var myPageRef = component.get("v.pageReference");
        if (myPageRef) {
            var attrValue = myPageRef.state.c__objNameAndObjId;
            if(attrValue != null && attrValue != undefined && attrValue.includes("@@")){
                const attrArray = attrValue.split("@@");
                component.set("v.receivedValue", attrValue);
                if(attrValue.includes("Hiring_Event__c")){
                    component.set("v.navFrom", "hiringevent");	    
                } else if(attrValue.includes("Job__c")){
                    component.set("v.navFrom", "job");
                    component.set("v.showapplicationJobfilter ",false);
                } else if(attrValue.includes("Application__c")){
                    component.set("v.navFrom", "application");
                    component.set("v.showapplicationfilters",false);
                } else if(attrValue.includes("Interviewer__c")){
                    component.set("v.navFrom", "Interviewer");
                    component.set("v.showapplicationpanell",false);
                    component.set("v.hideapppanelInterviwer",true);
                }
                component.set("v.appOrJobOrHrEvtId", attrArray[1]);
        	}
        }
        window.setTimeout(
            $A.getCallback(function() {
                var filrIntrvDiv = component.find('filterIntrvDiv');
                if(component.get("v.navFrom") != "hiringevent"){
                    $A.util.addClass(filrIntrvDiv, 'marginLeftClass');
                }
                var elmnt = document.getElementById("mnoutdiv");
                var hgt = elmnt.offsetHeight;
                component.set("v.tdheight",parseInt(hgt)-parseInt(20));
                component.set("v.tddivheight",parseInt(hgt)-parseInt(40));
                component.set("v.applicationsdivhght",parseInt(hgt)-parseInt(340));
                if(component.get("v.navFrom") == "application"){
                	component.set("v.applicationsdivhght",parseInt(hgt)-parseInt(130));    
                } else if(component.get("v.navFrom") == "job"){
                    component.set("v.applicationsdivhght",parseInt(hgt)-parseInt(280));
                }
                component.set("v.schdlrheight",parseInt(hgt)-parseInt(240));
            }), 5000
        );
        var hrslst = new Array('12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM','12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM');
        
        var actionstspicks = component.get("c.getneededPickListVals");
        actionstspicks.setCallback(this, function(actionResult1){
            var state = actionResult1.getState();
            if (state === "SUCCESS")
            {
                var res = actionResult1.getReturnValue();
                component.set("v.intrvstatusvals",res.interview);
                component.set("v.decisionvals",res.decision);
                component.set("v.selectedapplicationSts",res.appStatuses[0]);
                component.set("v.allapplicationStatuses",res.appStatuses);
            }
        });
        $A.enqueueAction(actionstspicks);
        
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
      	helper.getmatchintrvs(component,event,false);
        component.set("v.dailyhourslst",hrslst);
        var today = new Date();
        window.setTimeout(
            $A.getCallback(function() {
                helper.callApexMethod(component,event,today,'current');
            }), 1000
        );
    },
    
    showeditordelorfeedbackopt : function(component, event, helper) {
        var reqnm = event.target.title;
        component.set("v.stsorfeedback",reqnm);
        if(reqnm == 'Change Status' || reqnm == 'Add Feedback')
        {
            component.set("v.selectdstatuss",component.get("v.infintervieww.Status__c"));
            var editorfdbckoptdivcmp = component.find('editorfeedbackdivv');
            $A.util.removeClass(editorfdbckoptdivcmp, 'editstatusoraddfeedbackdiv');
            $A.util.addClass(editorfdbckoptdivcmp, 'showeditstatusoraddfeedbackdiv');
        }
        if(reqnm == 'Delete')
        {
            var action = component.get("c.getIntrvwDeleted");
            action.setParams({
                intrvwId : component.get("v.infintervieww.Id"),
            });
            action.setCallback(this, function(actionResult){
                var state = actionResult.getState();
                if (state === "SUCCESS")
                {
                    component.set("v.showprocessing",true);
                    helper.hideoptionsdiv(component, event);
                    helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
                }
            });
            $A.enqueueAction(action);
        }
        if(reqnm == 'View')
        {
            window.open('/lightning/r/Interview__c/' + component.get("v.infintervieww.Id")+'/view');
            helper.hideoptionsdiv(component, event);
        }
    },
    showstatusdeleteaddfeedback : function(component, event, helper) {
        component.set("v.showinformationdiv",false);
        var pxx = event.getParam("mousepostx");
        var pyy = event.getParam("mouseposty");
        component.set("v.mousssspx",pxx);
        component.set("v.moussspy",pyy-110);
        component.set("v.mousssspxstsfdbk",pxx+110);
        component.set("v.moussspystsfdbk",pyy-95);
        var editorfdbckoptdivcmp = component.find('editorfeedbackdivv');
        $A.util.removeClass(editorfdbckoptdivcmp, 'showeditstatusoraddfeedbackdiv');
        $A.util.addClass(editorfdbckoptdivcmp, 'editstatusoraddfeedbackdiv');
        var optdivcmp = component.find('optionsdivvvv');
        $A.util.removeClass(optdivcmp, 'rightclickdiv');
        $A.util.addClass(optdivcmp, 'showrightclickdiv');
    },
    hideeeditordelorfeedbackopt : function(component, event, helper) {
        var editorfdbckoptdivcmp = component.find('editorfeedbackdivv');
        $A.util.removeClass(editorfdbckoptdivcmp, 'showeditstatusoraddfeedbackdiv');
        $A.util.addClass(editorfdbckoptdivcmp, 'editstatusoraddfeedbackdiv');
    },
    hideoptionsssdivv : function(component, event, helper) {
        helper.hideoptionsdiv(component, event);
    },
    getstsupdatedd : function(component, event, helper) {
        var action = component.get("c.getIntrvwStsUpdated");
        action.setParams({
            intrvwId : component.get("v.infintervieww.Id"),
            selctdsts : component.get("v.selectdstatuss"),
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set("v.showprocessing",true);
                helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
                helper.hideoptionsdiv(component, event);
                var editorfdbckoptdivcmp = component.find('editorfeedbackdivv');
                $A.util.removeClass(editorfdbckoptdivcmp, 'showeditstatusoraddfeedbackdiv');
                $A.util.addClass(editorfdbckoptdivcmp, 'editstatusoraddfeedbackdiv');
            }
        });
        $A.enqueueAction(action);
    },
    getfdbckadded : function(component, event, helper) {
        if($A.util.isEmpty(component.get("v.fdbckkkk")) || $A.util.isUndefined(component.get("v.fdbckkkk")))
        {
            alert('Please enter Feedback.');
            return;
        }
        if($A.util.isEmpty(component.get("v.selectddecision")) || $A.util.isUndefined(component.get("v.selectddecision")) || component.get("v.selectddecision") == 'None')
        {
            alert('Please provide your decision.');
            return;
        }
        var action = component.get("c.getIntrvwFeedbackUpdated");
        action.setParams({
            intrvwId : component.get("v.infintervieww.Id"),
            seldecsn : component.get("v.selectddecision"),
            feedbck : component.get("v.fdbckkkk"),
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set("v.showprocessing",true);
                helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
                helper.hideoptionsdiv(component, event);
                var editorfdbckoptdivcmp = component.find('editorfeedbackdivv');
                $A.util.removeClass(editorfdbckoptdivcmp, 'showeditstatusoraddfeedbackdiv');
                $A.util.addClass(editorfdbckoptdivcmp, 'editstatusoraddfeedbackdiv');
                component.set("v.fdbckkkk",null);
                component.set("v.selectddecision",null);
            }
        });
        $A.enqueueAction(action);
    },
    
    getmatchapplicationsss : function(component, event, helper) {
        event.getSource().set("v.label","Fetching...");
       	helper.getmatchintrvs(component,event,true);
    },
    
    hideorshowapplicationsection : function(component, event, helper) {
        if(component.get("v.showapplicationpanell") == true)
        {
            component.set("v.showapplicationpanell",false);
        }
        else
        {
            component.set("v.showapplicationpanell",true);
        }
        component.set("v.showprocessing",true);
        helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
    },
    getschdatesintrvs : function(component, event, helper) {
        component.set("v.interviwerPageNum",1);
        component.set("v.showprocessing",true);
        helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
    },
    filterVieww : function(component, event, helper) {
        component.set("v.interviwerPageNum",1);
        component.set("v.showprocessing",true);
        helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
    },
    refrreshVieww : function(component, event, helper) {
        component.set("v.showprocessing",true);
        helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'current');
    },
    fetchnextdayintervws : function(component, event, helper) {
        component.set("v.showprocessing",true)
        helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'next');
    },
    fetchpreviousdayintervws : function(component, event, helper) {
        component.set("v.showprocessing",true)
        helper.nextandprev(component,event,component.get("v.selecteddtfrmpickr"),'previous');
    },
    showroundinterviewers : function(component, event, helper) {
        var reqnm = event.target.title;
        var fsdywrap = component.get("v.fsldaywrapp");
        var roundwrplst = fsdywrap.intrvwRoundWrapLst;
        for(var j=0;j<roundwrplst.length;j++)
        {
            if(roundwrplst[j].roundName == reqnm)
            {
                if(roundwrplst[j].showRoundInterviewrs == true)
                {
                    roundwrplst[j].showRoundInterviewrs = false;
                }
                else
                {
                    roundwrplst[j].showRoundInterviewrs = true;
                }
            }
        }
        component.set("v.fsldaywrapp",fsdywrap);
    },
    showapplst : function(component, event, helper) {
        var jobidd = event.target.title;
        var jlist = component.get("v.jobWrplsitt");
        for(var j=0;j<jlist.length;j++)
        {
            if(jlist[j].jobb.Id == jobidd)
            {
                if(jlist[j].showapps == true)
                {
                    jlist[j].showapps = false;
                }
                else
                {
                    jlist[j].showapps = true;
                }
            }
        }
        component.set("v.jobWrplsitt",jlist);
    },
    showroundinterviewersonclick : function(component, event, helper) {
        var reqnme = event.getSource().get("v.value");
        var fsdywrap = component.get("v.fsldaywrapp");
        var roundwrplst = fsdywrap.intrvwRoundWrapLst;
        for(var j=0;j<roundwrplst.length;j++)
        {
            if(roundwrplst[j].roundName == reqnme)
            {
                if(roundwrplst[j].showRoundInterviewrs == true)
                {
                    roundwrplst[j].showRoundInterviewrs = false;
                }
                else
                {
                    roundwrplst[j].showRoundInterviewrs = true;
                }
            }
        }
        component.set("v.fsldaywrapp",fsdywrap);
    },
    handleshoworhidediveevent : function(component, event, helper) {
        var selectedInterviewGetFromEvent = event.getParam("recordByEvent");
        var mul = event.getParam("multiusestringg");
        if(mul == 'showinf')
        {
            var pxx = event.getParam("mousepostx");
            var pyy = event.getParam("mouseposty");
            component.set("v.mousssspx",pxx);
            component.set("v.moussspy",pyy-100);
            component.set("v.infintervieww",selectedInterviewGetFromEvent);
            component.set("v.showinformationdiv",true);
        }
        if(mul == 'hideinf')
        {
            component.set("v.showinformationdiv",false);
        }
    },
    handledrageventfromintervwcomp : function(component, event, helper) {
        var selectedInterviewGetFromEvent = event.getParam("recordByEvent");
        var intervwridd = event.getParam("interviewerId");
        var intrvdragstrthr = event.getParam("interviewDraggedStrthr");
        var intrvdtstr = event.getParam("intrvwdate");
        component.set("v.tempintervvwrp",selectedInterviewGetFromEvent);
        component.set("v.intervwdraggedintervwrid",intervwridd);
        component.set("v.intervwdraggedstrthouur",intrvdragstrthr);
        component.set("v.intervwdraggeddt",intrvdtstr);
        component.set("v.isapplicationdragevent",false);
        component.set("v.showinformationdiv",false);
    },
    handledropeventfromhourcomp : function(component, event, helper) {
        var roundnameee = event.getParam("interviewRoundName");
        var intrverridddd = event.getParam("interviewerId");
        var strhr = event.getParam("interviewDroppedStrthr");
        var avlduration = event.getParam("availdurr");
        var drpddatestng = event.getParam("intrvwdate");
        var hrcomppnt = component.find("hrcompp");
        var intervduration = component.get("v.tempintervvwrp.hourrdurationn");
        var dragstrthr = component.get("v.intervwdraggedstrthouur");
        var dragintrvwrid = component.get("v.intervwdraggedintervwrid");
        if(component.get("v.isapplicationdragevent") == false)
        {
            if(component.get("v.tempintervvwrp.intrvw.Round_Name__c") == roundnameee)
            {
                component.set("v.showprocessing",true);
                var action = component.get("c.getInterviewSlotverified");
                action.setParams({
                    intrvw : JSON.stringify(component.get("v.tempintervvwrp.intrvw")),
                    drpstrthr : JSON.stringify(strhr),
                    intrvwrid : intrverridddd,
                    duratt : intervduration,
                    datee : drpddatestng,
                });
                action.setCallback(this, function(actionResult){
                    var state = actionResult.getState();
                    if (state === "SUCCESS")
                    {
                        var res = actionResult.getReturnValue();
                        if(res == 'notfound')
                        {
                            helper.updtintrvv(component, event,roundnameee,intrverridddd,strhr,avlduration,drpddatestng);
                        }
                        else
                        {
                            component.set("v.showprocessing",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Warning!",
                                "message": "This time slot of Interviewer is already booked.",
                                "mode": "dismissible",
                                "type": "warning",
                                "duration": "8000ms",
                            });
                            toastEvent.fire();
                            return;
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            if(component.get("v.tempintervvwrp.intrvw.Round_Name__c") != roundnameee)
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "message": "This interviewer's skill set does not match the requirements for this interview round.",
                    "mode": "dismissible",
                    "type": "warning",
                    "duration": "8000ms",
                });
                toastEvent.fire();
                return;
            }
        }
        else
        {
            var durhrlst = new Array();
            durhrlst.push(JSON.stringify(1));
            component.set("v.tempDroppedRoundName",roundnameee);
            component.set("v.hrdurationlist",durhrlst);
            component.set("v.applicationdropedintrvwrid",intrverridddd);
            component.set("v.applicationdropedstrthr",strhr);
            component.set("v.tempapplicationdrpeddatestrng",drpddatestng);
            component.set("v.tempinterviewerName",event.getParam("interviewerName"));
            component.set("v.tempdropStartTime",event.getParam("dropStartTime"));
            component.set("v.tempdropEndTime",event.getParam("dropEndTime"));
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('Modalbackdrop');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }
    },
    savenewintervieww : function(component,event,helper){
        component.set("v.showprocessing",true);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        var action = component.get("c.getInterviewSlotverified");
        action.setParams({
            datee : component.get("v.tempapplicationdrpeddatestrng"),
            drpstrthr : JSON.stringify(component.get("v.applicationdropedstrthr")),
            intrvwrid : component.get("v.applicationdropedintrvwrid"),
            duratt : component.get("v.selectedduratt"),
            intrvw : component.get("v.tempdragintrv"),
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                var res = actionResult.getReturnValue();
                if(res == 'notfound')
                {
                    helper.saveintervvvv(component, event);
                }
                else
                {
                    component.set("v.showprocessing",false);
                    component.set("v.selectedduratt",'1');
                    component.set("v.hrdurationlist",[]);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": "This time slot of Interviewer is already booked.",
                        "mode": "dismissible",
                        "type": "warning",
                        "duration": "8000ms",
                    });
                    toastEvent.fire();
                    return;
                }
            }
            else
            {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    closeModal:function(component,event,helper){
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.selectedduratt",'1');
        component.set("v.hrdurationlist",[]);
    },
    handleapplicationdragevent : function(component, event, helper) {
        var selectedInterviewGetFromEvent = event.getParam("recordByEvent");
        component.set("v.isapplicationdragevent",true);
        component.set("v.tempdragintrv",selectedInterviewGetFromEvent);
    },
})