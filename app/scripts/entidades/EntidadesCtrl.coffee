angular.module('WissenSystem')
.controller('EntidadesCtrl', ['$scope', 'Restangular', 'uiGridConstants', 'App', '$filter', '$uibModal', 'toastr', ($scope, Restangular, uiGridConstants, App, $filter, $modal, toastr)->
	

	$scope.imgSystemPath = App.imgSystemPath
	$scope.perfilPath = App.perfilPath
	$scope.creando = false
	$scope.editando = false




	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'

	btGrid2 = if $scope.hasRoleOrPerm(['Admin']) then btGrid2 else ''

	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', width: 50, enableCellEdit: false, enableColumnMenu: false}
			{ name: 'edit', displayName:'Edit', width: 70, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'logo_nombre', displayName:'Logo', cellTemplate: "<img width=\"35px\" ng-src=\"{{grid.appScope.perfilPath + grid.getCellValue(row, col)}}\">", width: 40}
			{ field: 'nombre', filter: {condition: uiGridConstants.filter.CONTAINS}, enableHiding: false }
			{ field: 'alias', width: 70, filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Alias'}
			{ field: 'lider_nombre', displayName:'Lider', filter: { condition: uiGridConstants.filter.CONTAINS }}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					Restangular.one('entidades/update').customPUT(rowEntity).then((r)->
						toastr.success 'Entidad actualizada con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)


	Restangular.all('entidades').getList().then((data)->
		$scope.gridOptions.data = data;
	)

	Restangular.all('imagenes').getList().then((data)->
		$scope.imagenes = data;
	)


	$scope.editar = (entidad)->
		$scope.creando 			= false
		$scope.editando 		= true
		$scope.currentEntidad 	= entidad
		$scope.currentEntidad.logo = {id: entidad.logo_id, nombre: entidad.logo_nombre, publica: entidad.publica}

	$scope.eliminar = (entidad)->
		modalInstance = $modal.open({
			templateUrl: App.views + 'eventos/removeEvento.tpl.html'
			controller: 'RemoveEntidadCtrl'
			resolve: 
				elemento: ()->
					entidad
		})
		modalInstance.result.then( (elem)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+elem.id})
			console.log 'Resultado del modal: ', elem
		)


	$scope.crearNuevo = ()->
		$scope.creando = true
		$scope.editando = false

	$scope.cancelarNuevo = ()->
		$scope.creando = false
		$scope.guardando = false

	$scope.cancelarEdit = ()->
		$scope.editando = false

	$scope.guardando = false
	$scope.guardar_nuevo = ()->
		$scope.guardando = true

		Restangular.one('entidades/store').customPOST($scope.newEntidad).then((r)->
			console.log('Entidad guardado', r)
			$scope.gridOptions.data.push r
			$scope.guardando = false
			$scope.creando = false
			toastr.success 'Entidad guardada con éxito.', 'Creado'

			# Reiniciamos las variables del nuevo entidad.
			$scope.newEntidad = {
				nombre: ''
				lider_nombre: ''
			}
		, (r2)->
			console.log('No se pudo guardar el entidad', r2)
			toastr.warning 'No se pudo crear entidad.', 'Problema'
			$scope.guardando = false
		)
		

	$scope.guardando_cambios = false
	$scope.guardar_cambios = ()->
		$scope.guardando_cambios = true

		$scope.currentEntidad.logo_id = $scope.currentEntidad.logo.id

		Restangular.one('entidades/update').customPUT($scope.currentEntidad).then((r)->

			$scope.guardando_cambios = false
			$scope.editando = false
			toastr.success 'Entidad guardada con éxito.', 'Creado'

			# Reiniciamos las variables del nuevo entidad.
			$scope.newEntidad = {
				nombre: ''
				lider_nombre: ''
			}
		, (r2)->
			console.log('No se pudo guardar entidad', r2)
			toastr.warning 'No se pudo crear entidad.', 'Problema'
			$scope.guardando_cambios = false
		)
		


	return

])



.controller('RemoveEntidadCtrl', ['$scope', '$uibModalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento

	$scope.ok = ()->

		Restangular.all('entidades/destroy').customDELETE(elemento.id).then((r)->
			toastr.success 'Entidad eliminada con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar elemento.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
			$modalInstance.dismiss('cancel')
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


