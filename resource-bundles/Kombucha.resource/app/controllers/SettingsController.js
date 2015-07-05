'use strict';

var app = angular.module('kombucha');

app.controller('SettingsController', ['$scope', '$state','settingsService', function($scope, $state, settingsService){
	$scope.data = settingsService.getData();

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

	$scope.save = function(){
		var data = JSON.stringify($scope.data);
		console.log('data: '+ data);
	};

	$scope.canSubmit = function(){
		var flag = $scope.data.generalFormValid && $scope.data.searchFormValid && $scope.data.emailFormValid;

		if(angular.isUndefined(flag)){
			console.log('flag is undefined.');
			flag = false;
		}

		return !flag;
	};

	$scope.$watchGroup(['generalForm.$valid','searchForm.$valid','emailForm.$valid'], function(newVals) {
		if(!angular.isUndefined(newVals[0])){
			$scope.data.generalFormValid = newVals[0];
		}

		if(!angular.isUndefined(newVals[1])){
			$scope.data.searchFormValid = newVals[1];
		}

		if(!angular.isUndefined(newVals[2])){
			$scope.data.emailFormValid = newVals[2];
		}
    });

}]);