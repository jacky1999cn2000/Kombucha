'use strict';

var app = angular.module('kombucha');

app.controller('HomeController', ['$scope', 'resourceUrl', 'remoteService', function($scope, resourceUrl, remoteService){

	$scope.imgUrl = resourceUrl + '/img/comebacklater.png';
	$scope.ready = true;
	
	$scope.time = new Date();
	$scope.hstep = 1;
	$scope.mstep = 1;
	$scope.ismeridian = true;
	$scope.start = function(){

	};

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

	



}]);