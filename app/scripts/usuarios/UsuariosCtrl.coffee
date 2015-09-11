angular.module('WissenSystem')

.controller('UsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'uiGridConstants', '$modal', '$filter', 'App' 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, uiGridConstants, $modal, $filter, App) ->

		$scope.imagesPath = App.images
		$scope.usuarios = []
		$scope.currentUsers = []
		$scope.newUsu = {
			sexo: 'M'
			niveles: []
			inscripciones: []
		}

		$scope.comprobar_evento_actual = ()->
			if $scope.evento_actual

				if $scope.evento_actual.idioma_principal_id

					$scope.idiomaPreg = {
						selected: $scope.evento_actual.idioma_principal_id
					}
			else
				toastr.warning 'Pimero debes crear o seleccionar un evento actual'

		$scope.comprobar_evento_actual()

		$scope.$on 'cambio_evento_user', ()->
			$scope.comprobar_evento_actual()
			$scope.traer_niveles()
			$scope.traer_disciplinas()
			$scope.traer_categorias()

		$scope.$on 'cambia_evento_actual', ()->
			$scope.comprobar_evento_actual()

		



		$scope.niveles_king = []
		$scope.traer_niveles = ()->
			Restangular.all('niveles/niveles-usuario').getList().then((r)->
				$scope.niveles_king = r
				#console.log 'Niveles traídas: ', r
			, (r2)->
				toastr.warning 'No se trajeron las niveles', 'Problema'
				console.log 'No se trajo niveles ', r2
			)
		$scope.traer_niveles()


		$scope.disciplinas_king = []
		$scope.traer_disciplinas = ()->
			Restangular.all('disciplinas/disciplinas-usuario').getList().then((r)->
				$scope.disciplinas_king = r
				#console.log 'Disciplinas traídas: ', r
			, (r2)->
				toastr.warning 'No se trajeron las disciplinas', 'Problema'
				console.log 'No se trajo disciplinas ', r2
			)
		$scope.traer_disciplinas()

			
		$scope.categorias_king1 = []
		$scope.categorias_king2 = []
		$scope.traer_categorias = ()->
			Restangular.all('categorias/categorias-usuario').getList().then((r)->
				$scope.categorias_king1 = r
				angular.copy($scope.categorias_king1, $scope.categorias_king2)
				#console.log 'Categorias traídas: ', r
			, (r2)->
				toastr.warning 'No se trajeron las categorias', 'Problema'
				console.log 'No se trajo categorias ', r2
			)
		$scope.traer_categorias()




			



		$scope.avatar = {
			masculino: {
				abrev: 'M'
				def: 'Masculino'
				img: $scope.imagesPath + 'system/avatars/male1.jpg'
			},
			femenino: {
				abrev: 'F'
				def: 'Femenino'
				img: $scope.imagesPath + 'system/avatars/female1.jpg'
			}
		}

		
		

		$scope.guardando = false
		$scope.guardarNuevo = ()->
			$scope.guardando = true

			Restangular.one('usuarios/store').customPOST($scope.newUsu).then((r)->
				r.editando = true
				$scope.usuarios.push r
				$scope.guardando = false
				console.log 'Usuario creado', r
			, (r2)->
				toastr.warning 'No se creó el usuario', 'Problema'
				console.log 'No se creó usuario ', r2
				$scope.guardando = false
			)



		$scope.cambiaInscripcion = (categoriaking, currentUser)->
			
			categoriaking.cambiando = true

			datos = 
				usuario_id: 	currentUser.id
				categoria_id: 	categoriaking.id

			if categoriaking.selected

			
				Restangular.one('inscripciones/inscribir').customPOST(datos).then((r)->
					$scope.usuarios.push r
					categoriaking.cambiando = false
					console.log 'Usuario creado', r
				, (r2)->
					toastr.warning 'No se inscribó el usuario', 'Problema'
					console.log 'No se inscribó el usuario ', r2
					categoriaking.cambiando = false
					categoriaking.selected = false
				)

			else

				Restangular.one('inscripciones/desinscribir').customPOST(datos).then((r)->
					$scope.usuarios.push r
					categoriaking.cambiando = false
					console.log 'Usuario creado', r
				, (r2)->
					toastr.warning 'No se quitó inscripción', 'Problema'
					console.log 'No se quitó inscripción ', r2
					categoriaking.cambiando = false
					categoriaking.selected = true
				)




		return
	]
)






