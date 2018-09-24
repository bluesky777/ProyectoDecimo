angular.module('WissenSystem')

.controller('GridUsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$interval', 'toastr', 'uiGridConstants', '$uibModal', '$filter', '$location', '$anchorScroll', '$mdSidenav', 'App', 'MySocket', 'SocketData'
	($scope, $http, Restangular, $state, $cookies, $interval, toastr, uiGridConstants, $modal, $filter, $location, $anchorScroll, $mdSidenav, App, MySocket, SocketData) ->

		$scope.currentusers = []
		$scope.currentuser = {}


		$scope.seleccionar_fila = (row)->
			$scope.gridApi.selection.clearSelectedRows()
			$scope.gridApi.selection.selectRow(row)
			$scope.currentuser = row

			# Me tocó copiarlo pues se acumulaban las inscripciones
			categoriasking_copy = []
			angular.copy $scope.categoriasking, categoriasking_copy
			console.log $scope.currentusers, categoriasking_copy, $scope.idioma
			$scope.categorias_inscripcion = $filter('categsInscritas')($scope.currentusers, categoriasking_copy, $scope.idioma )
			console.log $scope.categorias_inscripcion


		$scope.seleccionar_entidad = (row)->

			modalInstance = $modal.open({
				templateUrl: App.views + 'usuarios/cambiarEntidadUsuario.tpl.html'
				controller: 'SelectEntidadCtrl'
				resolve:
					usuario: ()->
						row
					entidades: ()->
						$scope.$parent.entidades
			})
			modalInstance.result.then( (entidad_id)->
				row.entidad_id = entidad_id
			)


		$scope.showSidenavSelectPC = (usuario)->
			SocketData.clt_selected = usuario
			$mdSidenav('sidenavSelectPC').toggle()
			$location.hash('sidenavSelectPC');
			$anchorScroll();


		$scope.editando = false
		$scope.editar = (row)->
			$scope.gridApi.selection.clearSelectedRows()
			$scope.gridApi.selection.selectRow(row)

			$scope.$parent.currentUser 				= row
			$scope.$parent.currentUser.imgUsuario 	= {id: $scope.$parent.currentUser.imagen_id, nombre: $scope.$parent.currentUser.imagen_nombre}

			for entid in $scope.$parent.entidades
				if entid.id == $scope.$parent.currentUser.entidad_id
					$scope.$parent.currentUser.entidad = entid

			$scope.$parent.currentUser.nivel_id 	= parseInt($scope.$parent.currentUser.nivel_id)
			$scope.currentusers 					= [row]
			$scope.$parent.editando 				= true

			# Me tocó copiarlo pues se acumulaban las inscripciones
			categoriasking_copy = []
			angular.copy $scope.categoriasking, categoriasking_copy

			$scope.$parent.categorias_inscripcion = $filter('categsInscritas')($scope.currentusers, categoriasking_copy, $scope.idioma )




		$scope.eliminar = (row)->
			$scope.gridApi.selection.clearSelectedRows()
			$scope.gridApi.selection.selectRow(row)

			modalInstance = $modal.open({
				templateUrl: App.views + 'usuarios/removeUsuario.tpl.html'
				controller: 'RemoveUsuarioCtrl'
				resolve:
					usuario: ()->
						row
					entidades: ()->
						$scope.$parent.entidades
			})
			modalInstance.result.then( (usuario)->
				user_id = if usuario.rowid then usuario.rowid else usuario.id
				campo   = if usuario.rowid then {rowid: '!'+user_id} else {id: '!'+user_id}

				$scope.usuarios         = $filter('filter')($scope.usuarios, campo)
				$scope.gridOptions.data = $scope.usuarios
			)


		$scope.$on('usuarioEliminadoEnParentEditar' , (event, usuario)->
			user_id = if usuario.rowid then usuario.rowid else usuario.id
			campo   = if usuario.rowid then {rowid: '!'+user_id}  else {id: '!'+user_id}

			$scope.usuarios         = $filter('filter')($scope.usuarios, campo)
			$scope.gridOptions.data = $scope.usuarios
		)



		$scope.verRoles = (row)->

			modalInstance = $modal.open({
				templateUrl: App.views + 'usuarios/verRoles.tpl.html'
				controller: 'VerRolesCtrl'
				resolve:
					usuario: ()->
						row
					roles: ()->
						Restangular.all('roles').getList().then((r)->
							return r
						, (r2)->
							toastr.warning 'No pudo traer los roles', 'Problema'
							console.log 'No pudo traer los roles ', r2
						)
			})
			modalInstance.result.then( (user)->
				#console.log 'Resultado del modal: ', user
			)



		btGrid1 = '<a class="btn btn-default btn-xs " ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i> <md-tooltip md-direction="left">Editar</md-tooltip> </a>'
		btGrid2 = if ($(window).width() > 800) then '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-xs btn-danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a> ' else ''
		btGrid3 = '<a class="btn btn-xs btn-info" ng-click="grid.appScope.seleccionar_fila(row.entity)"><i class="fa fa-check "></i></a>'
		btGridP = '<a class="btn btn-xs btn-info" ng-click="grid.appScope.showSidenavSelectPC(row.entity)"><i class="fa fa-desktop "></i> <md-tooltip md-direction="right">Abrir en equipo</md-tooltip> </a>'
		btGrid4 = '<a class="btn btn-xs shiny btn-info" ng-click="grid.appScope.seleccionar_entidad(row.entity)" ng-bind="row.entity.entidad_id | nombreEntidad:grid.appScope.$parent.entidades:true"> <md-tooltip md-direction="left">{{row.entity.entidad_id | nombreEntidad:grid.appScope.$parent.entidades:false}}</md-tooltip> </a>'
		btGrid5 = '<a class="btn btn-xs btn-info" ng-click="grid.appScope.verRoles(row.entity)"><span ng-repeat="rol in row.entity.roles">{{rol.display_name}}-</span>  <md-tooltip md-direction="left">Modificar roles</md-tooltip> </a>'

		botones = '<div class="btn-group">' + btGrid1 + btGrid2 + btGrid3 + btGridP + '</div>'
		###
		if $scope.$parent.hasRoleOrPerm(['Admin'])
			botones =
		else
			botones = btGrid1 + btGrid3 + btGridP
		###

		# Quitamos unas columnas si es NO es admin
		columnDefs = []

		if ($(window).width() > 800)
			campo = if $scope.$parent.USER.rowid then 'rowid' else 'id'
			columnDefs.push( { field: campo, displayName: 'Id', width: 50, enableCellEdit: false } )

		if ($(window).width() > 800)
			columnDefs.push( { name: 'edicion', displayName:'Edición', width: 130, enableSorting: false, enableFiltering: false, cellTemplate: botones, enableCellEdit: false, enableColumnMenu: false} )
		else
			columnDefs.push( { name: 'edicion', displayName:'Edición', width: 100, enableSorting: false, enableFiltering: false, cellTemplate: botones, enableCellEdit: false, enableColumnMenu: false} )

		columnDefs.push( {
			field: 'nombres', filter: {condition: uiGridConstants.filter.CONTAINS}, minWidth: 100, enableHiding: false
			filter: {
				condition: (searchTerm, cellValue)->
					termino 	= window.removeAccents(searchTerm).toLowerCase()
					find 		= window.removeAccents(cellValue).toLowerCase()
					return (find.indexOf(termino) isnt -1)
			}
		} )

		columnDefs.push( {
			field: 'apellidos', filter: { condition: uiGridConstants.filter.CONTAINS }, minWidth: 90
			filter: {
				condition: (searchTerm, cellValue)->
					termino 	= window.removeAccents(searchTerm).toLowerCase()
					find 		= window.removeAccents(cellValue).toLowerCase()
					return (find.indexOf(termino) isnt -1)
			}
		} )

		if ($(window).width() > 800)
			columnDefs.push( { field: 'sexo', displayName:'Sex', width: 50 } )

		columnDefs.push( { field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', minWidth: 70} )
		columnDefs.push( {
				field: 'entidad_id', displayName:'Entidad', cellTemplate: btGrid4, enableCellEdit: false, minWidth: 80,
				sortingAlgorithm: (a, b, rowA, rowB)->
					# No funcionaaaaaa
					if (a == b) then return 0
					if (a < b) then return 1
					return 1
				,
				filter: {
					condition: (searchTerm, cellValue)->
						entidades 	= $scope.$parent.entidades
						termino 	= window.removeAccents(searchTerm).toLowerCase()

						res = $filter('nombreEntidad')(cellValue, entidades, true)
						res = window.removeAccents(res).toLowerCase()

						res2 = $filter('nombreEntidad')(cellValue, entidades)
						res2 = window.removeAccents(res2).toLowerCase()

						return (res.indexOf(termino) isnt -1) or (res2.indexOf(termino) isnt -1)
				}
			}
		)


		if $scope.$parent.hasRoleOrPerm(['Admin', 'Ejecutor']) and $(window).width() > 800
			columnDefs.push( { field: 'roles', displayName:'Roles', cellTemplate: btGrid5, enableCellEdit: false, minWidth: 70 } )



		if ($(window).width() <= 800)
			$scope.gridOptions =
				multiSelect: false,
				enebleGridColumnMenu: false,
				enableRowHeaderSelection: false
		else
			$scope.gridOptions =
				selectedItems: $scope.currentusers,
				multiSelect: true,
				enableSelectAll: true,


		$scope.gridOptions.showGridFooter 	= true
		$scope.gridOptions.enableSorting 	= true
		$scope.gridOptions.enableFiltering 	= true
		$scope.gridOptions.enableRowSelection 	= true
		$scope.gridOptions.columnDefs 		= columnDefs
		$scope.gridOptions.onRegisterApi 	= ( gridApi ) ->

			$scope.gridApi = gridApi

			gridApi.selection.on.rowSelectionChanged($scope, (rows)->
				$scope.currentusers = gridApi.selection.getSelectedRows()
			)
			gridApi.selection.on.rowSelectionChangedBatch($scope, (rows)->
				$scope.currentusers = gridApi.selection.getSelectedRows()
			)

			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue
					if colDef.field == "sexo"
						if newValue != 'M' and newValue != 'F'
							toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
							$scope.$apply()
							return

					Restangular.one('usuarios/update').customPUT(rowEntity).then((r)->
						toastr.success 'Usuario actualizado con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)




		Restangular.all('usuarios').getList().then((data)->
			$scope.usuarios = data;
			$scope.gridOptions.data = $scope.usuarios
		)


		$scope.cambiaInscripcion = (categoria, currentUsers)->

			categoria.cambiando = true

			datos =
				usuarios: 		[]
				categoria_id: 	categoria.categoria_id

			for currentUser in currentUsers
				user_id = if currentUser.rowid then currentUser.rowid else currentUser.id
				datos.usuarios.push {user_id: user_id}


			if categoria.selected

				Restangular.one('inscripciones/inscribir-varios').customPUT(datos).then((r)->

					for currentUser in currentUsers
						for inscrip in r
							user_id = if currentUser.rowid then currentUser.rowid else currentUser.id
							if inscrip.user_id == user_id

								found = $filter('filter')(currentUser.inscripciones, {categoria_id: inscrip.categoria_id})

								if found.length == 0
									currentUser.inscripciones.push inscrip
								else
									insc_id = if inscrip.rowid then inscrip.rowid else inscrip.id
									found[0].id         = insc_id
									found[0].rowid      = insc_id
									found[0].deleted_at = inscrip.deleted_at



					categoria.cambiando = false
				, (r2)->
					toastr.warning 'No se inscribó el usuario', 'Problema'
					categoria.cambiando = false
					categoria.selected = false
				)

			else

				Restangular.one('inscripciones/desinscribir-varios').customPUT(datos).then((r)->
					categoria.cambiando = false

					for usua in currentUsers
						usua.inscripciones = $filter('filter')(usua.inscripciones, {categoria_id: '!'+categoria.categoria_id})

				, (r2)->
					toastr.warning 'No se quitó inscripción', 'Problema'
					categoria.cambiando = false
					categoria.selected = true
				)










		return
	]
)



.controller('RemoveUsuarioCtrl', ['$scope', '$uibModalInstance', 'usuario', 'entidades', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, entidades, Restangular, toastr)->
	$scope.usuario = usuario
	$scope.entidades = entidades

	$scope.ok = ()->

		user_id = if usuario.rowid then usuario.rowid else usuario.id
		promesa = if usuario.rowid then Restangular.all('usuarios/destroy').customPUT({user_id: user_id}) else Restangular.all('usuarios/destroy').customDELETE(user_id)

		promesa.then((r)->
			toastr.success 'Usuario eliminado con éxito.', 'Eliminado'
			$modalInstance.close(usuario)
		, (r2)->
			toastr.warning 'No se pudo eliminar al usuario.', 'Problema'
			console.log 'Error eliminando usuario: ', r2
			$modalInstance.dismiss('Error')
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('SelectEntidadCtrl', ['$scope', '$uibModalInstance', 'usuario', 'entidades', 'Restangular', 'toastr', '$filter', ($scope, $modalInstance, usuario, entidades, Restangular, toastr, $filter)->
	$scope.usuario = usuario
	$scope.entidades = entidades
	$scope.entidades_extras = $filter('filter')(entidades, {id: '!'+usuario.entidad_id})

	$scope.seleccionar = (entidad)->
		user_id = if usuario.rowid then usuario.rowid else usuario.id


		entidad_id = if entidad.rowid then entidad.rowid else entidad.id

		datos =
			user_id: user_id
			entidad_id: entidad_id

		Restangular.all('usuarios/cambiar-entidad').customPUT(datos).then((r)->
			toastr.success 'Entidad cambiada con éxito.', entidad.alias
			$modalInstance.close(entidad_id)
		, (r2)->
			toastr.warning 'No se pudo cambiar entidad.', 'Problema'
			$modalInstance.dismiss('Error')
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




.controller('VerRolesCtrl', ['$scope', '$uibModalInstance', 'usuario', 'roles', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, roles, Restangular, toastr)->
	$scope.usuario = usuario
	$scope.roles = roles
	user_id = if usuario.rowid then usuario.rowid else usuario.id

	$scope.datos = {selecteds: []}

	$scope.datos.selecteds = usuario.roles


	$scope.seleccionando = ($item, $model)->

		codigos =
			user_id: user_id
			role_id: $item.id

		Restangular.one('roles/add-role-to-user').customPUT(codigos).then((r)->
			toastr.success 'Rol agregado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo agregar el rol al usuario.', 'Problema'
			console.log 'No se pudo agregar el rol al usuario.: ', r2
		)

	$scope.quitando = ($item, $model)->

		Restangular.one('roles/remove-role-to-user').customPUT({role_id: $item.id, user_id: user_id}).then((r)->
			toastr.success 'Rol quitado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo quitar el rol al usuario.', 'Problema'
			console.log 'No se pudo quitar el rol al usuario.: ', r2
		)


	$scope.ok = ()->
		usuario.roles = $scope.datos.selecteds
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

