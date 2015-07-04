global with sharing class KombuchaTestJobQueuer implements schedulable {
	
	global void execute(SchedulableContext sc){
		doExecute();
	}

	@future (callout=true)
	public static void doExecute(){
		enqueueUnitTests();
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

       //ApexClasses[] testClasses = [SELECT Id, Name FROM ApexClass WHERE Name LIKE ]
	}
}