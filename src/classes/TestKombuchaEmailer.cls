@isTest(SeeAllData=true) 
private class TestKombuchaEmailer {
	
	@isTest static void test_sendPostExceptionEmail() {
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		if(kombuchaConfig == null){
			kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
			insert kombuchaConfig;
		}
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		KombuchaEmailer.sendPostExceptionEmail('endpoint', 'error');
	}
	
	@isTest static void test_sendPasswordUpdateEmail() {
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		if(kombuchaConfig == null){
			kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
			insert kombuchaConfig;
		}
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		KombuchaEmailer.sendPasswordUpdateEmail();
	}

	@isTest static void test_sendTestResultEmail() {
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		if(kombuchaConfig == null){
			kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
			insert kombuchaConfig;
		}
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		List<ApexTestResult> jobTestResults = KombuchaCodeCoverageCalculator.checkMethodStatus(null);
		Map<String,String> codeCoverageResult = KombuchaCodeCoverageCalculator.getClassCoverage();

		KombuchaEmailer.sendTestResultEmail(jobTestResults, codeCoverageResult);
	}
	
}