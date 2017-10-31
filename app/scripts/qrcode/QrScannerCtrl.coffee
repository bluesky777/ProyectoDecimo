angular.module('WissenSystem')

.controller('QrScannerCtrl', ['$scope', 'Restangular', 'toastr', 'resolved_user', 'App', 'AuthService', 'MySocket',  ($scope, Restangular, toastr, resolved_user, App, AuthService, MySocket)->

	$scope.USER = resolved_user
	$scope.imagesPath = App.images
	$scope.esperando = false
	$scope.usuarios = []
	$scope.selectedUser = {}


	AuthService.verificar_acceso()

	$scope.onSuccess = (data)->
		if !$scope.esperando
			toastr.info 'Reconocido...'
			$scope.esperando = true

			datos = {code: data}
			if $scope.selectedUser.id
				datos.user_id = $scope.selectedUser.id

			Restangular.one('qr').customPOST(datos).then((r)->
				if r.res 
					if r.res == 'no_encontrado'
						toastr.warning 'Código NO encontrado en la base de datos'
				else
					if r.accepted
						if $scope.selectedUser.id
							MySocket.got_qr(r, $scope.selectedUser.id)
						else
							MySocket.got_qr(r)
						toastr.success 'Código acceptado: "' + r.comando + '"'
					else
						toastr.warning 'Código NO aceptado', 'Tal vez ya ha sido usado antes'
				setTimeout(()->
					$scope.esperando = false
				, 3000);
				
			, (r2)->
				toastr.warning 'No se pudo reconocer el código qr'
				console.log 'No se pudo reconocer el código qr ', r2
				$scope.esperando = false
			)

	$scope.onError = (error)->
		$scope.errorqr = error

	$scope.onVideoError = (error)->
		$scope.errorqr = error

	$scope.seleccionarUsu = (usuario)->
		usuario.seleccionado = !usuario.seleccionado
		if usuario.seleccionado 
			$scope.selectedUser = usuario

			for user in $scope.usuarios
				if user.id != usuario.id
					user.seleccionado = false

	$scope.seleccionarCkUsu = (usuario)->
		if usuario.seleccionado 
			$scope.selectedUser = usuario

			for user in $scope.usuarios
				if user.id != usuario.id
					user.seleccionado = false





	Restangular.all('usuarios').getList().then((data)->
		$scope.usuarios = data;
	)



])

