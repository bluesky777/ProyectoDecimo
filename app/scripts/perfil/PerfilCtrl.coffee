'use strict'

angular.module('WissenSystem')

.controller('PerfilCtrl', ['$scope', 'Restangular', 'toastr', 
	($scope, Restangular, toastr) ->

		$scope.newusername = ''
		$scope.passantiguo = ''
		$scope.newpass = ''
		$scope.newpassverif = ''
		$scope.status = { passCambiado: false } # Para cerrar tab cuando se cambie el password

		$scope.cambiarPass = (newpass, newpassverif, passantiguo)->

			if newpass not in [newpassverif]
				toastr.warning 'Las contraseñas no coinciden'
				return
			if newpass.length < 3
				toastr.warning 'La contraseña debe tener mínimo 3 caracteres. Sin espacios ni Ñ ni tildes.'
				return
			
			$scope.cambiandoPass = true # Bloqueamos el botón temporalmente

			datos = {'password':newpassverif, 'oldpassword': passantiguo }

			Restangular.one('perfiles/cambiarpassword/'+$scope.USER.id).customPUT(datos).then((r)->
				toastr.success 'Contraseña cambiada.'
				$scope.status.passCambiado = false
				$scope.cambiandoPass = false
			, (r2)->
				r2 = r2.data
				if r2.$error
				
					if r2.error.message == 'Contraseña antigua es incorrecta'
						toastr.warning r2.error.message
					else
						toastr.error 'No se pudo cambiar la contraseña.'
				else
					toastr.error 'No se pudo cambiar la contraseña.'

				$scope.cambiandoPass = false
			)



	]
)








