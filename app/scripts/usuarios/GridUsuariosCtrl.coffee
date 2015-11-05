angular.module('WissenSystem')

.controller('GridUsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$interval', 'toastr', 'uiGridConstants', '$modal', '$filter', 'App' 
	($scope, $http, Restangular, $state, $cookies, $interval, toastr, uiGridConstants, $modal, $filter, App) ->

		$scope.currentusers = []
		$scope.currentuser = {}

		
		$scope.seleccionar_fila = (row)->
			$scope.gridApi.selection.clearSelectedRows()
			$scope.gridApi.selection.selectRow(row)
			$scope.currentuser = row

		$scope.seleccionar_entidad = (row)->
			console.log 'Presionado para cambiar entidad: ', row

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
				console.log 'Resultado del modal: ', entidad_id
			)


		$scope.editando = false
		$scope.editar = (row)->
			$scope.gridApi.selection.clearSelectedRows()
			$scope.gridApi.selection.selectRow(row)

			$scope.$parent.currentUser = row
			$scope.currentusers = [row]
			$scope.$parent.editando = true



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
				$scope.usuarios = $filter('filter')($scope.usuarios, {id: '!'+usuario.id})
				console.log 'Resultado del modal: ', usuario
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
				console.log 'Resultado del modal: ', user
			)


		btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs " ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
		btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-xs btn-danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a> '
		btGrid3 = '<a tooltip="Seleccionar" tooltip-placement="right" class="btn btn-xs btn-info" ng-click="grid.appScope.seleccionar_fila(row.entity)"><i class="fa fa-check "></i></a>'
		btGrid4 = '<a tooltip="{{row.entity.entidad_id | nombreEntidad:grid.appScope.$parent.entidades:false}}" tooltip-placement="left" class="btn btn-xs shiny btn-info" ng-click="grid.appScope.seleccionar_entidad(row.entity)" ng-bind="row.entity.entidad_id | nombreEntidad:grid.appScope.$parent.entidades:true"></a>'
		btGrid5 = '<a tooltip="Modificar roles" tooltip-placement="left" class="btn btn-xs btn-info" ng-click="grid.appScope.verRoles(row.entity)"><span ng-repeat="rol in row.entity.roles">{{rol.display_name}}-</span></a>'


		$scope.gridOptions = 
			showGridFooter: true,
			enableSorting: true,
			enableFiltering: true,
			#enebleGridColumnMenu: false,
			selectedItems: $scope.currentusers,
			multiSelect: true, 
			enableRowSelection: true,
			enableSelectAll: true,
			columnDefs: [
				{ field: 'id', displayName:'Id', width: 60, enableCellEdit: false, enableColumnMenu: false}
				{ name: 'edicion', displayName:'Edición', width: 100, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2 + btGrid3, enableCellEdit: false, enableColumnMenu: false}
				{ field: 'nombres', filter: {condition: uiGridConstants.filter.CONTAINS}, enableHiding: false }
				{ field: 'apellidos', filter: { condition: uiGridConstants.filter.CONTAINS }}
				{ field: 'sexo', width: 60 }
				{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario'}
				{ 
					field: 'entidad_id', displayName:'Entidad', cellTemplate: btGrid4, enableCellEdit: false, 
					filter: { 
						condition: (searchTerm, cellValue)-> 
							entidades = $scope.$parent.entidades
							termino = searchTerm.toLowerCase()

							res = $filter('nombreEntidad')(cellValue, entidades, true)
							res = res.toLowerCase()
							
							res2 = $filter('nombreEntidad')(cellValue, entidades)
							res2 = res2.toLowerCase()

							return res.indexOf(termino) isnt -1 or res2.indexOf(termino) isnt -1
					}
				}
				{ field: 'roles', displayName:'Roles', cellTemplate: btGrid5, enableCellEdit: false }
			],
			#filterOptions: $scope.filterOptions,
			onRegisterApi: ( gridApi ) ->

				$scope.gridApi = gridApi

				gridApi.selection.on.rowSelectionChanged($scope, (rows)->
					$scope.currentusers = gridApi.selection.getSelectedRows()
				)
				gridApi.selection.on.rowSelectionChangedBatch($scope, (rows)->
					$scope.currentusers = gridApi.selection.getSelectedRows()
				)

				gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
					console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
					
					if newValue != oldValue
						Restangular.one('usuarios/update', rowEntity.id).customPUT(rowEntity).then((r)->
							toastr.success 'Usuario actualizado con éxito', 'Actualizado'
						, (r2)->
							toastr.error 'Cambio no guardado', 'Error'
							console.log 'Falló al intentar guardar: ', r2
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
				datos.usuarios.push {user_id: currentUser.id}
				

			if categoria.selected
			
				Restangular.one('inscripciones/inscribir-varios').customPUT(datos).then((r)->
					
					for currentUser in currentUsers
						for inscrip in r

							if inscrip.user_id == currentUser.id

								found = $filter('filter')(currentUser.inscripciones, {categoria_id: inscrip.categoria_id})

								if found.length == 0
									currentUser.inscripciones.push inscrip
								else
									found[0].id = inscrip.id
									found[0].deleted_at = inscrip.deleted_at



					categoria.cambiando = false
					console.log 'Usuarios inscritos: ', currentUsers
				, (r2)->
					toastr.warning 'No se inscribó el usuario', 'Problema'
					console.log 'No se inscribó el usuario ', r2
					categoria.cambiando = false
					categoria.selected = false
				)

			else
				
				Restangular.one('inscripciones/desinscribir-varios').customPUT(datos).then((r)->
					#$scope.usuarios.push r
					categoria.cambiando = false
					#console.log 'Usuario creado', r

					for usua in currentUsers
						usua.inscripciones = $filter('filter')(usua.inscripciones, {categoria_id: '!'+categoria.categoria_id})

				, (r2)->
					toastr.warning 'No se quitó inscripción', 'Problema'
					console.log 'No se quitó inscripción ', r2
					categoria.cambiando = false
					categoria.selected = true
				)
				


		






		return
	]
)



.controller('RemoveUsuarioCtrl', ['$scope', '$modalInstance', 'usuario', 'entidades', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, entidades, Restangular, toastr)->
	$scope.usuario = usuario
	$scope.entidades = entidades
	console.log 'elemento', usuario, entidades

	$scope.ok = ()->

		Restangular.all('usuarios/destroy').customDELETE(usuario.id).then((r)->
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


.controller('SelectEntidadCtrl', ['$scope', '$modalInstance', 'usuario', 'entidades', 'Restangular', 'toastr', '$filter', ($scope, $modalInstance, usuario, entidades, Restangular, toastr, $filter)->
	$scope.usuario = usuario
	$scope.entidades = entidades
	$scope.entidades_extras = $filter('filter')(entidades, {id: '!'+usuario.entidad_id})

	console.log 'elementos', usuario, entidades

	$scope.seleccionar = (entidad)->

		datos =
			user_id: $scope.usuario.id
			entidad_id: entidad.id

		Restangular.all('usuarios/cambiar-entidad').customPUT(datos).then((r)->
			toastr.success 'Entidad cambiada con éxito.', entidad.alias
			$modalInstance.close(entidad.id)
		, (r2)->
			toastr.warning 'No se pudo cambiar entidad.', 'Problema'
			console.log 'Error cambiando elemento: ', r2
			$modalInstance.dismiss('Error')
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




.controller('VerRolesCtrl', ['$scope', '$modalInstance', 'usuario', 'roles', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, roles, Restangular, toastr)->
	$scope.usuario = usuario
	$scope.roles = roles

	$scope.datos = {selecteds: []}

	$scope.datos.selecteds = usuario.roles


	$scope.seleccionando = ($item, $model)->

		codigos = 
			user_id: usuario.id
			role_id: $item.id

		console.log $scope.datos.selecteds, $item

		Restangular.one('roles/add-role-to-user').customPUT(codigos).then((r)->
			toastr.success 'Rol agregado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo agregar el rol al usuario.', 'Problema'
			console.log 'No se pudo agregar el rol al usuario.: ', r2
		)

	$scope.quitando = ($item, $model)->
		console.log $item, $model

		Restangular.one('roles/remove-role-to-user').customPUT({role_id: $item.id, user_id: usuario.id}).then((r)->
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

