public with sharing class KombuchaSettingSetup {
	
	/*
		Check if scheduler is available
	*/
	public static String isSchedulerAvailable(){

		Map<String, String> status = new Map<String, String>();
		String jsonString = '';

		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

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

	public static String getConfigData(){
		Map<String, String> status = new Map<String, String>();
		String jsonString = '';

		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

		Map<String, Object> generalFormData = new Map<String, Object>();
		Map<String, Object> searchFormData = new Map<String, Object>();
		Map<String, Object> emailFormData = new Map<String, Object>();

		//generalFormData
		generalFormData.put('username', toValidData(kombuchaConfig.Username__c));
		generalFormData.put('password', toValidData(kombuchaConfig.Password__c));

		//searchFormData
		searchFormData.put('query1_position', (toValidData(kombuchaConfig.Query1_Position__c) == '') ? 'start' : toValidData(kombuchaConfig.Query1_Position__c));
		searchFormData.put('query2_position', (toValidData(kombuchaConfig.Query2_Position__c) == '') ? 'start' : toValidData(kombuchaConfig.Query2_Position__c));
		searchFormData.put('query3_position', (toValidData(kombuchaConfig.Query3_Position__c) == '') ? 'start' : toValidData(kombuchaConfig.Query3_Position__c));
		searchFormData.put('query1', toValidData(kombuchaConfig.Query1__c));
		searchFormData.put('query2', toValidData(kombuchaConfig.Query2__c));
		searchFormData.put('query3', toValidData(kombuchaConfig.Query3__c));
		searchFormData.put('namespace', toValidData(kombuchaConfig.Namespace__c));

		//emailFormData
		emailFormData.put('adddate', Boolean.valueOf(toValidData(kombuchaConfig.Add_Date__c)));
		emailFormData.put('recipient', toValidData(kombuchaConfig.Recipient__c));
		emailFormData.put('title', toValidData(kombuchaConfig.Title__c));
		emailFormData.put('slackendpoint', toValidData(kombuchaConfig.Slack_Endpoint__c));
		emailFormData.put('slackrequest', toValidData(kombuchaConfig.Slack_Request__c));

		//main data		
		Map<String, Object> returnMap = new Map<String, Object>();

		returnMap.put('editMode', false);
		returnMap.put('generalFormValid', false);
		returnMap.put('searchFormValid', false);
		returnMap.put('emailFormValid', false);

		returnMap.put('generalFormData', generalFormData);
		returnMap.put('searchFormData', searchFormData);
		returnMap.put('emailFormData', emailFormData);

		status.put('status', 'ok');
		status.put('statusMessage', '');
		List<Map<String, Object>> resultList = new List<Map<String, Object>>();
		resultList.add(returnMap);

		jsonString = KombuchaApexRouter.constructJSON(status, resultList);

		return jsonString;
	}

	private static String toValidData(Object data){
		if (data == null)
			return '';
		else
			return String.valueOf(data);
	}













}