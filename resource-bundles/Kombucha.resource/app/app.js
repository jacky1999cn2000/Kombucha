'use strict';

var app = angular.module('kombucha', ['ui.bootstrap', 'ui.router']);

app.constant('resourceUrl', '/resource/'+Date.now()+'/kombucha/app');

app.config(['$stateProvider','$urlRouterProvider','resourceUrl', function($stateProvider, $urlRouterProvider, resourceUrl){
	
	$urlRouterProvider.otherwise('/');

	$stateProvider
	.state('home', {
		url: '/',
		views: {
			'header': {
				templateUrl: resourceUrl+'/templates/partials/header.html',
				controller: 'HeaderController'
			},
			'content': {
				templateUrl: resourceUrl+'/templates/partials/home.html',
				controller: 'HomeController'
			},
			'footer': {
				templateUrl: resourceUrl+'/templates/partials/footer.html'
			}
		}
	})

	.state('home.settings', {
		url: 'settings',
		views: {
			'content@': {
				templateUrl: resourceUrl+'/templates/partials/settings.html',
				controller: 'SettingsController'
			}
		}
	})

	.state('home.settings.general', {
		url: '/general',
		views: {
			'general@home.settings' : {
				templateUrl: resourceUrl+'/templates/partials/settings-general.html',
				controller: 'SettingsController'
			}
		}
	})

	.state('home.settings.search', {
		url: '/search',
		views: {
			'search@home.settings' : {
				templateUrl: resourceUrl+'/templates/partials/settings-search.html',
				controller: 'SettingsController'
			}
		}
	})

	.state('home.settings.apexclass', {
		url: '/apexclass',
		views: {
			'apexclass@home.settings' : {
				templateUrl: resourceUrl+'/templates/partials/settings-apexclass.html',
				controller: 'SettingsController'
			}
		}
	})

	.state('home.settings.email', {
		url: '/email',
		views: {
			'email@home.settings' : {
				templateUrl: resourceUrl+'/templates/partials/settings-email.html',
				controller: 'SettingsController'
			}
		}
	})

	.state('home.analytics', {
		url: 'analytics',
		views: {
			'content@': {
				templateUrl: resourceUrl+'/templates/partials/analytics.html'
			}
		}
	});
}]);
















