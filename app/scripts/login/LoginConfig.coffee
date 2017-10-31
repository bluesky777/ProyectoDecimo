'use strict'

angular.module('WissenSystem')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', '$translateProvider', ($stateProvider, App, USER_ROLES, PERMISSIONS, $translateProvider) ->
	


	$translateProvider.translations('EN',
		LOGIN_MSG: 'Sign In to the panel'
	)
	.translations('ES',
		LOGIN_MSG: 'Ingresa al panel'
	)
])