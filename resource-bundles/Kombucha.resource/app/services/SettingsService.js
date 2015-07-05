'use strict';

var app = angular.module('kombucha');

app.factory('settingsService', [function(){
	
	var fac = {};

	fac.data = {};

	fac.getData = function(){
		return fac.data;
	};

	return fac;
}]);