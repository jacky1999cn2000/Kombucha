@isTest
private class TestKombuchaSettingSetup {
	
	@isTest static void test_isSchedulerAvailable(){
		//scenario 1: there is no custom setting
		System.assertEquals(KombuchaSettingSetup.isSchedulerAvailable().contains('Kombucha custom setting is not available.'), true);

		//scenario 2: there is custom setting, but certain fields are null
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		System.assertEquals(KombuchaSettingSetup.isSchedulerAvailable().contains('Please go to SETTINGS page to complete configuration first.'), true);
		
		//scenario 3: custom setting has all required data filled in, and check username and password
		kombuchaConfig.Instance_URL__c = 'dummyData';
		kombuchaConfig.Username__c = 'dummyData';
		kombuchaConfig.Password__c = 'dummyData';
		kombuchaConfig.Security_Code__c = 'dummyData';
		kombuchaConfig.Query1__c = 'dummyData';
		kombuchaConfig.ApexClass_Query1__c = 'dummyData';
		kombuchaConfig.Query1_Position__c = 'dummyData';
		kombuchaConfig.ApexClass_Query1_Position__c = 'dummyData';
		kombuchaConfig.Recipient__c = 'dummyData';
		kombuchaConfig.Title__c = 'dummyData';
		kombuchaConfig.Add_Date__c = true;
		update kombuchaConfig;

		System.assertEquals(KombuchaSettingSetup.isSchedulerAvailable(), '{"statusMessage":"","status":"ok","result":[]}');
	}

	@isTest static void test_saveConfigData(){
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;

		System.assertEquals(KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG), '{"statusMessage":"","status":"ok","result":[]}');
	}

	@isTest static void test_getConfigData(){
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);
		KombuchaSettingSetup.getConfigData();
		System.assert(true);
	}
}