'use strict';

var app = angular.module('kombucha', ['ui.bootstrap', 'ui.router']);

app.config(function($stateProvider, $urlRouterProvider){
	
	$urlRouterProvider.otherwise('/');

	$stateProvider
	.state('home', {
		url: '/',
		views: {
			'header': {
				templateUrl:'/templates/partials/header.html',
				controller: 'HeaderController'
			},
			'content': {
				template:'<h1>content</h1>'
			},
			'footer': {
				templateUrl:'/templates/partials/footer.html'
			}
		}
	})

	.state('home.settings', {
		url: 'settings',
		views: {
			'content@': {
				templateUrl: '/templates/partials/settings.html',
				controller: 'SettingsController'
			}
		}
	})

	.state('home.settings.general', {
		url: '/general',
		views: {
			'general@home.settings' : {
				templateUrl: 'templates/partials/settings-general.html'
			}
		}
	})

	.state('home.settings.search', {
		url: '/search',
		views: {
			'search@home.settings' : {
				templateUrl: 'templates/partials/settings-search.html'
			}
		}
	})

	.state('home.settings.email', {
		url: '/email',
		views: {
			'email@home.settings' : {
				templateUrl: 'templates/partials/settings-email.html'
			}
		}
	});
});
















