'use strict';

var app = angular.module('kombucha');

app.controller('SettingsController', ['$scope', '$state', function($scope, $state){
	$scope.selectTab = function(tabName){
		switch(tabName) {
		    case 'general':
		        $state.go('home.settings.general');
		        break;
		    case 'search':
		        $state.go('home.settings.search');
		        break;
		    case 'email':
		        $state.go('home.settings.email');
		        break;
		    default:
		        $state.go('home');
		}
	};
}]);