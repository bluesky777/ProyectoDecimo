angular.module('WissenSystem')

.controller('UsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'uiGridConstants', '$uibModal', '$filter', '$location', '$anchorScroll', '$mdSidenav', 'MySocket', 'SocketData', 'App', 'AuthService' 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, uiGridConstants, $modal, $filter, $location, $anchorScroll, $mdSidenav, MySocket, SocketData, App, AuthService) ->

		AuthService.verificar_acceso()

		$scope.imagesPath = App.images
		$scope.perfilPath = App.images + 'perfil/'
		$scope.usuarios = []
		$scope.currentUsers = []
		$scope.currentUser = {
			inscripciones: []
		}

		nivel 	= if localStorage.getItem('nivelSelected') then parseInt(localStorage.getItem('nivelSelected')) else ''
		entidad = if localStorage.getItem('entidadSelected') then parseInt(localStorage.getItem('entidadSelected')) else ''
		$scope.newUsu = {
			sexo: 			'M'
			nivel_id: 		nivel
			inscripciones: 	[]
			imgUsuario: 	null
		}
		$scope.editando = false
		$scope.creando = false


		

		Restangular.one('imagenes/usuarios').customGET().then((r)->
			$scope.imagenes = r.imagenes
		, (r2)->
			toastr.error 'No se trajeron las imágenes.'
		)
		

		$scope.misImagenes = ()->
			
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/misImagenes.tpl.html'
				controller: 'MisImagenes'
				size: 'lg',
				resolve: 
					resolved_user: ()->
						$scope.USER
			})
			modalInstance.result.then( (elem)->
				console.log elem
				$scope.imagenes.push elem
				$scope.newUsu.imgUsuario = $scope.imagenes[$scope.imagenes.length - 1]
				$scope.currentUser.imgUsuario = $scope.imagenes[$scope.imagenes.length - 1]
			)



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
			$scope.traer_entidades()
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


		$scope.entidades = []
		$scope.traer_entidades = ()->
			Restangular.all('entidades').getList().then((r)->
				$scope.entidades = r
			, (r2)->
				toastr.warning 'No se trajeron las entidades', 'Problema'
				console.log 'No se trajo entidades ', r2
			)
		$scope.traer_entidades()

			
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
				img: $scope.imagesPath + 'perfil/system/avatars/male1.jpg'
			},
			femenino: {
				abrev: 'F'
				def: 'Femenino'
				img: $scope.imagesPath + 'perfil/system/avatars/female1.jpg'
			}
		}

		$scope.empezarCrear = ()->
			$scope.creando 					= !$scope.creando
		
		

		$scope.guardando = false
		$scope.guardarNuevo = ()->
			$scope.guardando = true

			Restangular.one('usuarios/store').customPOST($scope.newUsu).then((r)->
				toastr.success 'Usuario guardado con éxito.'
				$scope.usuarios.unshift r
				$scope.guardando = false
				console.log 'Usuario creado', r
				$scope.newUsu.nombres = 		''
				$scope.newUsu.apellidos = 		''
				$scope.newUsu.username = 		''
				$scope.newUsu.inscripciones = 	[]
				$scope.newUsu.imgUsuario = 		null
			, (r2)->
				toastr.warning 'No se creó el usuario, posible login repetido', 'Problema'
				console.log 'No se creó usuario ', r2
				$scope.guardando = false
			)
		

		$scope.guardarNuevoYLogin = ()->
			$scope.guardando = true

			Restangular.one('usuarios/store').customPOST($scope.newUsu).then((r)->
				toastr.success 'Usuario guardado con éxito.'
				$scope.usuarios.unshift r
				$scope.guardando = false
				console.log 'Usuario creado', r

				$scope.newUsu.nombres = 		''
				$scope.newUsu.apellidos = 		''
				$scope.newUsu.username = 		''
				$scope.newUsu.inscripciones = 	[]
				$scope.newUsu.imgUsuario = 		null

				SocketData.clt_selected = usuario
				$mdSidenav('sidenavSelectPC').toggle()
				$location.hash('sidenavSelectPC');
				$anchorScroll();
			, (r2)->
				toastr.warning 'No se creó el usuario, posible login repetido', 'Problema'
				console.log 'No se creó usuario ', r2
				$scope.guardando = false
			)

		$scope.cambiaNivelNewUsu = ()->
			console.log $scope.newUsu.nivel_id
			localStorage.setItem 'nivelSelected', $scope.newUsu.nivel_id
		

		$scope.guardando_edicion = false
		$scope.guardarEdicion = ()->
			$scope.guardando_edicion = true

			Restangular.one('usuarios/update').customPUT($scope.currentUser).then((r)->
				toastr.success 'Cambios guardados.'
				$scope.guardando_edicion = false
				console.log 'Cambios guardados', r
			, (r2)->
				toastr.warning 'No se guardó cambios del usuario', 'Problema'
				console.log 'No se guardó cambios del usuario ', r2
				$scope.guardando_edicion = false
			)
			


		$scope.checkeandoCategorias = (item, list)->
			return list.indexOf(item) > -1

		$scope.toggle = (item, list)->
			idx = list.indexOf(item);
			if (idx > -1) then list.splice(idx, 1) else list.push(item)


		$scope.checkeandoCategoriasEdit = (item, list)->
			return list.indexOf(item) > -1

		$scope.toggleEdit = (item, list)->
			idx = list.indexOf(item);
			if (idx > -1) then list.splice(idx, 1) else list.push(item)



		$scope.cancelarNuevo = ()->
			$scope.creando = false


		$scope.cancelarEdicion = ()->
			$scope.editando = false



		$scope.cambiaInscripcion = (categoriaking, currentUsers)->
			
			currentUser = currentUsers[0]

			categoriaking.cambiando = true

			datos = 
				usuario_id: 	currentUser.id
				categoria_id: 	categoriaking.categoria_id

			if categoriaking.selected

			
				Restangular.one('inscripciones/inscribir').customPUT(datos).then((r)->
					categoriaking.cambiando = false
					console.log 'Inscripción creada', r

					inscrip = $filter('filter')(currentUser.inscripciones, {categoria_id: datos.categoria_id})
					if inscrip.length == 0
						currentUser.inscripciones.push r[0]
					else
						inscrip[0].id = r[0].id
						inscrip[0].deleted_at = r[0].deleted_at


				, (r2)->
					toastr.warning 'No se inscribó el usuario', 'Problema'
					console.log 'No se inscribó el usuario ', r2
					categoriaking.cambiando = false
					categoriaking.selected = false
				)

			else

				Restangular.one('inscripciones/desinscribir').customPUT(datos).then((r)->
					categoriaking.cambiando = false
					console.log 'Inscripción eliminada', r, currentUser.inscripciones, datos.categoria_id
					
					currentUser.inscripciones = $filter('filter')(currentUser.inscripciones, {categoria_id: '!'+datos.categoria_id})

				, (r2)->
					toastr.warning 'No se quitó inscripción', 'Problema'
					console.log 'No se quitó inscripción ', r2
					categoriaking.cambiando = false
					categoriaking.selected = true
				)




		return
	]
)






