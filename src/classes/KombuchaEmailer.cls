public with sharing class KombuchaEmailer {

	public static void sendTestResultEmail(List<ApexTestResult> jobTestResults, Map<String,String> codeCoverageResult){
        System.debug(' In sendTestResultEmail');
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        Kombucha_Configuration__c kombuchaConfig = Kombucha_Configuration__c.getInstance(KombuchaConstants.CUSTOM_SETTING_NAME);

        mail.setToAddresses(new String[] {kombuchaConfig.Recipient__c});
        
        String emailSubject = kombuchaConfig.Title__c + ' ' + (kombuchaConfig.Add_Date__c ? String.valueOf(Date.today()) : ''); 
    
        mail.setSubject(emailSubject);

        String testResultEmailbody = getTestResultHtmlEmailBody(jobTestResults, codeCoverageResult);

        mail.setHtmlBody(testResultEmailbody);
        
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
        system.debug(' sent test results email');
    }


    private static String getTestResultHtmlEmailBody(List<ApexTestResult> jobTestResults, Map<String, String> codeCoverageResult){
        system.debug(' In getTestResultHtmlEmailBody');
        // Unfortunately, css has to be inlined because many email service providers now exclude external CSS
        // because it can pose a security risk.
        
        List<ApexTestResult> successTests = new List<ApexTestResult>();
        List<ApexTestResult> failedTests = new List<ApexTestResult>();
        
        for (ApexTestResult jobTestResult : jobTestResults){
            if (jobTestResult.Outcome == 'Pass'){
                successTests.add(jobTestResult);
            }
            else{
                failedTests.add(jobTestResult);
            }
        }
        
        Integer numTestsRun = successTests.size() + failedTests.size();
        Integer numFailures = failedTests.size();
        Integer successNum = numTestsRun - numFailures;
        
        if (successNum < 0){
            successNum = 0;
        }
        
        String testResultBody = '<table><tbody><tr>';

        testResultBody += '<th style="text-align: left; padding-left: 5px;">Class Name</th>';
        testResultBody += '<th style="text-align: left; padding-left: 5px;">Code Coverage</th>';
        testResultBody += '</tr>';        

        String total_coverage = '';

        for(String className : codeCoverageResult.keySet()){
            if(className == 'total coverage'){
                total_coverage = codeCoverageResult.get(className);
                continue;
            }

            if(Double.valueOf(codeCoverageResult.get(className)) < 75.0){
                testResultBody += '<tr>';
                testResultBody += '<td style="background-color: #FF0000; padding: 5px; vertical-align: top;">' + className +'';
                testResultBody += '<td style="background-color: #FF0000; padding: 5px; vertical-align: top;">' + codeCoverageResult.get(className) +'';
                testResultBody += '</tr>';
            }else{
                testResultBody += '<tr>';
                testResultBody += '<td style="background-color: #00FF00; padding: 5px; vertical-align: top;">' + className +'';
                testResultBody += '<td style="background-color: #00FF00; padding: 5px; vertical-align: top;">' + codeCoverageResult.get(className) +'';
                testResultBody += '</tr>';
            }
        }
        
        testResultBody += '</tbody></table>';

        testResultBody += '<div style="margin: 5px 0px; font-weight: bold;">Total Coverage: '+total_coverage+'</div>';

        testResultBody += '<table><tbody><tr class="firstTr"><td>Tests Run:</td><td>'+numTestsRun+'</td></tr><tr><td>Failure Count:</td><td>'+numFailures+'</td><</tr><tr><td>Success Count:</td><td>'+successNum+'</td></tr></tbody></table>';
                
        if (numFailures > 0){
            
            testResultBody += '<div style="margin: 5px 0px; font-weight: bold;">Test Failures</div>';
            
            testResultBody += '<table><tbody><tr>';
            
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Test Class</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Unit Test</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Message</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Stack Trace</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Time (Ms)</th>';
            testResultBody += '</tr>';
            
            for (ApexTestResult testFailure : failedTests){
                testResultBody += '<tr>';
                
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexClass.Name +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.MethodName +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.message +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.stackTrace +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexLog.DurationMilliseconds +'';
                
                testResultBody += '</tr>';
            }
            
            testResultBody += '</tbody></table>';
        }       
        
        return testResultBody;
    }
}