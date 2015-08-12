'use strict';
/*
var app = angular.module('kombucha');

app.factory('remoteService', ['$q', '$rootScope', function($q, $rootScope){
	
	var fac = {};

	fac.call = function(type, params){
		var deferred = $q.defer();

		KombuchaApexRouter.router(
				type,
				params,
				function(result, event){
					$rootScope.$apply(function(){
						if(event.status){
							deferred.resolve(result);
						}else{
							deferred.reject(event);
						}
					});	
				},
				{ buffer: true, escape: false, timeout: 30000 }
		);

		return deferred.promise;
	};

	return fac;
}]);
*/