'use strict';

var app = angular.module('kombucha');

app.factory('settingsService', ['$q', 'remoteService', function($q, remoteService){

	var fac = {};
/*
	

	fac.initData = function(){
		fac.data = {};

		fac.data.generalFormData = {};
		fac.data.searchFormData = {};
		fac.data.emailFormData = {};

		fac.data.editMode = false;
		fac.data.emailFormData.adddate=true;
		fac.data.searchFormData.query1_position = 'start';
		fac.data.searchFormData.query2_position = 'start';
		fac.data.searchFormData.query3_position = 'start';
	}

	fac.getData = function(){

		console.log('***first check, fac.data: '+fac.data);

		var deferred = $q.defer();

		if(angular.isUndefined(fac.data)){

			var type = 'settings';
			var params = {};
			params.action = 'getConfigData';

			remoteService.call(type, params).then(
				function(data){
					var response = JSON.parse(data);

					if(response.status === 'ok'){
						fac.data = response.result[0];
						fac.data.status = response.status;
						fac.data.statusMessage = response.statusMessage;
					}else{
						this.initData();
						fac.data.status = response.status;
						fac.data.statusMessage = response.statusMessage;
					}
				}
			);
		}else{
			return fac.data;
		}
	};
*/

////////////////

	fac.data = {};

	fac.data.generalFormData = {};
	fac.data.searchFormData = {};
	fac.data.emailFormData = {};

	fac.data.editMode = false;
	fac.data.emailFormData.adddate=true;
	fac.data.searchFormData.query1_position = 'start';
	fac.data.searchFormData.query2_position = 'start';
	fac.data.searchFormData.query3_position = 'start';

	fac.getData = function(){
		return fac.data;
	};

	return fac;
}]);