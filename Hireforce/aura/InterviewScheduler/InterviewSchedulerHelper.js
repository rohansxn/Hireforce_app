({
    callApexMethod : function(component,event,today,dayspecifier) {
        var monthDigit = today.getMonth() + 1;
        var action = component.get("c.getFslDaywrap");
        action.setParams({
            yr : JSON.stringify(today.getFullYear()),
            mnth : JSON.stringify(monthDigit),
            day : JSON.stringify(today.getDate()),
            currentornextorprevspecifier : dayspecifier,
            navigatedFrom : component.get("v.navFrom"),
            appOrJobOrHiringEvntId : component.get("v.appOrJobOrHrEvtId"),
            pagNum : JSON.stringify(component.get("v.interviwerPageNum")),
            roundOrHiringMngrName : component.get("v.searchByroundOrHiringMngrName")
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set("v.fsldaywrapp", actionResult.getReturnValue());
                var res = actionResult.getReturnValue();
                component.set("v.selecteddtfrmpickr",res.presentdatee);
                component.set("v.intrvdte",res.presentdatee);
                component.set("v.isLastIntervwrSet",res.isLastInterviewerSet);
                this.monthandDaysetter(component,event,res.presentdatee,res.weekdayy);
            }
        });
        $A.enqueueAction(action);
    },
    nextandprev : function(component,event,reqdate,dayspecifier) {
        if(dayspecifier == "next"){
        	component.set("v.interviwerPageNum",component.get("v.interviwerPageNum")+1);    
        }
        if(dayspecifier == "previous"){
            component.set("v.interviwerPageNum",component.get("v.interviwerPageNum")-1);
        }
        var action = component.get("c.getFslDaywrap");
        action.setParams({
            yr : reqdate.split('-')[0],
            mnth : reqdate.split('-')[1],
            day : reqdate.split('-')[2],
            currentornextorprevspecifier : 'current',
            navigatedFrom : component.get("v.navFrom"),
            appOrJobOrHiringEvntId : component.get("v.appOrJobOrHrEvtId"),
            pagNum : JSON.stringify(component.get("v.interviwerPageNum")),
            roundOrHiringMngrName : component.get("v.searchByroundOrHiringMngrName")
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set("v.fsldaywrapp", actionResult.getReturnValue());
                var res = actionResult.getReturnValue();
                component.set("v.selecteddtfrmpickr",res.presentdatee);
                component.set("v.isLastIntervwrSet",res.isLastInterviewerSet);
                this.monthandDaysetter(component,event,res.presentdatee,res.weekdayy);
            }
        });
        $A.enqueueAction(action);
    },
    monthandDaysetter : function(component,event,reqdate,wkday) {
        var mnthval = reqdate.split('-')[1];
        var monthDigit = parseInt(mnthval);
        var dayyy = parseInt(reqdate.split('-')[2]);
        component.set("v.yearr",reqdate.split('-')[0]);
        component.set("v.dayy",JSON.stringify(dayyy));
        if(monthDigit == 1)
        {
            component.set("v.monthname",'January');
        }
        else if(monthDigit == 2)
        {
            component.set("v.monthname",'February');
        }
            else if(monthDigit == 3)
            {
                component.set("v.monthname",'March');
            }
                else if(monthDigit == 4)
                {
                    component.set("v.monthname",'April');
                }
                    else if(monthDigit == 5)
                    {
                        component.set("v.monthname",'May');
                    }
                        else if(monthDigit == 6)
                        {
                            component.set("v.monthname",'June');
                        }
                            else if(monthDigit == 7)
                            {
                                component.set("v.monthname",'July');
                            }
                                else if(monthDigit == 8)
                                {
                                    component.set("v.monthname",'August');
                                }
                                    else if(monthDigit == 9)
                                    {
                                        component.set("v.monthname",'September');
                                    }
                                        else if(monthDigit == 10)
                                        {
                                            component.set("v.monthname",'October');
                                        }
                                            else if(monthDigit == 11)
                                            {
                                                component.set("v.monthname",'November');
                                            }
                                                else
                                                {
                                                    component.set("v.monthname",'December');
                                                }
        var n = wkday;
        if(n == 'Monday')
        {
            component.set("v.weekdayname",'Mon');
        }
        else if(n == 'Tuesday')
        {
            component.set("v.weekdayname",'Tue');
        }
            else if(n == 'Wednesday')
            {
                component.set("v.weekdayname",'Wed');
            }
                else if(n == 'Thursday')
                {
                    component.set("v.weekdayname",'Thu');
                }
                    else if(n == 'Friday')
                    {
                        component.set("v.weekdayname",'Fri');
                    }
                        else if(n == 'Saturday')
                        {
                            component.set("v.weekdayname",'Sat');
                        }
                            else
                            {
                                component.set("v.weekdayname",'Sun');
                            }
        component.set("v.showprocessing",false);
        component.set("v.showloading",false);
        document.addEventListener('contextmenu', event => event.preventDefault());
    },
    hideoptionsdiv : function(component, event)
    {
        var optdivcmp = component.find('optionsdivvvv');
        $A.util.removeClass(optdivcmp, 'showrightclickdiv');
        $A.util.addClass(optdivcmp, 'rightclickdiv');
    },
    
    getmatchintrvs : function(component, event, showtoastt) {
        var action = component.get("c.getApplicantsList");
        action.setParams({serchtxt : component.get("v.searchtext"),
                          navigatedFrom : component.get("v.navFrom"),
                          appOrJobOrHiringEvntId : component.get("v.appOrJobOrHrEvtId"), 
                          status : component.get("v.selectedapplicationSts")
                         });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set("v.jobWrplsitt", actionResult.getReturnValue());
                if(showtoastt){
                    event.getSource().set("v.label","Fetch Applications");
                    if(component.get("v.jobWrplsitt").length == 0){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Info!",
                            "message": "No matching Job Applications found.",
                            "mode": "dismissible",
                            "type": "info",
                        });
                        toastEvent.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    saveintervvvv : function(component, event) {
        var jlist = component.get("v.jobWrplsitt");
        for(var i=0;i<jlist.length;i++)
        {
            var applicntlst = jlist[i].appList;
            for(var j=0;j<applicntlst.length;j++)
            {
                if(applicntlst[j].Id == component.get("v.tempdragintrv.Application__c"))
                {
                    applicntlst.splice(j, 1);
                }
            }
            jlist[i].appList = applicntlst;
            if(applicntlst.length == 0)
            {
            	jlist.splice(i, 1);    
            }
        }
        component.set("v.jobWrplsitt",jlist);
        component.set("v.tempdragintrv.Round_Name__c",component.get("v.tempDroppedRoundName"));
        var action = component.get("c.getnewInterviewSent");
        action.setParams({
            datee : component.get("v.tempapplicationdrpeddatestrng"),
            drpstrthr : JSON.stringify(component.get("v.applicationdropedstrthr")),
            intrvwrid : component.get("v.applicationdropedintrvwrid"),
            duratt : component.get("v.selectedduratt"),
            intrvw : component.get("v.tempdragintrv"),
            navigatedFrom : component.get("v.navFrom"),
            appOrJobOrHiringEvntId : component.get("v.appOrJobOrHrEvtId")
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                var res = actionResult.getReturnValue();
                var intrvvduration = res.hourrdurationn;
                var hrcomppnt = component.find("hrcompp");
                for(var j = 0;j<intrvvduration;j++)
                {
                    for(var i = 0;i < hrcomppnt.length;i++)
                    {
                        hrcomppnt[i].insertandSpliceInterview(res,component.get("v.tempDroppedRoundName"),component.get("v.applicationdropedintrvwrid"),component.get("v.applicationdropedstrthr")+j,j,"add",component.get("v.tempapplicationdrpeddatestrng"));
                    }
                }
                component.set("v.showprocessing",false);
                component.set("v.selectedduratt",'1');
                component.set("v.hrdurationlist",[]);
            }
            else
            {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    updtintrvv :function(component, event,roundnameee,intrverridddd,strhr,avlduration,drpddatestng) {
        var hrcomppnt = component.find("hrcompp");
        var intrvvduration = component.get("v.tempintervvwrp.hourrdurationn");
        var dragstrthr = component.get("v.intervwdraggedstrthouur");
        var dragintrvwrid = component.get("v.intervwdraggedintervwrid");
        for(var j = 0;j<intrvvduration;j++)
        {
            for(var i = 0;i < hrcomppnt.length;i++)
            {
                hrcomppnt[i].insertandSpliceInterview(component.get("v.tempintervvwrp"),roundnameee,intrverridddd,strhr+j,j,"add",drpddatestng);
                hrcomppnt[i].insertandSpliceInterview(component.get("v.tempintervvwrp"),'',dragintrvwrid,dragstrthr+j,j,"splice",component.get("v.intervwdraggeddt"));
            }
        }
        var action = component.get("c.getInterviewupdated");
        action.setParams({
            intrvWrpStr : JSON.stringify(component.get("v.tempintervvwrp")),
            drpstrthr : JSON.stringify(strhr),
            intervrId : intrverridddd,
            datee : drpddatestng,
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                component.set("v.showprocessing",false);
            }
        });
        $A.enqueueAction(action);
    },
})