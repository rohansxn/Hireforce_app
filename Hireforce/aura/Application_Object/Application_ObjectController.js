({
    drag : function(component, event, helper) {
        event.dataTransfer.setData('Text', 'thisid');
        var applicationId = component.get("v.application.Id");
        component.set("v.intervieww.Application__c",applicationId);
        component.set("v.intervieww.Name",component.get("v.application.Name"));
        var compEvent = component.getEvent("ApplicationDragEvent");
        compEvent.setParams({"recordByEvent" : component.get("v.intervieww"),
                            });
        compEvent.fire();
    },
    
    showappInff : function(component, event, helper) {
        if(component.get("v.showappinf") == false)
        {
            component.set("v.showappinf",true);
        }
        else
        {
            component.set("v.showappinf",false);
        }
    },
})