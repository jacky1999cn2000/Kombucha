'use strict';

var app = angular.module('kombucha');

app.factory('settingsService', ['$q', 'remoteService', function($q, remoteService){

	var fac = {};
	fac.kombucha = {};

	fac.initData = function(){
		var deferred = $q.defer();

		if(angular.isUndefined(fac.kombucha.data)){
			//if fac.kombucha.data not exists, then call remote service to init it
			var type = 'settings';
			var params = {};
			params.action = 'getConfigData';

			remoteService.call(type, params).then(
				function(data){
					var response = JSON.parse(data);
					if(response.status === 'ok'){
						fac.kombucha.data = response.result[0];
						deferred.resolve('ok');
					}
				}
			);
		}else{
			//otherwise, do nothing.
			deferred.resolve('ok');
		}

		return deferred.promise;
	};

	fac.getData = function(){
		//remember to use object, which will be passed by reference
		return fac.kombucha;
	};

	fac.saveData = function(){
		var deferred = $q.defer();

		var type = 'settings';
		var params = {};
		params.action = 'saveConfigData';
		params.data = JSON.stringify(fac.kombucha.data);

		remoteService.call(type, params).then(
			function(data){
				var response = JSON.parse(data);
				if(response.status === 'ok'){
					deferred.resolve('ok');
				}
			}
		);

		return deferred.promise;
	};

	return fac;
}]);