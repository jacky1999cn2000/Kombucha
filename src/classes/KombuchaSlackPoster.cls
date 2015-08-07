global with sharing class KombuchaSlackPoster implements Schedulable{
	global void execute(SchedulableContext SC) {
        doExecute();
    }
    
    @future (callout=true)
    public static void doExecute(){
        doPost();
    }

    public static void createDailyScheduledJob(){
		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		
		if(kombuchaConfig == null){
			return;
		}

        KombuchaSlackPoster ksp = new KombuchaSlackPoster();  
 		
 		//String sch = String.format('0 {0} {1} * * ?', new String[] {kombuchaConfig.Minute__c, kombuchaConfig.Hour__c});
        string sch = '0 35 16 * * ?'; 
        Id cronId = System.schedule('Kombucha - Slack Poster',sch,ksp);

        kombuchaConfig.CronJobId_SlackPoster__c = cronId;
        kombuchaConfig.CronJobName_SlackPoster__c = 'Kombucha - Slack Poster';
        update kombuchaConfig;
    }

    public static void doPost(){
    	Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
    	
    	if(kombuchaConfig.CodeCoverage__c == null || kombuchaConfig.CodeCoverage__c == ''){
    		return;
    	}

    	if(kombuchaConfig.Slack_Request__c != null && kombuchaConfig.Slack_Request__c != '' &&
    		kombuchaConfig.Slack_Endpoint__c != null || kombuchaConfig.Slack_Endpoint__c != ''){
    		postToSlack(kombuchaConfig.CodeCoverage__c, kombuchaConfig.Slack_Endpoint__c, kombuchaConfig.Slack_Request__c);
    	}

    	if(kombuchaConfig.Other_Endpoint__c != null && kombuchaConfig.Other_Endpoint__c != ''){
    		postToUniDragon(kombuchaConfig.CodeCoverage__c, kombuchaConfig.Other_Endpoint__c);
    	}

    }

    public static void postToUniDragon(String codeCoverage, String endpoint){
    	Map<String, String> testResult = new Map<String, String> {
            'type' => 'apex',
            'coverage' => codeCoverage
        };

        String request = JSON.serialize(testResult);
        
        request = request.replace('\\"', '"');
        request = request.replace('"{', '{');
        request = request.replace('}"', '}');
        request = request.replaceall('\\r','');
        request = request.replaceall('\\n','');
        request = request.replaceall('\\r\\n','');

        // Setup a new HTTP Request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        req.setBody(request);
        req.setHeader('Content-Type', 'application/json'); 

        System.debug('***request '+req); 

        // Create a new HTTP object
        Http http = new Http();
        HTTPResponse resp = null;

        try{
	        if(!Test.isRunningTest()) {
	            resp = http.send(req);
	        }
        }catch(Exception ex){
        	KombuchaEmailer.sendPostExceptionEmail(endpoint, ex.getMessage());
        }
    }

    public static void postToSlack(String codeCoverage, String endpoint, String request){
    	request = request.replace('codeCoverage', codeCoverage);
    	System.debug('***request content: '+request);

        // Setup a new HTTP Request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        req.setBody(request);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 

        System.debug('***req '+req); 

        // Create a new HTTP object
        Http http = new Http();
        HTTPResponse resp = null;

        try{
	        if(!Test.isRunningTest()) {
	            resp = http.send(req);
	        }    
        }catch(Exception ex){
        	KombuchaEmailer.sendPostExceptionEmail(endpoint, ex.getMessage());
        }
    }

}














