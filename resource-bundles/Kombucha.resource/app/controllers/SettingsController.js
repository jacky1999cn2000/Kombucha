'use strict';

var app = angular.module('kombucha');

app.controller('SettingsController', ['$scope', '$state','settingsService', function($scope, $state, settingsService){
	$scope.data = settingsService.getData();
	console.log('***settingsService.getData(): '+settingsService.getData());
	console.log('***initialized data: '+$scope.data);

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
		console.log('***save data: '+ data);
		$scope.data.editMode = !$scope.data.editMode;
	};

	$scope.canSubmit = function(){
		console.log('***scope data: '+ $scope.data);
		var flag = $scope.data.generalFormValid && $scope.data.searchFormValid && $scope.data.emailFormValid;

		if(angular.isUndefined(flag)){
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