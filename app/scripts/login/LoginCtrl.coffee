'use strict'

angular.module('WissenSystem')
.controller('LoginCtrl', ['$scope', '$state', '$mdDialog', 'AUTH_EVENTS', 'AuthService', '$stateParams', 'Restangular', '$cookies', 'Perfil', 'App', 'cfpLoadingBar', 'toastr', 'MySocket', 'SocketData', '$rootScope', '$http', ($scope, $state, $mdDialog, AUTH_EVENTS, AuthService, $stateParams, Restangular, $cookies, Perfil, App, cfpLoadingBar, toastr, MySocket, SocketData, $rootScope, $http)->
	
	
	$scope.logoPath 			= 'images/MyVc-1.gif'
	$scope.imagesPath 			= App.images 
	$scope.modificando_servidor = false
	$scope.editando_nombre_punto = false
	$scope.dominio 				= localStorage.getItem('dominio')
	$scope.MySocket 			= MySocket
	$scope.SocketData 			= SocketData
	$scope.usuarios_all 		= []
	$scope.selectedUser 		= {}


	# Traemos evento actual.
	$scope.in_evento_actual.qr = ''
	if !$scope.in_evento_actual.nombre
		Restangular.one('welcome').customGET().then((r)->
			$scope.in_evento_actual = r
			$scope.in_evento_actual.ip = if localStorage.getItem('nombre_punto') then localStorage.getItem('nombre_punto') else $scope.in_evento_actual.ip
			MySocket.conectar(r.qr)

		, (r2)->
			toastr.warning 'No se trae el evento principal'
		)


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
			templateUrl: App.views + 'login/passwordNombrePunto.tpl.html',
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
		

	$scope.seleccionarUsu = (usuario)->
		usuario.seleccionado = !usuario.seleccionado
		if usuario.seleccionado 
			$scope.selectedUser = usuario

			for user in $scope.usuarios_all
				if user.id != usuario.id
					user.seleccionado = false

	$scope.seleccionarCkUsu = (usuario)->
		if usuario.seleccionado 
			$scope.selectedUser = usuario

			for user in SocketData.usuarios_all
				if user.id != usuario.id
					user.seleccionado = false

	$scope.ingresar_seleccionado = ()->
		if $scope.selectedUser.id
			Restangular.one('qr/validar-usuario').customPUT({user_id: $scope.selectedUser.id, token_auth: SocketData.token_auth }).then((r)->
				if r.token
					$cookies.put('xtoken', r.token)
					$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')
					$state.go 'panel'
			, (r2)->
				toastr.warning 'No se pudo ingresar'
				console.log 'No se pudo ingresar ', r2
			)
		else 
			toastr.warning 'Selecciona el usuario correspondiente'
	
	$scope.guardarNombrePunto = ()->
		localStorage.setItem('nombre_punto', $scope.in_evento_actual.ip)
		$scope.editando_nombre_punto = false




	$rootScope.$on 'nombre_punto_cambiado', (ev, datos)->
		localStorage.setItem('nombre_punto', datos.nombre)
		$scope.in_evento_actual.ip = datos.nombre



	return

])

.controller('PasswordNombrePuntoCtrl', ['$scope', '$mdDialog', 'toastr', ($scope, $mdDialog, toastr)->
	
	$scope.validar = (pass)->
		$mdDialog.hide(pass)

	$scope.cancelar = ()->
		$mdDialog.cancel()

	return

])