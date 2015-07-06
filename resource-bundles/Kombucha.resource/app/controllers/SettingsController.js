'use strict';

var app = angular.module('kombucha');

app.controller('SettingsController', ['$scope', '$state','settingsService', function($scope, $state, settingsService){

	settingsService.initData().then(

		function(success){
			//when code runs here, we know the data in service has been initiated already, so 
			//we could call getData() method safely
			$scope.kombucha = settingsService.getData();

			//define all other methods then
			
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
				var data = JSON.stringify($scope.kombucha.data);
				$scope.kombucha.data.editMode = !$scope.kombucha.data.editMode;
				console.log('***save data: '+ data);			
			};

			$scope.canSubmit = function(){
				var flag = $scope.kombucha.data.generalFormValid && $scope.kombucha.data.searchFormValid && $scope.kombucha.data.emailFormValid;

				if(angular.isUndefined(flag)){
					flag = false;
				}

				return !flag;
			};

			$scope.$watchGroup(['generalForm.$valid','searchForm.$valid','emailForm.$valid'], function(newVals) {
				if(!angular.isUndefined(newVals[0])){
					$scope.kombucha.data.generalFormValid = newVals[0];
				}

				if(!angular.isUndefined(newVals[1])){
					$scope.kombucha.data.searchFormValid = newVals[1];
				}

				if(!angular.isUndefined(newVals[2])){
					$scope.kombucha.data.emailFormValid = newVals[2];
				}
		    });
		}
	);

}]);