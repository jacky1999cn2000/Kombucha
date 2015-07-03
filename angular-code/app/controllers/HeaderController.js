'use strict';

var app = angular.module('kombucha');

app.controller('HeaderController', ['$scope', function($scope){
	$scope.selectedTab = 'home';

	$scope.selectTab = function(tabName){
		$scope.selectedTab = tabName;
	};
	
}]);