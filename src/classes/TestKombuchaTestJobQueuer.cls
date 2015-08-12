@isTest
private class TestKombuchaTestJobQueuer {
	
	@isTest static void test_createDailyScheduledJob() {
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		Test.startTest();
		KombuchaTestJobQueuer.createDailyScheduledJob();

		kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

		String jobId = kombuchaConfig.CronJobId_TestJobQueuer__c;
		System.debug('***jobId '+jobId);

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);

		Test.stopTest();
	}
	
}