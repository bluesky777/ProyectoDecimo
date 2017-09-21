angular.module('WissenSystem')

.directive('sidenavSelectUsuDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}control/sidenavSelectUsuDir.tpl.html"
	scope: false
	controller: 'SidenavSelectUsuCtrl'
		

])
.controller('SidenavSelectUsuCtrl', ['$scope', 'Restangular', 'toastr', 'MySocket', 'SocketData', 'SocketClientes', '$mdSidenav',  ($scope, Restangular, toastr, MySocket, SocketData, SocketClientes, $mdSidenav)->
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
		usuario.seleccionado = !usuario.seleccionado
		if usuario.seleccionado 
			$scope.selectedUser = usuario

			for user in SocketClientes.usuarios_all
				if user.id != usuario.id
					user.seleccionado = false

	$scope.seleccionarCkUsu = (usuario)->
		if usuario.seleccionado 
			$scope.selectedUser = usuario

			for user in SocketClientes.usuarios_all
				if user.id != usuario.id
					user.seleccionado = false

	$scope.ingresar_seleccionado = (usuario)->
		if usuario
			MySocket.let_him_enter(usuario.id, $scope.cltdisponible_selected.resourceId)
			$scope.cerrar_sidenav()
		else
			if $scope.selectedUser.id
				MySocket.let_him_enter($scope.selectedUser.id, $scope.cltdisponible_selected.resourceId)
				$scope.cerrar_sidenav()
			else 
				toastr.warning 'Selecciona un usuario'
	
	
		
	$scope.cerrar_sidenav = ()->
		$mdSidenav('sidenavSelectusu').close()
		


])
