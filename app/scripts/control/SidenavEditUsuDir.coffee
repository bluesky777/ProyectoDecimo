angular.module('WissenSystem')

.directive('sidenavEditUsuDir',['App', (App)->

	restrict: 'E'
	templateUrl: "#{App.views}control/sidenavEditUsuDir.tpl.html"
	scope: false
	controller: 'SidenavEditUsuCtrl'


])
.controller('SidenavEditUsuCtrl', ['$scope', 'Restangular', 'toastr', 'MySocket', 'SocketData', '$mdSidenav', '$mdDialog', '$filter',  ($scope, Restangular, toastr, MySocket, SocketData, $mdSidenav, $mdDialog, $filter)->

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
			img: $scope.imagesPath + 'perfil/system/avatars/male1.png'
		},
		femenino: {
			abrev: 'F'
			def: 'Femenino'
			img: $scope.imagesPath + 'perfil/system/avatars/female1.png'
		}
	}




	$scope.guardando_edicion = false
	$scope.guardar = ()->
		$scope.guardando_edicion = true

		Restangular.one('usuarios/update').customPUT($scope.clt_to_edit.user_data).then((r)->
			toastr.success 'Cambios guardados.'
			$scope.guardando_edicion = false
		, (r2)->
			toastr.warning 'No se guardó cambios del usuario', 'Problema'
			$scope.guardando_edicion = false
		)

	$scope.cancelar = ()->
		$scope.guardando_edicion = false
		$mdSidenav('sidenavEditusu').close()


	$scope.cambiarPass = (ev)->
		confirm = $mdDialog.prompt()
			.title('Contraseña')
			.textContent('Escribe nueva contraseña')
			.placeholder('Contraseña')
			.ariaLabel('Contraseña')
			.targetEvent(ev)
			.ok('Cambiar')
			.cancel('Cancelar');
		$mdDialog.show(confirm).then((result)->
			usu_id 	= if $scope.clt_to_edit.user_data.rowid then $scope.clt_to_edit.user_data.rowid else $scope.clt_to_edit.user_data.id
			datos 	= {usu_id: usu_id, password: result }

			Restangular.one('usuarios/cambiar-pass').customPUT(datos).then((r)->
				toastr.success 'Contraseña cambiada.'
			, (r2)->
				toastr.warning 'No se cambió la contraseña', 'Problema'
			)
		, ()->
			console.log "Canceló cambio de pass"
		)




	$scope.cambiaInscripcion = (categoriaking, currentUser)->

		categoriaking.cambiando = true

		datos =
			usuario_id: 	  if currentUser.rowid then currentUser.rowid else currentUser.id
			categoria_id: 	categoriaking.categoria_id

		if categoriaking.selected


			Restangular.one('inscripciones/inscribir').customPUT(datos).then((r)->
				categoriaking.cambiando = false
				console.log 'Inscripción creada', r

				inscrip = $filter('filter')(currentUser.inscripciones, {categoria_id: datos.categoria_id})
				if inscrip.length == 0
					currentUser.inscripciones.push r
				else
					inscrip[0].id         = if r.rowid then r.rowid else r.id
					inscrip[0].deleted_at = r.deleted_at


			, (r2)->
				toastr.warning 'No se inscribó el usuario', 'Problema'
				categoriaking.cambiando = false
				categoriaking.selected = false
			)

		else

			Restangular.one('inscripciones/desinscribir').customPUT(datos).then((r)->
				categoriaking.cambiando = false
				console.log 'Inscripción creada', r

				currentUser.inscripciones = $filter('filter')(currentUser.inscripciones, {categoria_id: '!'+datos.categoria_id})

			, (r2)->
				toastr.warning 'No se quitó inscripción', 'Problema'
				console.log 'No se quitó inscripción ', r2
				categoriaking.cambiando = false
				categoriaking.selected = true
			)





])
