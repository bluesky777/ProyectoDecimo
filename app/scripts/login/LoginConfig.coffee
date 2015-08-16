'use strict'

angular.module('WissenSystem')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', '$translateProvider', ($stateProvider, App, USER_ROLES, PERMISSIONS, $translateProvider) ->
	

	$stateProvider

	.state('panel.login', { #- Estado admin.
				url: '^/login'
				views:
					'contenido_panel':
						templateUrl: "#{App.views}login/login.tpl.html"
						controller: 'LoginCtrl'

				data: 
					pageTitle: 'Login'
			})


	$translateProvider.translations('EN',
		LOGIN_MSG: 'Sign In to the panel'
	)
	.translations('ES',
		LOGIN_MSG: 'Ingresa al panel'
	)
])