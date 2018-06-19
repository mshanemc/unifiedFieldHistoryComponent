public class LightningHistoryCtrl {

    @AuraEnabled
    public static string getPluralLabel(string objectAPIName){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        return sobjResult.getLabelPlural();
    }

    @AuraEnabled
    public static string getLabel(string objectAPIName){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        return sobjResult.getLabel();
    }

    @AuraEnabled
    public static string GetNameField(string objectAPIName){
        list<string> objects = new list<string>();
        objects.add(objectAPIName);

        list<Schema.DescribeSObjectResult> objectResults = Schema.describeSObjects(objects);
        system.assertEquals(1, objectResults.size());

        map<string, Schema.SObjectField> fieldMap = objectResults[0].fields.getMap();
        for (Schema.SObjectField field:fieldMap.values()){
            DescribeFieldResult dfr = field.getDescribe();
            if (dfr.isNameField()){
                return dfr.getName();
            }
        }

        return null;

    }

    @AuraEnabled
    public static string getHistory(string objectAPIName, string recordId, integer rowLimit){

        if (rowLimit == null){
            rowLimit = 2000;
        }

        list<sobject> unArchivedResults = (list<sobject>)getUnarchivedHistory(objectAPIName, recordId, rowLimit);

        integer archivedLimit = integer.valueOf(rowLimit) - unArchivedResults.size();

        system.debug(archivedLimit);

        list<sobject> archivedResults = (list<sobject>)getArchivedHistory(objectAPIName, recordId, archivedLimit);

        list<sobject> mergedResults = new list<sobject>();
        mergedResults.addAll(unArchivedResults);
        mergedResults.addAll(archivedResults);

        // returns a json array, but will be serialized at the end
        list<map<string, object>> finalResults = new list<map<string, object>>();

        //build a field describe map so we can use it in the fields later;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
        //system.debug(fieldMap);

        map<String, Schema.DescribeFieldResult> fieldDescribeMap = new map<String, Schema.DescribeFieldResult>();

        set<string> resultsFields = new set<string>();
        set<Id> referenceFieldIds = new set<Id>();

        set<id> userIds = new set<id>();

        for (sobject so:mergedResults){
            userIds.add( (Id)so.get('CreatedById') ); //IDs will will become a usermap
            if ((string)so.get('Field') != 'created'){
                resultsFields.add((string)so.get('Field')); //will become a list of fields to get describe for
            }
        }

        // iterate the resultsFields and get their describe
        for (string fieldName:resultsFields){
            //system.debug('resultField is ' + fieldName);
            if (fieldName != 'created'){
                try {
                    Schema.DescribeFieldResult descField = fieldMap.get(fieldName).getDescribe();
                    fieldDescribeMap.put(fieldName, descField);
                } catch (NullPointerException e){
                    try {
                        Schema.DescribeFieldResult descField = fieldMap.get(fieldName + 'Id').getDescribe();
                        fieldDescribeMap.put(fieldName, descField);
                    } catch (exception f){
                        system.debug('couldn\'t find describe for field ' + fieldName);
                    }
                } catch (exception e) {
                    system.debug('couldn\'t find describe for field ' + fieldName);
                }

                // put the reference fields in their own list so we can getDescribe them

            }
        }


        // scan for reference fields to resolve
        // list<ReferenceResolver.ResolverRequest> toResolve = new list<ReferenceResolver.ResolverRequest>();
        // for (sobject so:mergedResults){
        //     Schema.DescribeFieldResult descField = fieldDescribeMap.get( string.valueOf( so.get('Field')) );

        //     if (so.get('Field') != 'created'){
        //         system.debug('old value is ' + so.get('OldValue'));
        //         system.debug('new value is ' + so.get('NewValue'));

        //         if (  string.valueOf(  descField.getType()  ) == 'Reference' ){
        //             if (so.get('OldValue')!= null){
        //                 ReferenceResolver.ResolverRequest req = new ReferenceResolver.ResolverRequest();
        //                 req.objectName = string.valueOf(descField.getReferenceTo());
        //                 req.recordId = (id)so.get('OldValue');
        //                 toResolve.add(req);
        //             }
        //             if (so.get('NewValue')!= null){
        //                 ReferenceResolver.ResolverRequest req = new ReferenceResolver.ResolverRequest();
        //                 req.objectName = string.valueOf(descField.getReferenceTo());
        //                 req.recordId = (id)so.get('NewValue');
        //                 toResolve.add(req);
        //             }
        //         }
        //     }
        // }

        // map<id, string> resolvedRecords = ReferenceResolver.resolve(toResolve);

        //access check, remove dual-null weirdness!
        map<id, user> userMap = new map<id, user>([select Name from User where id in:userIds]);

        for (sobject so:mergedResults){
            map<string, object> fr = new map<string,object>();
            fr.put('CreatedDate', so.get('CreatedDate'));
            fr.put('Field', so.get('Field'));
            User u = (User)userMap.get((Id)so.get('CreatedById'));
            fr.put('CreatedByName', u.Name);
            fr.put('CreatedById', (Id)so.get('CreatedById'));
            fr.put('UserLink', '/' + (Id)so.get('CreatedById'));
            fr.put('ObjectLabel', sobjResult.getLabel());

            if ( string.valueOf( so.get('Field')) != 'created')  {

                if (  string.valueOf(  fieldDescribeMap.get(  string.valueOf( so.get('Field') )  ).getType()  )  == 'Reference' ){
                    // if it's castable to ID, ignore it!
                    if ( ! ((string)so.get('OldValue') instanceOf Id || (string)so.get('NewValue') instanceOf Id  )){
                        fr.put('OldValue', string.valueOf(so.get('OldValue')));
                        fr.put('NewValue', string.valueOf(so.get('NewValue')));
                    } else {
                        continue;
                    }
                    // fr.put('OldValue',  resolvedRecords.get( (id)so.get('OldValue') ) );
                    // fr.put('NewValue',  resolvedRecords.get( (id)so.get('NewValue') ) );
                // } else {
                // }
                } else {
                    fr.put('OldValue', string.valueOf(so.get('OldValue')));
                    fr.put('NewValue', string.valueOf(so.get('NewValue')));
                }
            }

            if (so.get('Field') == 'created'){
                finalResults.add(fr);
            } else {

                //security check
                Schema.DescribeFieldResult describe = fieldDescribeMap.get((string)so.get('Field'));
                system.debug(describe.getType());

                if (describe.isAccessible()){
                    finalResults.add(fr);
                }
            }

        }


        system.debug(finalResults);
        return JSON.serialize(finalResults);

    }

    public static list<FieldHistoryArchive> getArchivedHistory(string objectType, id recordId, integer RowLimit){
        try {
            return [select Field, NewValue, OldValue, CreatedDate, CreatedById from FieldHistoryArchive where FieldHistoryType =: objectType AND ParentId =:recordId order by FieldHistoryType ASC, ParentID ASC, CreatedDate DESC limit :RowLimit];
        } catch (exception e){
            return null;
        }
    }

    public static list<sobject> getUnarchivedHistory(string objectAPIName, id recordId, integer RowLimit){
        string parentFieldName = getParentName(objectAPIName);
        string query = 'select Field, NewValue, OldValue, CreatedDate, CreatedById from ' + getObjectHistoryName(objectAPIName) + ' where ' + parentFieldName + ' =\'' + recordId + '\' order by CreatedDate DESC limit ' + RowLimit;
		system.debug(query);
        list<sobject> output = database.query(query);
        return output;
    }

    @AuraEnabled
    public static integer getUnarchivedCount(string objectAPIName, id recordId){
        string parentFieldName = getParentName(objectAPIName);
        string query = 'select Count() from ' + getObjectHistoryName(objectAPIName) + ' where ' + parentFieldName + ' =\'' + recordId + '\'';
		// return database.query(query);
        return database.countQuery(query);

    }

    private static string getObjectHistoryName(string objectAPIName){
        if (objectAPIName.contains('__c')){
            return objectAPIName.replace('__c', '__History');
        }
        if (objectAPIName == 'Opportunity'){
            return 'OpportunityFieldHistory';
        }
        return objectAPIName + 'History';

    }

    private static string getParentName(string objectAPIName){
        if (objectAPIName.contains('__c')){
            return 'ParentId' ;
        }
        return objectAPIName + 'Id';
    }


}

// select Field, NewValue, OldValue, CreatedDate, CreatedById from FieldHistoryArchive where FieldHistoryType = 'Opportunity' and ParentID = '00663000007mbeFAAQ' order by FieldHistoryType ASC, ParentID ASC, CreatedDate DESC limit 0
