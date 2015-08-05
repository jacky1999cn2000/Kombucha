global with sharing class KombuchaTestJobQueuer implements schedulable {
	
	global void execute(SchedulableContext sc){
		doExecute();
	}

	@future (callout=true)
	public static void doExecute(){
		enqueueUnitTests();
	}

	public static void createDailyScheduledJob(){
		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		
		if(kombuchaConfig == null){
			return;
		}

        KombuchaTestJobQueuer ktjq = new KombuchaTestJobQueuer();  
 		
 		String sch = String.format('0 {0} {1} * * ?', new String[] {kombuchaConfig.Minute__c, kombuchaConfig.Hour__c});
        System.schedule('Enqueue Unit Tests',sch,ktjq);
    }

	/*
		Allows us to externally enqueue our unit tests. 
		For example, whenever we check our code into source control, we could
       	run our unit tests.
	*/
	WebService static void enqueueUnitTests(){
		enqueueTests();
	}

	public static void enqueueTests(){
		/* 	The first thing we need to do is to query all the test classes that 
			we want to execute

         	In most org, test classes are named as "Test<Class_Name_Here>"
         	so that all the test classes are grouped together in IDE.

         	We will build the where clause based on the keyword defined in settings.
       */

       Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

       String sql = 'SELECT Id, Name FROM ApexClass' + buildWhereClause(kombuchaConfig.Query1__c,kombuchaConfig.Query2__c,kombuchaConfig.Query3__c,kombuchaConfig.Query1_Position__c,kombuchaConfig.Query2_Position__c,kombuchaConfig.Query3_Position__c,kombuchaConfig.Namespace__c);

       System.debug('***sql : '+sql);

       List<sObject> testClasses = Database.query(sql);

       System.debug('***testClasses: '+testClasses);
	}

	private static String buildWhereClause(String keyword1, String keyword2, String keyword3,
										   String position1, String position2, String position3,
										   String namespaceprefix){
		String whereClause = ' WHERE ';

		if(keyword1 != null && keyword1 != ''){
			whereClause += 'Name LIKE ' + getQueryKeyword(keyword1, position1);
		}
		if(keyword2 != null && keyword2 != ''){
			whereClause += 'AND Name LIKE ' + getQueryKeyword(keyword2, position2);
		}
		if(keyword3 != null && keyword3 != ''){
			whereClause += 'AND Name LIKE ' + getQueryKeyword(keyword3, position3);
		}
		if(namespaceprefix != null && namespaceprefix != ''){
			whereClause += 'AND NamespacePrefix = "' + namespaceprefix + '"';
		}

		return whereClause;
	}

	private static String getQueryKeyword(String keyword, String position){
		if(position == 'start'){
			return '\'' + keyword + '%\' ';
		}

		if(position == 'end'){
			return '\'%' + keyword + '\' ';
		}

		return '\'%' + keyword + '%\' ';
	}
}






































