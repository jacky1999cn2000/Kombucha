@isTest(SeeAllData=true) 
private class TestKombuchaCodeCoverageCalculator {
	
	@isTest static void test_createDailyScheduledJob() {
		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		if(kombuchaConfig == null){
			kombuchaConfig = new Kombucha_Configuration__c();
			kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
			insert kombuchaConfig;
		}
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		Test.startTest();
		KombuchaCodeCoverageCalculator.createDailyScheduledJob();
		Test.stopTest();
	}

	@isTest static void test_saveCodeCoverageToCustomSetting(){
		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		if(kombuchaConfig == null){
			kombuchaConfig = new Kombucha_Configuration__c();
			kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
			insert kombuchaConfig;
		}

		KombuchaCodeCoverageCalculator.saveCodeCoverageToCustomSetting('50');
		kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		System.assertEquals(kombuchaConfig.CodeCoverage__c, '50');
	}
	
}