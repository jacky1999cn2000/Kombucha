'use strict';

var app = angular.module('kombucha');

app.controller('SettingsController', ['$scope', '$state','settingsService', function($scope, $state, settingsService){
	$scope.data = settingsService.getData();

	//$scope.data.searchFormData = {};

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

	$scope.update = function(type){
		switch(type) {
		    case 'searchFormData.namespace':
		        settingsService.updateData(type, $scope.data.searchFormData.namespace);
		        break;
		    case 'searchFormData.query1':
		        settingsService.updateData(type, $scope.data.searchFormData.query1);
		        break;
		    case 'searchFormData.query2':
		        settingsService.updateData(type, $scope.data.searchFormData.query2);
		        break;
		    case 'searchFormData.query3':
		    	settingsService.updateData(type, $scope.data.searchFormData.query3);
		    	break;
		    default:
		        console.log('*** SettingsController:update(): this should never be printed ***');
		}
	};

	$scope.canSubmit = function(){
		console.log('****** Controller:canSubmit *****');
		console.log('                        ');
		return !settingsService.canAllFormsValid();
	};

	$scope.$watchGroup(['generalForm.$valid','searchForm.$valid','emailForm.$valid'], function(newVals) {
		console.log('****** watchGroup *****');
		console.log('                        ');
		console.log('generalForm.$valid: '+newVals[0]);
		console.log('searchForm.$valid: '+newVals[1]);
		console.log('emailForm.$valid: '+newVals[2]);
		console.log('                        ');

		if(!angular.isUndefined(newVals[0])){
			settingsService.updateData('generalFormValid', newVals[0]);
		}

		if(!angular.isUndefined(newVals[1])){
			settingsService.updateData('searchFormValid', newVals[1]);
		}

		if(!angular.isUndefined(newVals[2])){
			settingsService.updateData('emailFormValid', newVals[2]);
		}
    });

}]);