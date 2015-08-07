global with sharing class KombuchaCodeCoverageCalculator implements Schedulable{
	global void execute(SchedulableContext SC){
		doExecute();
	}

	//Have to use a future method so the email will be sent out
	@future(callout=true)
	public static void doExecute(){
		processAsyncResults();
	}

	public static void createDailyScheduledJob(){
		Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);
		
		if(kombuchaConfig == null){
			return;
		}

        KombuchaCodeCoverageCalculator kccc = new KombuchaCodeCoverageCalculator();  
 		
 		String sch = String.format('0 {0} {1} * * ?', new String[] {kombuchaConfig.Minute__c, kombuchaConfig.Hour__c});
        //string sch = '0 58 14 * * ?'; 
        Id cronId = System.schedule('Kombucha - Calculate Code Coeverage',sch,kccc);

        kombuchaConfig.CronJobId_CodeCoverageCalculator__c = cronId;
        kombuchaConfig.CronJobName_CodeCoverageCalculator__c = 'Kombucha - Calculate Code Coeverage';
        update kombuchaConfig;
    }

    public static void processAsyncResults(){
    	System.debug('***in processAsyncResults');

    	List<Kombucha_Schedule_Job__c> queuedTests = [SELECT Id, Name, Job_Id__c FROM Kombucha_Schedule_Job__c LIMIT 5];

    	if(queuedTests != null && queuedTests.size() > 0){
    		Set<Id> AsyncIds = new Set<Id>();

    		for(Kombucha_Schedule_Job__c queuedJob : queuedTests){
    			AsyncIds.add(queuedJob.Job_Id__c);
    		}

    		List<ApexTestQueueItem> queuedItems = checkClassStatus(AsyncIds);

    		Map<Id, List<ApexTestQueueItem>> groupedTestsByJob = new Map<Id, List<ApexTestQueueItem>>();

    		for(ApexTestQueueItem atqi : queuedItems){
    			if(groupedTestsByJob.containsKey(atqi.ParentJobId)){
    				List<ApexTestQueueItem> groupedTests = groupedTestsByJob.get(atqi.ParentJobId);
    				groupedTests.add(atqi);
				}else{
					List<ApexTestQueueItem> groupedTests = new List<ApexTestQueueItem>();
					groupedTests.add(atqi);
					groupedTestsByJob.put(atqi.ParentJobId, groupedTests);
				}
    		}

    		Set<Id> completedAsyncJobIds = getCompletedAsyncJobIds(groupedTestsByJob);

    		if(completedAsyncJobIds != null && completedAsyncJobIds.size() > 0){
    			//this means at least one batch of tests were finished running
    			Map<String, String> codeCoverageResult = getClassCoverage();

    			if(codeCoverageResult == null){
    				//username password expires, send email
    				System.debug('***did not get sessionId');
                    KombuchaEmailer.sendPasswordUpdateEmail();
                    return;
    			}

    			List<ApexTestResult> testResults = checkMethodStatus(completedAsyncJobIds);

    			Map<Id, List<ApexTestResult>> groupedTestResultsByJob = new Map<Id, List<ApexTestResult>>();

    			for (ApexTestResult testResult : testResults){
                    if (groupedTestResultsByJob.containsKey(testResult.AsyncApexJobId)){
                        List<ApexTestResult> groupedTestsResults = groupedTestResultsByJob.get(testResult.AsyncApexJobId);
                        groupedTestsResults.add(testResult);
                    }
                    else{
                        List<ApexTestResult> groupedTestsResults = new List<ApexTestResult>();
                        groupedTestsResults.add(testResult);          
                        groupedTestResultsByJob.put(testResult.AsyncApexJobId, groupedTestsResults );
                    }
                }

                Integer counter = 0;
                for (List<ApexTestResult> jobTestResults : groupedTestResultsByJob.values()){

                	if(counter > 0){
                		return;
                	}

                    KombuchaEmailer.sendTestResultEmail(jobTestResults,codeCoverageResult);

                    System.debug('***jobTestResults: '+jobTestResults);
                	System.debug('***codeCoverageResult: '+codeCoverageResult);

                	counter++;
                    saveCodeCoverageToCustomSetting(codeCoverageResult.get('total coverage'));
                }

                List<Kombucha_Schedule_Job__c> queuedTestsToDelete = new List<Kombucha_Schedule_Job__c>();

                for (Kombucha_Schedule_Job__c queuedTest : queuedTests){
                    for (Id completedAsyncJobId : completedAsyncJobIds){
                        if (queuedTest.Job_Id__c == completedAsyncJobId){
                            queuedTestsToDelete.add(queuedTest);
                            break;
                        }
                    }
                    if (groupedTestsByJob.containsKey(queuedTest.Job_Id__c) == false){
                        queuedTestsToDelete.add(queuedTest);
                    }
                }
                
                if (queuedTestsToDelete.size() > 0){
                    delete queuedTestsToDelete;
                } 

    		}// if(completedAsyncJobIds != null && completedAsyncJobIds.size() > 0)

    	} // - if(queuedTests != null && queuedTests.size() > 0)
    }



    //utility functions

    public static void saveCodeCoverageToCustomSetting(String codeCoverage){
        Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

        if(kombuchaConfig != null){
            kombuchaConfig.CodeCoverage__c = codeCoverage;
            update kombuchaConfig;
        }
    }

    /*
    	Get the status and pass rate for each class whose tests were run by the job that
    	correspond to the specified job Id.
    */
    public static List<ApexTestQueueItem> checkClassStatus(Set<Id> jobIds){
    	ApexTestQueueItem[] items = [SELECT ApexClass.Name, Status, ExtendedStatus, ParentJobId FROM ApexTestQueueItem WHERE ParentJobId in : jobIds];

    	for(ApexTestQueueItem item : items){
    		String extStatus = item.ExtendedStatus == null ? '' : item.ExtendedStatus;
    		System.debug(item.ApexClass.Name + ': ' + item.Status + ',' + extStatus);
    	}

    	return items;
    } 

    /*
    	Return a Set containing ParentJobIds whose tests were all completed 
    */
    public static Set<Id> getCompletedAsyncJobIds(Map<Id, List<ApexTestQueueItem>> groupedTestsByJob){
    	Set<Id> completedAsyncJobIds = new Set<Id>();

    	for(List<ApexTestQueueItem> jobTests : groupedTestsByJob.values()){
    		if(jobTests == null || jobTests.size() == 0){
    			continue;
    		}

    		Boolean allCompleted = true;

    		for(ApexTestQueueItem queuedTest : jobTests){
    			if(queuedTest.Status != 'Completed' && queuedTest.Status != 'Failed' && queuedTest.Status != 'Aborted'){
    				allCompleted = false;
    				break;
    			}
    		}

    		if(allCompleted){
    			completedAsyncJobIds.add(jobTests[0].ParentJobId);
    		}
    	}

    	return completedAsyncJobIds;
    }

    /*
    	Get the result for each test method that was executed. 
    */
    public static List<ApexTestResult> checkMethodStatus(Set<ID> jobIds) {
        ApexTestResult[] results = 
           [SELECT Outcome,
                   MethodName,
                   Message,
                   StackTrace,
                   AsyncApexJobId, 
                   ApexClass.Name,
                   ApexClass.Body,
                   ApexClass.LengthWithoutComments,
                   ApexClass.NamespacePrefix,
                   ApexClass.Status,
                   ApexLogId,
                   ApexLog.DurationMilliseconds,
                   ApexLog.Operation,
                   ApexLog.Request,
                   ApexLog.Status,
                   ApexLog.Location,
                   ApexLog.Application
            FROM ApexTestResult 
            WHERE AsyncApexJobId in :jobIds];
            
        for (ApexTestResult atr : results) {
            System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                System.debug(atr.Message + '\n at ' + atr.StackTrace);
            }
        }
        
        return results;
    }

    /*
    	Make REST call to Tooling API and return a map as <className, codeCoverageRate>
    */
    public static Map<String, String> getClassCoverage(){

    	Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

    	String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
		String username = kombuchaConfig.Username__c;
		String password = kombuchaConfig.Password__c + kombuchaConfig.Security_Code__c; //'Test.12348zwttaiuGue3Y5eIkfHdISWg';
		String clientId = '3MVG9QDx8IX8nP5TDUEcqn9g5NV2Mmoorc8ce29x4DibO9_vCc10quGGvZxEdCeF7EbxRoUU8cydvNd5ngVZd';
		String clientSecret = '2098978559629868962';
		
		String sessionId = KombuchaSessionRefresher.requestAccessToken(username, password, clientId, clientSecret, tokenEndpoint);

    	if(sessionId.contains('authentication failure')){
			return null;
		}

		System.debug('***sessionId: '+sessionId);

		Set<Id> classIdSet = new Set<Id>();

		Map<Id, String> classIdNameMap = new Map<Id, String>();

		String sql = 'SELECT Id, Name FROM ApexClass' + KombuchaTestJobQueuer.buildWhereClause(kombuchaConfig.ApexClass_Query1__c,kombuchaConfig.ApexClass_Query2__c,kombuchaConfig.ApexClass_Query3__c,kombuchaConfig.ApexClass_Query1_Position__c,kombuchaConfig.ApexClass_Query2_Position__c,kombuchaConfig.ApexClass_Query3_Position__c,kombuchaConfig.ApexClass_Namespace__c);

		List<sObject> Classes = Database.query(sql);

		for(sObject ac : Classes){
   			classIdSet.add(((ApexClass)ac).Id);
   			classIdNameMap.put(((ApexClass)ac).Id, ((ApexClass)ac).Name);
   		}

   		String salesforceHost = 'https://' + kombuchaConfig.Instance_URL__c;
   		
   		System.debug('***salesforceHost: '+salesforceHost);

   		String idset = '';

   		for(Id id: classIdSet){
   			idset += '\''+id+'\',';
   		}

   		if(idset.endsWith(',')){
   			idset = idset.substring(0, idset.length() -1);
   		}

   		String query = 'SELECT+NumLinesCovered,NumLinesUncovered,ApexClassorTriggerId+FROM+ApexCodeCoverageAggregate+WHERE+ApexClassorTriggerId+In+(' + idset + ')';

   		String url = salesforceHost + '/services/data/v29.0/tooling/query/?q='+query;

   		System.debug('***url: '+url);

   		HttpRequest req = new HttpRequest();

   		req.setMethod('GET');
   		req.setEndpoint(url);
   		req.setHeader('Content-Type', 'application/json');
   		req.setHeader('Authorization', 'Bearer '+sessionId);

   		Http http = new Http();

   		HttpResponse res = http.send(req);

   		System.debug('***res '+res);
        System.debug('***res '+res.getBody());

        List<ClassCodeCoverage> classCodeCoverageList = getClassCodeCoverageList(res.getBody());

        System.debug('***class list '+classCodeCoverageList);
        System.debug('***class list size '+classCodeCoverageList.size());

        Map<String, String> results = new Map<String, String>();

        Integer covered_total = 0;
        Integer uncovered_total = 0;

        for(ClassCodeCoverage ccc : classCodeCoverageList){
            results.put(ClassIdNameMap.get(ccc.id), String.valueOf(ccc.codeCoverage));
            covered_total += ccc.numLinesCovered;
            uncovered_total += ccc.numLinesUncovered;
        }

        Double coverage_total = (covered_total*100)/(covered_total+uncovered_total);
        results.put('total coverage', String.valueOf(coverage_total));

        for(String name : results.keySet()){
            System.debug('***class name ' + name);
            System.debug('***class codeCoverage ' + results.get(name));
        }

        return results;
    }

    /*
    	parse json retrieved via Tooling API
    */
    public static List<ClassCodeCoverage> getClassCodeCoverageList(String jsonResponse){

    	List<ClassCodeCoverage> classCodeCoverageList = new List<ClassCodeCoverage>();

    	JSONParser parser = JSON.createParser(jsonResponse);

    	Id classId = null;
    	Integer numLinesCovered = null;
    	Integer numLinesUncovered = null;

    	while(parser.nextToken() != null){
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getCurrentName() == 'records'){
                    while(parser.nextToken() != JSONToken.END_ARRAY){

                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'NumLinesCovered'){
                            parser.nextToken();
                            numLinesCovered = Integer.valueOf(parser.getText());
                        }

                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'NumLinesUncovered'){
                            parser.nextToken();
                            numLinesUncovered = Integer.valueOf(parser.getText());
                        }

                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'ApexClassOrTriggerId'){
                            parser.nextToken();
                            classId = parser.getText();
                        }

                        if(parser.getCurrentToken() == JSONToken.END_OBJECT && classId != null && numLinesCovered != null && numLinesUncovered != null){
                            KombuchaCodeCoverageCalculator.ClassCodeCoverage ccc = new KombuchaCodeCoverageCalculator.ClassCodeCoverage(classId,numLinesCovered,numLinesUncovered);
                            System.debug('***ccc '+ccc);
                            classCodeCoverageList.add(ccc);
                            classId = null;
                            numLinesCovered = null;
                            numLinesUncovered = null;
                        }                       
                    }
                }
            }
        }

        return classCodeCoverageList;
    }

    //inline class to contain code coverage info 
    public class ClassCodeCoverage {

        public String id {get; set;}
        public Integer numLinesCovered {get;set;}
        public Integer numLinesUncovered {get;set;}
        public Double codeCoverage {get;set;}

        public ClassCodeCoverage(Id classId, Integer covered, Integer uncovered){
            id = classId;
            numLinesCovered = covered;
            numLinesUncovered = uncovered;
            codeCoverage = (covered*100)/(covered+uncovered);
        }
    }
}

























