@isTest
private class TestKombuchaApexRouter {
	
	@isTest static void test_router() {
		Map<String, String> params = new Map<String, String>();
		params.put('action', 'checkAvailability');
		KombuchaApexRouter.router('settings', params);

		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;

		params.put('action', 'saveConfigData');
		params.put('data', KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);
		KombuchaApexRouter.router('settings', params);

		params.put('action', 'getConfigData');
		KombuchaApexRouter.router('settings', params);

		params.put('action', 'start');
		KombuchaApexRouter.router('scheduling', params);

		params.put('action', 'delete');
		KombuchaApexRouter.router('scheduling', params);
	}
	
	@isTest static void test_init() {
		KombuchaApexRouter apexRouter = new KombuchaApexRouter();
		apexRouter.init();
	}

	@isTest static void test_getToolingApiRemoteSettingStatus() {
		KombuchaApexRouter.getToolingApiRemoteSettingStatus();

		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);

		KombuchaApexRouter.getToolingApiRemoteSettingStatus();
	}
	
	@isTest static void test_getOauthRemoteSettingStatus() {

		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);
		
		KombuchaApexRouter apexRouter = new KombuchaApexRouter();
		apexRouter.getOauthRemoteSettingStatus();
	}

	@isTest static void test_getHost() {
		
		Kombucha_Configuration__c kombuchaConfig = new Kombucha_Configuration__c();
		kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;
		insert kombuchaConfig;
		KombuchaSettingSetup.saveConfigData(KombuchaConstants.KOMBUCHA_SETTINGSETUP_SAVECONFIG);
		
		KombuchaApexRouter apexRouter = new KombuchaApexRouter();
		apexRouter.getHost();
	}
}