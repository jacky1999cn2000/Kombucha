public with sharing class KombuchaSettingSetup {
	
	/*
		Check if scheduler is available
	*/
	public static String isSchedulerAvailable(){

		Map<String, String> status = new Map<String, String>();
		String jsonString = '';

		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance('kombucha');

		if(kombuchaConfig == null){
			status.put('status', 'error');
			status.put('statusMessage', 'Kombucha custom setting is not available.');
			jsonString = KombuchaApexRouter.constructJSON(status, null);
			return jsonString;
		}

		if(kombuchaConfig.Instance_URL__c == null || kombuchaConfig.Instance_URL__c == ''){
			status.put('status', 'error');
			status.put('statusMessage', 'Please go to SETTINGS page to complete configuration first.');
			jsonString = KombuchaApexRouter.constructJSON(status, null);
			return jsonString;
		}

		//TODO: CHECK WHETHER SCHEDULER JOBS ALREADY EXIST

		status.put('status', 'ok');
		status.put('statusMessage', '');
		List<Map<String, Object>> resultList = new List<Map<String, Object>>();
		jsonString = KombuchaApexRouter.constructJSON(status, resultList);

		return jsonString;
	} 
}