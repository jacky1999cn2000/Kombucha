global with sharing class KombuchaApexRouter {
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
 			if(params.get('action') == 'getConfigData'){
 				jsonString = KombuchaSettingSetup.getConfigData();
 			}
 		}

 		System.debug('***jsonString: '+jsonString);
 		
 		return jsonString;
    }

    /*
    	Initiate kombuchaConfig during Home page load (if it hasn't been initiated yet).
    	Also get Salesforce Instance URL here. 
    */
    public PageReference init(){
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
		KombuchaSettingSetup.getConfigData();
	}
}