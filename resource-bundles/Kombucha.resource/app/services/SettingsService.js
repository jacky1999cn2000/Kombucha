'use strict';

var app = angular.module('kombucha');

app.factory('settingsService', [function(){
	
	var fac = {};

	fac.data = {};

	fac.data.searchFormData = {};

	fac.updateData = function(type, data){
		switch(type) {
			case 'generalFormValid':
				console.log('****** SERVICE:updateData *****');
				console.log('                        ');
				console.log('updateData generalFormValid before: '+fac.data.generalFormValid);
		        fac.data.generalFormValid = data;
		        console.log('updateData generalFormValid after: '+fac.data.generalFormValid);
		        console.log('                        ');
		        break;
		    case 'searchFormValid':
		    	console.log('****** SERVICE:updateData *****');
				console.log('                        ');
				console.log('updateData searchFormValid before: '+fac.data.searchFormValid);
		        fac.data.searchFormValid = data;
		        console.log('updateData searchFormValid after: '+fac.data.searchFormValid);
		        console.log('                        ');
		        break;
		    case 'emailFormValid':
		    	console.log('****** SERVICE:updateData *****');
				console.log('                        ');
				console.log('updateData emailFormValid before: '+fac.data.emailFormValid);
		        fac.data.emailFormValid = data;
		        console.log('updateData emailFormValid after: '+fac.data.emailFormValid);
		        console.log('                        ');
		        break;
			case 'searchFormData.namespace':
		        fac.data.searchFormData.namespace = data;
		        break;
		    case 'searchFormData.query1':
		        fac.data.searchFormData.query1 = data;
		        break;
		    case 'searchFormData.query2':
		        fac.data.searchFormData.query2 = data;
		        break;
		    case 'searchFormData.query3':
		        fac.data.searchFormData.query3 = data;
		        break;
		    default:
		        console.log('*** settingService:updateData(): this should never be printed ***');
		}
	};

	fac.getData = function(){
		return fac.data;
	};

	fac.canAllFormsValid = function(){
		console.log('****** SERVICE: canAllFormsValid *****');
		console.log('                        ');
		console.log('generalFormValid '+fac.data.generalFormValid);
		console.log('searchFormValid '+fac.data.searchFormValid);
		console.log('emailFormValid '+fac.data.emailFormValid);
		console.log('                        ');

		var flag = fac.data.generalFormValid && fac.data.searchFormValid && fac.data.emailFormValid;
		console.log('initial flag '+flag);

		if(angular.isUndefined(flag)){
			console.log('flag is undefined.');
			flag = false;
		}
		
		console.log('final flag '+flag);
		return flag;
	};

	return fac;
}]);