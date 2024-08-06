({
    onloadforInterviewRec : function(component, event, helper) {
        var divcmp = component.find('maindivv');
        var indiv = component.find('innerdivv');
        var intrvdiv = component.find('interviewdivv');
        var intduration = component.get("v.intervww.hourrdurationn");
        component.set("v.durattionn",intduration);
        if(component.get("v.intervww.intrvw.Status__c") == 'None' || component.get("v.intervww.intrvw.Status__c") == '' ||
           component.get("v.intervww.intrvw.Status__c") == null)
        {
            $A.util.addClass(intrvdiv, 'nonestatusstyl');
        }
        if(component.get("v.intervww.intrvw.Status__c") == 'Invite Sent')
        {
            $A.util.addClass(intrvdiv, 'schdlstatusstyl');
        }
        if(component.get("v.intervww.intrvw.Status__c") == 'Confirmed')
        {
            $A.util.addClass(intrvdiv, 'dispatchstatsstyl');
        }
        if(component.get("v.intervww.intrvw.Status__c") == 'No Show')
        {
            $A.util.addClass(intrvdiv, 'noshowstsstyl');
        }
        if(component.get("v.intervww.intrvw.Status__c") == 'In Progress')
        {
            $A.util.addClass(intrvdiv, 'inprogstsstyl');
        }
        if(component.get("v.intervww.intrvw.Status__c") == 'Completed')
        {
            $A.util.addClass(intrvdiv, 'completedstsstyl');
        }
        if(component.get("v.intervww.intrvw.Status__c") == 'Cancelled')
        {
            $A.util.addClass(intrvdiv, 'cancledstsstyl');
        }
        if(component.get("v.availlength") >= intduration)
        {
            var temp = component.get("v.hrcomppwidthh");
            component.set("v.intervwwwidth",(temp*intduration)+(intduration-1));
            if(intduration == 1)
            {
                $A.util.addClass(divcmp, 'divcss1');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 2)
            {
                $A.util.addClass(divcmp, 'divcss2');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 3)
            {
                $A.util.addClass(divcmp, 'divcss3');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 4)
            {
                $A.util.addClass(divcmp, 'divcss4');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 5)
            {
                $A.util.addClass(divcmp, 'divcss5');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 6)
            {
                $A.util.addClass(divcmp, 'divcss6');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 7)
            {
                $A.util.addClass(divcmp, 'divcss7');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 8)
            {
                $A.util.addClass(divcmp, 'divcss8');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 9)
            {
                $A.util.addClass(divcmp, 'divcss9');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 10)
            {
                $A.util.addClass(divcmp, 'divcss10');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 11)
            {
                $A.util.addClass(divcmp, 'divcss11');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 12)
            {
                $A.util.addClass(divcmp, 'divcss12');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 13)
            {
                $A.util.addClass(divcmp, 'divcss13');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 14)
            {
                $A.util.addClass(divcmp, 'divcss14');
                $A.util.addClass(indiv, 'innerstyldiv1');
            }
            if(intduration == 15)
            {
                $A.util.addClass(divcmp, 'divcss15');
            }
            if(intduration == 16)
            {
                $A.util.addClass(divcmp, 'divcss16');
            }
            if(intduration == 17)
            {
                $A.util.addClass(divcmp, 'divcss17');
            }
            if(intduration == 18)
            {
                $A.util.addClass(divcmp, 'divcss18');
            }
            if(intduration == 19)
            {
                $A.util.addClass(divcmp, 'divcss19');
            }
            if(intduration == 20)
            {
                $A.util.addClass(divcmp, 'divcss20');
            }
            if(intduration == 21)
            {
                $A.util.addClass(divcmp, 'divcss21');
            }
            if(intduration == 22)
            {
                $A.util.addClass(divcmp, 'divcss22');
            }
            if(intduration == 23)
            {
                $A.util.addClass(divcmp, 'divcss23');
            }
            if(intduration == 24)
            {
                $A.util.addClass(divcmp, 'divcss24');
            }
        }
        else
        {
            var temp = component.get("v.hrcomppwidthh");
            var durrrr = component.get("v.availlength");
            component.set("v.intervwwwidth",(temp*durrrr)+(durrrr-1));
            helper.helperMethod(component, event,component.get("v.availlength"));
        }
        component.set("v.intervwwvisibility","visible");
    },
    showInf : function(component, event, helper) {
        var compEvent = component.getEvent("showinterviewdetails");
        var mx = event.clientX;
        var my = event.clientY;
        compEvent.setParams({"recordByEvent" : component.get("v.intervww.intrvw"),
                             "multiusestringg" : 'showinf',
                             "mousepostx" : mx,
                             "mouseposty" : my,
                            });
        compEvent.fire();
    },
    hideInf : function(component, event, helper) {
        var compEvent = component.getEvent("showinterviewdetails");
        compEvent.setParams({"multiusestringg" : 'hideinf',
                            });
        compEvent.fire();
    },
    handleOpenNewWindowWithRecordId : function(component, event, helper) {
        var recordId = component.get('v.intervww.intrvw.Id');
        window.open('/lightning/r/Interview__c/' + recordId+'/view');
    },
    showstatusdeleteaddfeedback : function(component, event, helper) {
        var recordId = component.get('v.intervww.intrvw.Id');
        var mx = event.clientX;
        var my = event.clientY;
        var compEvent = component.getEvent("showoptionlistt");
        compEvent.setParams({"recordByEvent" : component.get("v.intervww.intrvw"),
                             "multiusestringg" : 'showoptionslst',
                             "mousepostx" : mx,
                             "mouseposty" : my,
                            });
        compEvent.fire();
    },
    drag : function(component, event, helper) {
        event.dataTransfer.setData('Text', 'thisid');
        var divcmp = component.find('informationdivv');
        $A.util.removeClass(divcmp, 'infdivvstyl');
        $A.util.addClass(divcmp, 'infdivvhiddenstyl');
        var compEvent = component.getEvent("InterviewDragEvent");
        compEvent.setParams({"recordByEvent" : component.get("v.intervww"),
                             "interviewerId" : component.get("v.interviewr.Id"),
                             "interviewDraggedStrthr" : component.get("v.strthrr"),
                             "intrvwdate" : component.get("v.intervww.intrvDtStrng"),
                            });
        compEvent.fire();
    },
})