public with sharing class KombuchaSettingSetup {
	
	/*
		Check if scheduler is available
	*/
	public static String isSchedulerAvailable(){

		Map<String, String> status = new Map<String, String>();
		String jsonString = '';

		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

		//1. check if custom setting exists
		if(kombuchaConfig == null){
			status.put('status', 'error');
			status.put('statusMessage', 'Kombucha custom setting is not available.');
			jsonString = KombuchaApexRouter.constructJSON(status, null);
			return jsonString;
		}

		//2. check if custom setting is well set
		if(kombuchaConfig.Instance_URL__c == null || kombuchaConfig.Instance_URL__c == '' ||
			kombuchaConfig.Username__c == null || kombuchaConfig.Username__c == '' ||
			kombuchaConfig.Password__c == null || kombuchaConfig.Password__c == '' ||
			kombuchaConfig.Security_Code__c == null || kombuchaConfig.Security_Code__c == '' ||
			kombuchaConfig.Query1__c == null || kombuchaConfig.Query1__c == '' ||
			kombuchaConfig.Query1_Position__c == null || kombuchaConfig.Query1_Position__c == '' ||
			kombuchaConfig.Recipient__c == null || kombuchaConfig.Recipient__c == '' ||
			kombuchaConfig.Title__c == null || kombuchaConfig.Title__c == '' ||
			kombuchaConfig.Add_Date__c == null){

			status.put('status', 'error');
			status.put('statusMessage', 'Please go to SETTINGS page to complete configuration first.');
			jsonString = KombuchaApexRouter.constructJSON(status, null);
			return jsonString;
		}

		//3. check if username & password works
		String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
		String username = kombuchaConfig.Username__c;
		String password = kombuchaConfig.Password__c + kombuchaConfig.Security_Code__c; //'Test.12348zwttaiuGue3Y5eIkfHdISWg';
		String clientId = '3MVG9QDx8IX8nP5TDUEcqn9g5NV2Mmoorc8ce29x4DibO9_vCc10quGGvZxEdCeF7EbxRoUU8cydvNd5ngVZd';
		String clientSecret = '2098978559629868962';
		String response = KombuchaSessionRefresher.requestAccessToken(username, password, clientId, clientSecret, tokenEndpoint);

		if(response.contains('authentication failure')){
			status.put('status', 'error');
			status.put('statusMessage', 'Please update your username & password & security token in SETTING page.');
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

	public static String saveConfigData(String data){
		Map<String, String> status = new Map<String, String>();
		String jsonString = '';

		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

		Map<String, Object> configMap = (Map<String, Object>)JSON.deserializeUntyped(data);
		for(String key : configMap.keySet()){
			if(key == 'generalFormData'){
				kombuchaConfig.Username__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('username'));
				kombuchaConfig.Password__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('password'));
				kombuchaConfig.Security_Code__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('securitycode'));
			}
			if(key == 'searchFormData'){
				kombuchaConfig.Namespace__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('namespace'));
				kombuchaConfig.Query1__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('query1'));
				kombuchaConfig.Query2__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('query2'));
				kombuchaConfig.Query3__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('query3'));
				kombuchaConfig.Query1_Position__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('query1_position'));
				kombuchaConfig.Query2_Position__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('query2_position'));
				kombuchaConfig.Query3_Position__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('query3_position'));
			}
			if(key == 'emailFormData'){
				kombuchaConfig.Recipient__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('recipient'));
				kombuchaConfig.Title__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('title'));
				kombuchaConfig.Slack_Endpoint__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('slackendpoint'));
				kombuchaConfig.Slack_Request__c = String.valueOf(((Map<String, Object>)configMap.get(key)).get('slackrequest'));
				kombuchaConfig.Add_Date__c = Boolean.valueOf(((Map<String, Object>)configMap.get(key)).get('adddate'));
			}
			if(key == 'hour'){
				kombuchaConfig.Hour__c = String.valueOf(configMap.get(key));
			}
			if(key == 'minute'){
				kombuchaConfig.Minute__c = String.valueOf(configMap.get(key));
			}
		}

		try{
			update kombuchaConfig;
			status.put('status', 'ok');
			status.put('statusMessage', '');
		}catch(Exception ex){
			status.put('status', 'error');
			status.put('statusMessage', 'Error when updating config');
		}

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
		generalFormData.put('securitycode', toValidData(kombuchaConfig.Security_Code__c));

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
		returnMap.put('alert', true);
		returnMap.put('generalFormValid', false);
		returnMap.put('searchFormValid', false);
		returnMap.put('emailFormValid', false);

		returnMap.put('generalFormData', generalFormData);
		returnMap.put('searchFormData', searchFormData);
		returnMap.put('emailFormData', emailFormData);

		returnMap.put('hour', toValidData(kombuchaConfig.Hour__c));
		returnMap.put('minute', toValidData(kombuchaConfig.Minute__c));

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