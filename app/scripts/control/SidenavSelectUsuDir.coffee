angular.module('WissenSystem')

.directive('sidenavSelectUsuDir',['App', (App)->

	restrict: 'E'
	templateUrl: "#{App.views}control/sidenavSelectUsuDir.tpl.html"
	scope: false
	controller: 'SidenavSelectUsuCtrl'


])
.controller('SidenavSelectUsuCtrl', ['$scope', 'Restangular', 'toastr', 'MySocket', 'SocketData', 'SocketClientes', '$mdSidenav', '$timeout',  ($scope, Restangular, toastr, MySocket, SocketData, SocketClientes, $mdSidenav, $timeout)->
	$scope.selectedUser 		= {}



	$scope.avatar = {
		masculino: {
			abrev: 'M'
			def: 'Masculino'
			img: $scope.imagesPath + 'perfil/system/avatars/male1.png'
		},
		femenino: {
			abrev: 'F'
			def: 'Femenino'
			img: $scope.imagesPath + 'perfil/system/avatars/female1.png'
		}
	}


	$scope.seleccionarUsu = (usuario)->
		user_id               = if usuario.rowid then usuario.rowid else usuario.id
		usuario.seleccionado  = !usuario.seleccionado

		if usuario.seleccionado
			$scope.selectedUser = usuario

			for user in SocketClientes.usuarios_all
				user2_id = if user.rowid then user.rowid else user.id
				if user2_id != user_id
					user.seleccionado = false

	$scope.seleccionarCkUsu = (usuario)->
		user_id               = if usuario.rowid then usuario.rowid else usuario.id
		if usuario.seleccionado
			$scope.selectedUser = usuario

			for user in SocketClientes.usuarios_all
				user2_id = if user.rowid then user.rowid else user.id
				if user2_id != user_id
					user.seleccionado = false

	$scope.ingresando_seleccionado = false
	$scope.ingresar_seleccionado = (usuario)->
		if 	$scope.ingresando_seleccionado == false
			if usuario
				user_id = if usuario.rowid then usuario.rowid else usuario.id
				$scope.ingresando_seleccionado = true

				MySocket.let_him_enter(user_id, $scope.cltdisponible_selected.resourceId)
				$scope.cerrar_sidenav()
			else
				user_id = if $scope.selectedUser.rowid then $scope.selectedUser.rowid else $scope.selectedUser.id
				if user_id
					$scope.ingresando_seleccionado = true
					MySocket.let_him_enter(user_id, $scope.cltdisponible_selected.resourceId)
					$scope.cerrar_sidenav()
				else
					toastr.warning 'Selecciona un usuario'



	$scope.cerrar_sidenav = ()->
		$mdSidenav('sidenavSelectusu').close()
		$timeout(()->
			$scope.ingresando_seleccionado = false
		, 50)


])
