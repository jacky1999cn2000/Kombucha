'use strict';

var app = angular.module('kombucha');

app.controller('HomeController', ['$scope', 'resourceUrl', 'remoteService', 'settingsService', '$state', '$http', '$window', '$q', function($scope, resourceUrl, remoteService, settingsService, $state, $http, $window, $q){

	console.log('tooling **'+kombucha_global.toolingApiRemoteSettingStatus);
	console.log('oauth **'+kombucha_global.oauthRemoteSettingStatus);

	$scope.imgUrl = resourceUrl + '/img/comebacklater.png';
	$scope.ready = true;
	$scope.host = 'https://'+kombucha_global.host;
	$scope.tooling = (kombucha_global.toolingApiRemoteSettingStatus == 'true');
	$scope.oauth = (kombucha_global.oauthRemoteSettingStatus == 'true');
	$scope.remotesettings = $scope.tooling && $scope.oauth;
	
	settingsService.initData().then(
		function(){
			$scope.kombucha = settingsService.getData();

			$scope.alreadyhavejobs = ($scope.kombucha.data.cronJobId_TestJobQueuer !== '');
			console.log('***alreadyhavejobs: '+$scope.alreadyhavejobs);

			var d = new Date();
			d.setHours(parseInt($scope.kombucha.data.hour, 10));
		    d.setMinutes(parseInt($scope.kombucha.data.minute, 10));
		    //d.setSeconds(0);
    		$scope.time = d;
			$scope.hstep = 1;
			$scope.mstep = 1;
			$scope.ismeridian = true;
			
			//define start() function here, since we need $scope.kombucha available for this function
			$scope.start = function(){
				console.log('in start()');
				$scope.kombucha.data.hour = $scope.time.getHours();
				$scope.kombucha.data.minute = $scope.time.getMinutes();
				console.log('kombucha: '+JSON.stringify($scope.kombucha.data));

				settingsService.saveData()
				.then(
					function(){
						console.log('save successful!');
						$scope.schedule();
					}
				)
				.then(
					function(){
						console.log('scheduling successful!');
					}
				);
			};
		}
	);

	$scope.schedule = function(){
		var deferred = $q.defer();

		var type = 'scheduling';
		var params = {};
		params.action = 'start';

		remoteService.call(type, params).then(
			function(data){
				var response = JSON.parse(data);
				if(response.status === 'ok'){
					console.log('response: '+JSON.stringify(response));

					$scope.kombucha.data.cronJobId_TestJobQueuer = response.result[0].cronJobId_TestJobQueuer;
					$scope.kombucha.data.cronJobName_TestJobQueuer = response.result[0].cronJobName_TestJobQueuer;
					
					console.log('--cronJobId_TestJobQueuer: '+$scope.kombucha.data.cronJobId_TestJobQueuer);
					console.log('--cronJobName_TestJobQueuer: '+$scope.kombucha.data.cronJobName_TestJobQueuer);
					
					$scope.alreadyhavejobs = ($scope.kombucha.data.cronJobId_TestJobQueuer !== '');
					
					console.log('***alreadyhavejobs: '+$scope.alreadyhavejobs);
					
					deferred.resolve('ok');
				}
			}
		);

		return deferred.promise;
	};


	$scope.deleteJobs = function(){
		var type = 'scheduling';
		var params = {};
		params.action = 'delete';

		remoteService.call(type, params).then(
			function(data){
				var response = JSON.parse(data);
				if(response.status === 'ok'){
					$scope.kombucha.data.cronJobId_TestJobQueuer = '';
					$scope.kombucha.data.cronJobName_TestJobQueuer = '';

					console.log('--cronJobId_TestJobQueuer: '+$scope.kombucha.data.cronJobId_TestJobQueuer);
					console.log('--cronJobName_TestJobQueuer: '+$scope.kombucha.data.cronJobName_TestJobQueuer);

					$scope.alreadyhavejobs = ($scope.kombucha.data.cronJobId_TestJobQueuer !== '');

					console.log('***alreadyhavejobs: '+$scope.alreadyhavejobs);
				}
			}
		);
	};

	$scope.createToolingApiRemoteSetting = function() {
		var data =  
	       '<?xml version="1.0" encoding="utf-8"?>' +  
	       '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+  
	       '<env:Header>' +  
	       '<urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">' +  
	       '<urn:sessionId>'+kombucha_global.sessionId+'</urn:sessionId>' +  
	       '</urn:SessionHeader>' +  
	       '</env:Header>' +  
	       '<env:Body>' +  

	       '<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' +  
	       '<metadata xsi:type="RemoteSiteSetting">' +  
	       '<fullName>Kombucha1</fullName>' +  
	       '<description>Tooling API Remote Site Setting for Kombucha</description>' +  
	       '<disableProtocolSecurity>false</disableProtocolSecurity>' +  
	       '<isActive>true</isActive>' +  
	       '<url>https://'+kombucha_global.host+'</url>' +  
	       '</metadata>' +  
	       '</createMetadata>' +  

	       '</env:Body>' +  
	       '</env:Envelope>'; 

	    console.log('request data: '+data);

		$http({ 
		    method: 'POST',
		    url: 'https://'+kombucha_global.host+'/services/Soap/m/31.0',//'https://c.na31.visual.force.com/services/Soap/m/31.0',
		    data: data,
		    headers: { 'Content-Type': 'text/xml', 'SOAPAction': '""' }
		})
		.success(function(data,status){
			console.log('***success!');
			console.log('data: '+data);
			console.log('status: '+status);
			kombucha_global.toolingApiRemoteSettingStatus = 'true';
			$state.reload();
		})
		.error(function(data,status){
			console.log('***error!!');
			console.log('data: '+data);
			console.log('status: '+status);
		});
	};

	$scope.createOauthRemoteSettings = function() {
		var data =  
	       '<?xml version="1.0" encoding="utf-8"?>' +  
	       '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+  
	       '<env:Header>' +  
	       '<urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">' +  
	       '<urn:sessionId>'+kombucha_global.sessionId+'</urn:sessionId>' +  
	       '</urn:SessionHeader>' +  
	       '</env:Header>' +  
	       '<env:Body>' +  

	       '<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' +  
	       '<metadata xsi:type="RemoteSiteSetting">' +  
	       '<fullName>Kombucha2</fullName>' +  
	       '<description>Oauth Remote Site Setting for Kombucha</description>' +  
	       '<disableProtocolSecurity>false</disableProtocolSecurity>' +  
	       '<isActive>true</isActive>' +  
	       '<url>https://login.salesforce.com/services/oauth2/token</url>' +  
	       '</metadata>' +  
	       '</createMetadata>' + 

	       '</env:Body>' +  
	       '</env:Envelope>'; 

	    console.log('request data: '+data);

		$http({ 
		    method: 'POST',
		    url: 'https://'+kombucha_global.host+'/services/Soap/m/31.0',//'https://c.na31.visual.force.com/services/Soap/m/31.0',
		    data: data,
		    headers: { 'Content-Type': 'text/xml', 'SOAPAction': '""' }
		})
		.success(function(data,status){
			console.log('***success!');
			console.log('data: '+data);
			console.log('status: '+status);
			kombucha_global.oauthRemoteSettingStatus = 'true';
			$state.reload();
		})
		.error(function(data,status){
			console.log('***error!!');
			console.log('data: '+data);
			console.log('status: '+status);
		});
	};

	$scope.leaveKombucha = function(){
		$window.location.href = $scope.host;
	};

	console.log('tooling: '+$scope.tooling);
	console.log('oauth: '+$scope.oauth);
	console.log('remotesettings: '+$scope.remotesettings);
	console.log('sessionId: '+kombucha_global.sessionId);
	console.log('host: '+kombucha_global.host);

	if($scope.tooling === true && $scope.oauth === true){
		console.log('***remote settings are ready');

		var type = 'settings';
		var params = {};
		params.action = 'checkAvailability';

		remoteService.call(type, params).then(
			function(data){
				var response = JSON.parse(data);
				if(response.status === 'ok'){
					$scope.ready = true;
				}else{
					$scope.ready = false;
					$scope.error = response.statusMessage;
				}
			},
			function(error){
				$scope.ready = false;
				$scope.error = error;
			}
		);
	}else{
		console.log('***remote settings are not ready');
		$scope.ready = false;
	}	
	


}]);