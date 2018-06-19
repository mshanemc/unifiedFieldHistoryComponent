@isTest(seeAllData=true)
private class LightningHistoryCtrlTest {

    @isTest static void checkFATTable(){
        list<opportunity> o = [select Id from Opportunity];
        system.assert(o.size() == 1);

        LightningHistoryCtrl.getArchivedHistory('Opportunity', o[0].Id, 1000);
    }

    @isTest static void checkUnarchivedCount(){
        list<opportunity> o = [select Id from Opportunity];
        system.assert(o.size() == 1);

        integer result = LightningHistoryCtrl.getUnarchivedCount('Opportunity', o[0].Id);
        system.assertEquals(LightningHistoryCtrl.getUnarchivedHistory('Opportunity', o[0].Id, 1000).size(), result);
    }


	// @isTest static void test_method_one() {
	// 	list<case> cases = [select id from case];
	// 	system.assert(cases.size()!=0);
	// 	//public static string getHistory(string objectAPIName, string recordId)
	// 	LightningHistoryCtrl.getHistory('Case', cases[0].Id);
	// }

	// @testSetup static void testSetupCoreObjects() {
    //     case c = new case();
    //     c.status = 'New';
    //     c.Subject = 'your software sucks';
    //     insert c;

    //     lead l = new lead();
    //     l.lastname = 'McLaughlin';
    //     insert l;

    //     account a = new account();
    //     a.name = 'Pizza King';
    //     insert a;

    //     /*opportunity o = new opportunity();
    //     o.name = 'Pizza King Oppty';
    //     o.AccountId = a.Id;
    //     o.CloseDate = system.today();
    //     o.StageName = 'New';
    //     insert o;*/

}