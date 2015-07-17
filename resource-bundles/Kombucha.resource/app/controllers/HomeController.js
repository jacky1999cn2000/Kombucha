'use strict';

var app = angular.module('kombucha');

app.controller('HomeController', ['$scope', 'resourceUrl', 'remoteService', '$state', '$http', '$window', function($scope, resourceUrl, remoteService, $state, $http, $window){

	$scope.imgUrl = resourceUrl + '/img/comebacklater.png';
	$scope.ready = true;
	$scope.endpoint = 'https://'+kombucha_global.host;
	$scope.noremotesetting = false;
	
	$scope.time = new Date();
	$scope.hstep = 1;
	$scope.mstep = 1;
	$scope.ismeridian = true;

	$scope.start = function(){

	};

	$scope.createRemoteSettings = function() {
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
	       '<fullName>kombucha</fullName>' +  
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
		    url: 'https://c.na31.visual.force.com/services/Soap/m/31.0',
		    data: data,
		    headers: { 'Content-Type': 'text/xml', 'SOAPAction': '""' }
		})
		.success(function(data,status){
			console.log('***success!');
			console.log('data: '+data);
			console.log('status: '+status);
			kombucha_global.remoteSettingStatus = true;
			$state.reload();
		})
		.error(function(data,status){
			console.log('***error!!');
			console.log('data: '+data);
			console.log('status: '+status);
		});
	};

	$scope.leaveKombucha = function(){
		$window.location.href = $scope.endpoint;
	};


	console.log('remoteSettingStatus: '+kombucha_global.remoteSettingStatus);
	console.log('sessionId: '+kombucha_global.sessionId);
	console.log('host: '+kombucha_global.host);

	if(kombucha_global.remoteSettingStatus === true){
		console.log('***remote setting is ready');

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
		console.log('***remote setting is not ready');
		$scope.ready = false;
		$scope.noremotesetting = true;
	}	
	


}]);