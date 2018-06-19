({
    doInit : function(component) {
        const myPageRef = component.get("v.pageReference");
        component.set('v.recordId', myPageRef.state.c__recordId);
        component.set('v.sObjectName', myPageRef.state.c__sObjectName);

        component.set('v.inited', true);

        var action = component.get("c.getPluralLabel");
        action.setStorable();
        action.setParams({
            objectAPIName: myPageRef.state.c__sObjectName
        });

        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set('v.pluralLabel', a.getReturnValue());
            } else if (state === "ERROR") {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);

        var labelCall = component.get("c.getLabel");
        labelCall.setStorable();
        labelCall.setParams({
            objectAPIName: component.get('v.sObjectName')
        });
        labelCall.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set('v.objectLabel', a.getReturnValue());
            } else if (state === "ERROR") {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(labelCall);

        var nameFieldCall = component.get("c.GetNameField");
        nameFieldCall.setParams({
            objectAPIName: component.get('v.sObjectName')
        });
        nameFieldCall.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set('v.nameField', a.getReturnValue());
            } else if (state === "ERROR") {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(nameFieldCall);
    },

    recordUpdated : function(component) {
        console.log('record updated');
        const nameField = component.get('v.nameField');
        console.log('name field is ' + nameField);
        const targetFields = component.get('v.targetFields');
        console.log(JSON.stringify(targetFields));
        console.log(targetFields[nameField]);

        component.set('v.nameValue', targetFields[nameField]);
    },

    navToObject : function(component) {
        component.find('navService').navigate({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: component.get('v.sObjectName'),
                actionName: 'home'
            }
        });
    },

    navToRecord : function(component) {
        component.find('navService').navigate({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: component.get('v.sObjectName'),
                recordId: component.get('v.recordId'),
                actionName: 'view'
            }
        });
    },
})
