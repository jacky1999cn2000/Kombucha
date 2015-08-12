global with sharing class KombuchaApexRouter {
	public String hasRemoteSettings {get;set;}
	/*
		The major routing method.
	*/
	@RemoteAction
 	global static String router(String type, Map<String, String> params){
 		
 		System.debug('***type: '+type);
 		System.debug('***params: '+params);

 		String jsonString = '';

 		if(type == 'settings'){
 			if(params.get('action') == 'checkAvailability'){
 				jsonString = KombuchaSettingSetup.isSchedulerAvailable();
 			}
 			if(params.get('action') == 'saveConfigData'){
 				jsonString = KombuchaSettingSetup.saveConfigData(params.get('data'));
 			}
 			if(params.get('action') == 'getConfigData'){
 				jsonString = KombuchaSettingSetup.getConfigData();
 			}
 		}

 		if(type == 'scheduling'){
 			Map<String, String> status = new Map<String, String>();
 			List<Map<String, Object>> resultList = new List<Map<String, Object>>();
			Map<String, Object> returnMap = new Map<String, Object>();

 			if(params.get('action') == 'start'){
 				try{
 					KombuchaTestJobQueuer.createDailyScheduledJob();
 				}catch(Exception ex){
 					status.put('status', 'error');
					status.put('statusMessage', ex.getMessage());	
 				}

 				try{
 					KombuchaCodeCoverageCalculator.createDailyScheduledJob();
 				}catch(Exception ex){
 					status.put('status', 'error');
					status.put('statusMessage', ex.getMessage());	
 				}

 				try{
 					KombuchaSlackPoster.createDailyScheduledJob();
 				}catch(Exception ex){
 					status.put('status', 'error');
					status.put('statusMessage', ex.getMessage());	
 				}

 				Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
 				System.debug('***kombuchaConfig: '+kombuchaConfig);

				returnMap.put('cronJobId_TestJobQueuer', kombuchaConfig.CronJobId_TestJobQueuer__c);
				returnMap.put('cronJobName_TestJobQueuer', kombuchaConfig.CronJobName_TestJobQueuer__c);
				returnMap.put('cronJobId_CodeCoverageCalculator', kombuchaConfig.CronJobId_CodeCoverageCalculator__c);
				returnMap.put('cronJobName_CodeCoverageCalculator', kombuchaConfig.CronJobName_CodeCoverageCalculator__c);
				returnMap.put('cronJobId_SlackPoster', kombuchaConfig.CronJobId_SlackPoster__c);
				returnMap.put('cronJobName_SlackPoster', kombuchaConfig.CronJobName_SlackPoster__c);
				resultList.add(returnMap);
 			}

 			if(params.get('action') == 'delete'){

 				Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

 				try{
 					System.abortJob(kombuchaConfig.CronJobId_TestJobQueuer__c);	
 					System.abortJob(kombuchaConfig.CronJobId_CodeCoverageCalculator__c);
 					System.abortJob(kombuchaConfig.CronJobId_SlackPoster__c);
 				}catch(Exception ex){
 					status.put('status', 'error');
					status.put('statusMessage', ex.getMessage());
 				}

 				kombuchaConfig.CronJobId_TestJobQueuer__c = '';
 				kombuchaConfig.CronJobName_TestJobQueuer__c = '';
 				kombuchaConfig.CronJobId_CodeCoverageCalculator__c = '';
 				kombuchaConfig.CronJobName_CodeCoverageCalculator__c = '';
 				kombuchaConfig.CronJobId_SlackPoster__c = '';
 				kombuchaConfig.CronJobName_SlackPoster__c = '';
 				update kombuchaConfig;
 			}

 			status.put('status', 'ok');
			status.put('statusMessage', '');
			jsonString = KombuchaApexRouter.constructJSON(status, resultList);
 		}

 		System.debug('***jsonString: '+jsonString);

 		return jsonString;
    }

    /*
    	Initiate kombuchaConfig during Home page load (if it hasn't been initiated yet).
    	Also get Salesforce Instance URL here. 
    */
    public PageReference init(){

    	System.debug('***in init');
    	
    	Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		
		if(kombuchaConfig == null){
			kombuchaConfig = new Kombucha_Configuration__c();
			kombuchaConfig.Name = KombuchaConstants.CUSTOM_SETTING_NAME;

			List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.'); 
         	String instance = String.join( parts, '.' ); 
         	kombuchaConfig.Instance_URL__c = instance;

         	try{
         		insert kombuchaConfig;
         	}catch(Exception ex){
         		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.FATAL, 'A problem occurred while saving Kombucha Configuration: ' + ex.getMessage());
           		ApexPages.addMessage(errorMessage);
         	}   	
		}

		return null;
    }

    /*
    	Initiate kombuchaConfig during Home page load (if it hasn't been initiated yet).
    	Also get Salesforce Instance URL here. 
    */
    public static Boolean getToolingApiRemoteSettingStatus(){

		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		
		if(kombuchaConfig == null){
			System.debug('***kombuchaConfig is null');
			return false;
		}

		try{
			HttpRequest req = new HttpRequest();
			req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
			req.setHeader('Content-Type', 'application/json');
			req.setEndpoint('https://' + kombuchaConfig.Instance_URL__c + '/services/data/v31.0/tooling/sobjects/User/' + UserInfo.getUserId() +'/');
			req.setMethod('GET'); 
			Http h = new Http();

			if(Test.isRunningTest()){
				return false;
			}else{
				HttpResponse res = h.send(req);
			}

		}catch(Exception e){
			System.debug('***in Exception');
			return false;
		}
		
		return true;
	}

    public Boolean getOauthRemoteSettingStatus(){

    	Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

    	if(kombuchaConfig == null || kombuchaConfig.Username__c == null || kombuchaConfig.Password__c == null || kombuchaConfig.Security_Code__c == null){
    		return false;
    	}
    	
    	String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
		String username = kombuchaConfig.Username__c;
		String password = kombuchaConfig.Password__c + kombuchaConfig.Security_Code__c; //'Test.12348zwttaiuGue3Y5eIkfHdISWg';
		String clientId = '3MVG9QDx8IX8nP5TDUEcqn9g5NV2Mmoorc8ce29x4DibO9_vCc10quGGvZxEdCeF7EbxRoUU8cydvNd5ngVZd';
		String clientSecret = '2098978559629868962';
		
		String response = KombuchaSessionRefresher.requestAccessToken(username, password, clientId, clientSecret, tokenEndpoint);

		if(response.contains('authentication failure')){
			return true;
		}

		if(response.contains('Unauthorized endpoint')){
			return false;
		}else{
			return true;
		}
    }

    public String getHost(){

    	Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

    	if(kombuchaConfig == null || kombuchaConfig.Instance_URL__c == null){
    		return '';
    	}else{
    		return kombuchaConfig.Instance_URL__c;
    	}
    }


    /*
    	A tooling function to construct JSON string.
    */
    public static String constructJSON(Map<String, String> status, List<Map<String, Object>> resultList){
 		Map<String, Object> jsonMap;

 		if(status.get('status') == 'ok'){
			jsonMap = new Map<String, Object>{
	 			'result' => resultList,
	 			'status' => 'ok',
	 			'statusMessage' => ''
	 		};
 		}else{
 			jsonMap = new Map<String, Object>{
	 			'result' => new List<Object>(),
	 			'status' => status.get('status'),
	 			'statusMessage' => status.get('statusMessage')
	 		};
 		}

 		String jsonString = JSON.serialize(jsonMap);
 		return jsonString;			
 	}


	public void test(){
		KombuchaCodeCoverageCalculator.getClassCoverage();
	}
}