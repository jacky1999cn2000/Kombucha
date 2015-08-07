global with sharing class KombuchaSlackPoster implements Schedulable{
	global void execute(SchedulableContext SC) {
        doExecute();
    }
    
    @future (callout=true)
    public static void doExecute(){
        postToSlack();
    }

    public static void createDailyScheduledJob(){
		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		
		if(kombuchaConfig == null){
			return;
		}

        KombuchaSlackPoster ksp = new KombuchaSlackPoster();  
 		
 		//String sch = String.format('0 {0} {1} * * ?', new String[] {kombuchaConfig.Minute__c, kombuchaConfig.Hour__c});
        string sch = '0 58 14 * * ?'; 
        Id cronId = System.schedule('Kombucha - Slack Poster',sch,ksp);

        kombuchaConfig.CronJobId_SlackPoster__c = cronId;
        kombuchaConfig.CronJobName_SlackPoster__c = 'Kombucha - Slack Poster';
        update kombuchaConfig;
    }

    public static void postToSlack(){
    	
    }

}