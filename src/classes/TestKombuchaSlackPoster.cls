@isTest
private class TestKombuchaSlackPoster {
	
	@isTest static void test_createDailyScheduledJob() {
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		Test.startTest();
		kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		kombuchaConfig.CodeCoverage__c = 'dummyData';
		kombuchaConfig.Slack_Request__c = 'dummyData';
		kombuchaConfig.Slack_Endpoint__c = 'dummyData';
		update kombuchaConfig;
		KombuchaSlackPoster.createDailyScheduledJob();
		Test.stopTest();
	}
	
}