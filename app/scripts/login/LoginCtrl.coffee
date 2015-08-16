'use strict'

angular.module('WissenSystem')
.controller('LoginCtrl', ['$scope', '$rootScope', 'AUTH_EVENTS', 'AuthService', '$location', 'Restangular', '$cookies', 'Perfil', 'App', ($scope, $rootScope, AUTH_EVENTS, AuthService, $location, Restangular, $cookies, Perfil, App)->
	
	
	$scope.logoPath = 'images/MyVc-1.gif'

	$scope.credentials = 
		username: ''
		password: ''


	#$scope.host = $location.host()

	$scope.login = (credentials)->

		$state.go 'panel'

		user = AuthService.login_credentials(credentials)
		
		user.then((r)->
			#console.log 'Promise ganada', r
			return
		, (r2)->
			console.log 'Promise de login_credentials rechazada', r2
		)


	return

])