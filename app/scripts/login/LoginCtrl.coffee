'use strict'

angular.module('WissenSystem')
.controller('LoginCtrl', ['$scope', '$state', '$mdDialog', 'AUTH_EVENTS', 'AuthService', '$stateParams', 'Restangular', '$cookies', 'Perfil', 'App', 'cfpLoadingBar', 'toastr', ($scope, $state, $mdDialog, AUTH_EVENTS, AuthService, $stateParams, Restangular, $cookies, Perfil, App, cfpLoadingBar, toastr)->
	
	
	$scope.logoPath = 'images/MyVc-1.gif'
	$scope.modificando_servidor = false
	$scope.editando_nombre_punto = false


	$scope.credentials = 
		username: ''
		password: ''


	cfpLoadingBar.complete()

	$scope.login = ()->

		user = AuthService.login_credentials($scope.credentials)
		
		user.then((r)->
			#console.log 'Promise ganada', r
			return
		, (r2)->
			console.log 'Promise de login_credentials rechazada', r2
		)


	$scope.mostrar_modificar_servidor = ()->
		$scope.modificando_servidor = !$scope.modificando_servidor


	$scope.guardar_servidor = ()->
		localStorage.setItem('dominio', $scope.dominio)
		#toastr.success 'Servidor cambiado'
		location.reload();


	$scope.borrar_servidor = ()->
		localStorage.removeItem('dominio')


	$scope.editarNombrePunto = (ev)->
		elementWrapper = {}
		elementWrapper.target = document.getElementById('nombre_punto');
		
		confirm = $mdDialog.show({
			controller: 'PasswordNombrePuntoCtrl',
			templateUrl: App.views + 'login/password_nombre_punto.tpl.html',
			parent: angular.element(document.body),
			clickOutsideToClose:true,
			#openFrom: '#nombre_punto'
			fullscreen: true
			targetEvent: elementWrapper
		}).then((f)->
			console.log f
			if f != "" and f != null and f == $scope.in_evento_actual.password
				$scope.editando_nombre_punto = true
			else
				toastr.warning 'Contraseña incorrecta'
		, ()->
			$scope.status = 'You didn\'t name your dog.';
		)
		
		###
		f = prompt('Contraseña', 'Necesitas permisos para editar este nombre de equipo:')
		if f != "" and f != null and f == $scope.in_evento_actual.password
			$scope.editando_nombre_punto = true
		###
	
	$scope.guardarNombrePunto = ()->
		localStorage.setItem('nombre_punto', $scope.in_evento_actual.ip)
		$scope.editando_nombre_punto = false
		


	return

])

.controller('PasswordNombrePuntoCtrl', ['$scope', '$mdDialog', 'toastr', ($scope, $mdDialog, toastr)->
	
	$scope.validar = (pass)->
		$mdDialog.hide(pass)

	$scope.cancelar = ()->
		$mdDialog.cancel()

	return

])