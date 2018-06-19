({
    doInit : function(component) {

        // // support for the fullscreen version (not on a record home page)
        // const myPageRef = component.get("v.pageReference");
        // if (!component.get('v.recordId') && myPageRef.state.c__recordId){
        //     component.set('v.recordId', myPageRef.state.c__recordId);
        //     component.set('v.sObjectName', myPageRef.state.c__sObjectName);
        //     component.set('v.fullScreen', myPageRef.state.c__fullScreen);
        // }

        var action = component.get('c.getHistory');
        action.setParams({
            objectAPIName : component.get('v.sObjectName'),
            recordId: component.get('v.recordId'),
            rowLimit: component.get('v.rowLimit')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === 'SUCCESS') {
                const result = JSON.parse(a.getReturnValue());
                component.set('v.data', result);
                console.log(result);
            } else if (state === 'ERROR') {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);

        var action = component.get("c.getUnarchivedCount");
        action.setParams({
            objectAPIName: component.get('v.sObjectName'),
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set('v.unarchivedCount', a.getReturnValue());
            } else if (state === "ERROR") {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);
        component.set('v.columns', [
            { label: 'Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric', hour:'2-digit', minute:'2-digit'}  },
            { label: 'Field', fieldName: 'Field', type: 'text' },
            { label: 'User', fieldName: 'UserLink', type: 'url', typeAttributes: {label: {fieldName:'CreatedByName'}, target: '_blank'} },
            { label: 'Original Value', fieldName: 'OldValue', type: 'text' },
            { label: 'New Value', fieldName: 'NewValue', type: 'text' }
        ]);
    },

    loadMoreData : function(component, event, helper) {
        console.log('load more called');
    },


})
