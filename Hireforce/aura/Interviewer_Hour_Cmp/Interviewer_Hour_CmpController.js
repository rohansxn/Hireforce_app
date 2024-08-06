({
    doInit : function(component, event, helper) {
        if(component.get("v.hourrwrapp.isInterviwerAvailableSlot") == false && component.get("v.navFrom") == 'hiringevent'){
        	component.set("v.isUnavailablee",true);    
        }
        component.set("v.hrcompwidth",$('#test1').width());
        var hrwrp = component.get("v.hourrwrapp");
        var intervwlstt = hrwrp.interviewScheduledstartthishour;
        if(intervwlstt.length > 0)
        {
            var intervsrec = component.find("interviewcompp");
            if(intervwlstt.length == 1)
            {
                intervsrec.stylesetter();
            }
            else
            {
                for(var i=0;i<intervsrec.length;i++)
                {
                    intervsrec[i].stylesetter();
                }
            }
            //below code to hide intervew for same interviwer for diff round
            for(var j=0;j<intervwlstt.length;j++){
                if(intervwlstt[j].intrvw.Round_Name__c != component.get("v.roundName")){
                	intervwlstt[j].showIntrvw = false;    
                }    
            }
            hrwrp.interviewScheduledstartthishour = intervwlstt;
            component.set("v.hourrwrapp",hrwrp);
        }
        var intervlsttt = component.get("v.hourrwrapp.interviewLst");
        if(intervlsttt.length > 0)
        {
            var divcmp = component.find('hurcompp');
            $A.util.addClass(divcmp, 'pointerr');
        }
    },
    showInf : function(component, event, helper) {
        var intervlsttt = component.get("v.hourrwrapp.interviewLst");
        var interv;
        for(var i=0;i<intervlsttt.length;i++)
        {
            interv = intervlsttt[i].intrvw;
        }
        if(intervlsttt.length > 0)
        {
            var mx = event.clientX;
            var my = event.clientY;
            var compEvent = component.getEvent("showinterviewdetails");
            compEvent.setParams({"recordByEvent" : interv,
                                 "multiusestringg" : 'showinf',
                                 "mousepostx" : mx,
                                 "mouseposty" : my,
                                });
            compEvent.fire();
        }
    },
    showstatusdeleteaddfeedback : function(component, event, helper) {
        var intervlsttt = component.get("v.hourrwrapp.interviewLst");
        var interv;
        for(var i=0;i<intervlsttt.length;i++)
        {
            interv = intervlsttt[i].intrvw;
        }
        if(intervlsttt.length > 0)
        {
            var mx = event.clientX;
            var my = event.clientY;
            var shcompEvent = component.getEvent("showoptionlistt");
            shcompEvent.setParams({"recordByEvent" : interv, 
                                   "multiusestringg" : 'showoptionslst',
                                   "mousepostx" : mx,
                                   "mouseposty" : my,
                                  });
            shcompEvent.fire();
        }
    },
    hideInf : function(component, event, helper) {
        var compEvent = component.getEvent("showinterviewdetails");
        compEvent.setParams({"multiusestringg" : 'hideinf',
                            });
        compEvent.fire();
    },
    chngbolen : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var mul = params.multiuse;
            if(mul == 'acc')
            {
                component.set("v.isapplicationdragevent",true);
            }
            else
            {
                component.set("v.isapplicationdragevent",false);
            }
        }
    },
    onDrop : function(component, event, helper) {
        if(component.get("v.isUnavailablee")){
        	alert("Interviewer is unavailable at this time.");
            return;
        }
        var hrwrp = component.get("v.hourrwrapp");
        var intervwlstt = hrwrp.interviewLst;
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date
        if(dd < 10){
            dd = '0' + dd;
        }
        // if month is less then 10, then append 0 before date
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.clndrdateee") != '' && component.get("v.clndrdateee") < todayFormattedDate)
        {
            alert("You can't schedule an interview with date less than today.");
            return;
        }
        else
        {
            if(intervwlstt.length == 0)
            {
                event.preventDefault();
                var compEvent = component.getEvent("InterviewDropEvent");
                compEvent.setParams({"interviewRoundName" : component.get("v.roundName"),
                                     "interviewerId" : component.get("v.interviewerr.Id"),
                                     "interviewDroppedStrthr" : component.get("v.hourrwrapp.strthr"),
                                     "availdurr" : component.get("v.hourrwrapp.maxavillength"),
                                     "intrvwdate" : component.get("v.datestringg"),
                                     "interviewerName" : component.get("v.interviewerr.Name"),
                                     "dropStartTime" : component.get("v.hourrwrapp.readableStarttm"),
                                     "dropEndTime" : component.get("v.hourrwrapp.readableEndtm")
                                    });
                compEvent.fire();
            }
            else
            {
                alert("This time slot was scheduled, please select other timings.");
                return;
            }
        }
    },
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    doAction : function(component, event, helper) {
        var hrwrp = component.get("v.hourrwrapp");
        var intvrid = component.get("v.interviewerr.Id");
        var params = event.getParam('arguments');
        if (params) {
            var intervww = params.interrview;
            var rndNme = params.rounddName;
            var intrvwrrrrId = params.interviwerIdd;
            var strthhr = params.strthouur;
            var indx = params.indxnum;
            var act = params.actiontype;
            var dttstr = params.dtstrr;
            if(act == "add")
            {
                if(intvrid == intrvwrrrrId && component.get("v.datestringg") == dttstr && component.get("v.hourrwrapp.strthr") == strthhr)
                {
                    var processstyle = 1;
                    intervww.intrvDtStrng = dttstr;
                    var intervwlstt = hrwrp.interviewLst;
                    var intrvschdthidhrlst = hrwrp.interviewScheduledstartthishour;
                    intervwlstt.push(intervww);
                    hrwrp.interviewLst = intervwlstt;
                    var divcmp = component.find('hurcompp');
                    $A.util.addClass(divcmp, 'pointerr');
                    if(indx == 0)
                    {
                        if(rndNme != component.get("v.roundName")){
                            intervww.showIntrvw = false;
                            processstyle = 0;
                        }
                        intrvschdthidhrlst.push(intervww);
                        hrwrp.interviewScheduledstartthishour = intrvschdthidhrlst;    
                    }
                    component.set("v.hourrwrapp",hrwrp);
                    if(intrvschdthidhrlst.length > 0 && processstyle == 1)
                    {
                        var intervsrec = component.find("interviewcompp");
                        if(intrvschdthidhrlst.length == 1)
                        {
                            intervsrec.stylesetter();
                        }
                        else
                        {
                            for(var i=0;i<intervsrec.length;i++)
                            {
                                intervsrec[i].stylesetter();
                            }
                        }
                    }
                }
            }
            if(act == "splice")
            {
                if(intvrid == intrvwrrrrId && component.get("v.datestringg") == dttstr && component.get("v.hourrwrapp.strthr") == strthhr)
                {
                    var divcmp = component.find('hurcompp');
                    $A.util.removeClass(divcmp, 'pointerr');
                    var intervwlstt = hrwrp.interviewLst;
                    for(var i =0 ;i<intervwlstt.length;i++)
                    {
                        if(intervwlstt[i].Id == intervww.Id)
                        {
                            intervwlstt.splice(i, 1);
                        }
                    }
                    hrwrp.interviewLst = intervwlstt;
                    if(indx == 0)
                    {
                        var intrvschdthidhrlst = hrwrp.interviewScheduledstartthishour;
                        for(var j =0 ;j<intrvschdthidhrlst.length;j++)
                        {
                            if(intrvschdthidhrlst[j].Id == intervww.Id)
                            {
                                intrvschdthidhrlst.splice(j, 1);
                            }
                        }
                        hrwrp.interviewScheduledstartthishour = intrvschdthidhrlst;
                    }
                    component.set("v.hourrwrapp",hrwrp);
                }
            }
        }
    },
})