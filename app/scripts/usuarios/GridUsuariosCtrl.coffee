angular.module('WissenSystem')

.controller('GridUsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'uiGridConstants', '$modal', '$filter', 'App' 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, uiGridConstants, $modal, $filter, App) ->

		$scope.currentusers = []
		
		$scope.inscripcion_rapida = (row)->
			console.log 'Presionado para inscripción rápida fila: ', row
			$scope.currentuser 	= row


		$scope.editando = false
		$scope.editar = (row)->
			console.log 'Presionado para editar fila: ', row
			$scope.currentuser = row
			$scope.editando = false


		$scope.eliminar = (row)->
			console.log 'Presionado para eliminar fila: ', row

			modalInstance = $modal.open({
				templateUrl: App.views + 'usuarios/removeAlumno.tpl.html'
				controller: 'RemoveUsuariosCtrl'
				resolve: 
					usuarios: ()->
						row
			})
			modalInstance.result.then( (alum)->
				$scope.usuarios = $filter('filter')($scope.usuarios, {alumno_id: '!'+alum.alumno_id})
				console.log 'Resultado del modal: ', alum
			)



		btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
		btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
		btGrid3 = '<a tooltip="Inscripciones" tooltip-placement="left" class="btn btn-primary btn-xs shiny icon-only info" ng-click="grid.appScope.inscripcion_rapida(row.entity)"><i class="fa fa-map-marker "></i></a>'


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
				{ name: 'edicion', displayName:'Edición', width: 90, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2 + btGrid3, enableCellEdit: false, enableColumnMenu: false}
				{ field: 'nombres', filter: {condition: uiGridConstants.filter.CONTAINS}, enableHiding: false }
				{ field: 'apellidos', filter: { condition: uiGridConstants.filter.CONTAINS }}
				{ field: 'sexo', width: 60 }
				{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario'}
				{ field: 'email', enableCellEdit: false, filter: { condition: uiGridConstants.filter.CONTAINS }}
				{ field: 'cell', displayName:'Celular', filter: { condition: uiGridConstants.filter.CONTAINS }}
				{ field: 'edad' }
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
							$scope.toastr.success 'Usuario actualizado con éxito', 'Actualizado'
						, (r2)->
							$scope.toastr.error 'Cambio no guardado', 'Error'
							console.log 'Falló al intentar guardar: ', r2
						)
					$scope.$apply()
				)


		Restangular.all('usuarios').getList().then((data)->
			$scope.usuarios = data;
			$scope.gridOptions.data = $scope.usuarios
		)


		$scope.cambiaInscripcion = (categoriaking, currentUsers)->
			
			categoriaking.cambiando = true

			datos = 
				usuarios: 		[]
				categoria_id: 	categoriaking.id

			for currentUser in currentUsers
				datos.usuarios.push {user_id: currentUser.id}
				

			if categoriaking.selected
			
				Restangular.one('inscripciones/inscribir-varios').customPUT(datos).then((r)->
					
					for currentUser in currentUsers
						for inscrip in r

							if inscrip.user_id == currentUser.id

								found = $filter('filter')(currentUser.inscripciones, {categoria_id: inscrip.categoria_id})

								if found.length == 0
									currentUser.inscripciones.push inscrip



					categoriaking.cambiando = false
					console.log 'Usuarios inscritos: ', currentUsers
				, (r2)->
					toastr.warning 'No se inscribó el usuario', 'Problema'
					console.log 'No se inscribó el usuario ', r2
					categoriaking.cambiando = false
					categoriaking.selected = false
				)

			else
				
				Restangular.one('inscripciones/desinscribir-varios').customPOST(datos).then((r)->
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



.controller('RemoveUsuarioCtrl', ['$scope', '$modalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento
	console.log 'elemento', elemento

	$scope.ok = ()->

		Restangular.all('users/destroy').customDELETE(elemento.id).then((r)->
			toastr.success 'Usuario eliminado con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
			$modalInstance.dismiss('Error')
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


