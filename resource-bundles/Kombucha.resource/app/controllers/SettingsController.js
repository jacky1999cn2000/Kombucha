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
				    case 'apexclass':
				    	$state.go('home.settings.apexclass');
				    	break;
				    default:
				        $state.go('home');
				}
			};

			$scope.save = function(){
				$scope.kombucha.data.editMode = !$scope.kombucha.data.editMode;

				settingsService.saveData().then(
					function(success){
						$scope.kombucha.data.alert = false;
						setTimeout(function(){ 
							$scope.kombucha.data.alert = true; 
							$scope.$apply();
							var data = JSON.stringify($scope.kombucha.data);				
							console.log('***after alert data: '+ data);
						}, 1500);
						var data = JSON.stringify($scope.kombucha.data);				
						console.log('***before alert data: '+ data);
					}
				);			
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