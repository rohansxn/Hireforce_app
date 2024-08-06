({
    doInit : function(component, event, helper) {
        var objname = component.get("v.sObjectName");
        if(objname.includes("Interviewer__c")){
            component.set("v.buttonLabel",$A.get("$Label.c.Manage_My_Interviews")) 
        } else if(objname.includes("Application__c")){
        	component.set("v.buttonLabel",$A.get("$Label.c.Book_and_Manage_Interview"))    
        } else {
            component.set("v.buttonLabel",$A.get("$Label.c.Book_Interviews"))    
        }
        
        var action = component.get("c.getNavigationDecision");
        action.setParams({
            objectNme : component.get("v.sObjectName"),
            objId : component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                var res = actionResult.getReturnValue();
                if(res == 'hide'){
                	component.set("v.showButton",false);    
                } else if(res != 'ok'){
                	component.set("v.messagee",res); 
                    component.set("v.showButton",false);
                    component.set("v.showMsg",true);
                }
            }
        });
        $A.enqueueAction(action);
        
        
    },
    navigateToInterviewCalender : function(component, event, helper) {
        var objNmeobjId = component.get("v.sObjectName")+'@@'+component.get("v.recordId");
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Interview_Scheduler'
            },
            state: {
                c__objNameAndObjId: objNmeobjId
            }
        };
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                window.open(url, '_blank');
            }), $A.getCallback(function(error) {
            }));
    }
})