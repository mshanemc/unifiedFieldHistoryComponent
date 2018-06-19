({
    viewAll: function (component) {
        console.log('view all called');

        component.find('navService').navigate({
            type: 'standard__component',
            attributes: {
                componentName: 'c__unifiedFieldHistoryFullPage'
            },
            state: {
                "c__recordId": component.get('v.recordId'),
                "c__sObjectName": component.get('v.sObjectName')
            }
        });
    },

    doInit : function(component) {

        var action = component.get("c.getLabel");
        action.setStorable();
        action.setParams({
            objectAPIName: component.get('v.sObjectName')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set('v.objectLabel', a.getReturnValue());
            } else if (state === "ERROR") {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);
    },
})
