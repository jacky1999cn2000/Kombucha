'use strict';

var app = angular.module('kombucha');

app.controller('HeaderController', ['$scope', 'resourceUrl', function($scope, resourceUrl){
	$scope.selectedTab = 'home';

	$scope.selectTab = function(tabName){
		$scope.selectedTab = tabName;
	};

	$scope.imgUrl = resourceUrl + '/img/logo.png';
	
}]);