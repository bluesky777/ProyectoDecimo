angular.module('WissenSystem')
.controller('GridEvaluacionesCtrl', ['$scope', 'Restangular', 'uiGridConstants', '$modal', '$filter', 'App', 'toastr', ($scope, Restangular, uiGridConstants, $modal, $filter, App, toastr)->



	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-xs btn-info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-xs btn-danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	cellcateg = '<span ng-bind="row.entity.categoria_id | nombreCategoria:grid.appScope.categoriasking:grid.appScope.idioma"></span>'
	cellactual = '<md-checkbox ng-true-value="1" ng-false-value="0" ng-model="row.entity.actual" ng-change="grid.appScope.setActual(row.entity)" aria-label="Actual" ng-disable="row.entity.actualizando" style="margin-top: 0px;">Actual</md-checkbox>'

	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', width: 60, enableCellEdit: false, enableColumnMenu: false}
			{ name: 'edit', displayName:'Edit', width: 80, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'descripcion', displayName:'Descripción', filter: {condition: uiGridConstants.filter.CONTAINS}, enableHiding: false }
			{ field: 'categoria_id', displayName:'Categoría', filter: { condition: uiGridConstants.filter.CONTAINS }, cellTemplate: cellcateg, enableCellEdit: false}
			{ field: 'actual', displayName:'Actual', width: 90, filter: { condition: uiGridConstants.filter.CONTAINS }, cellTemplate: cellactual, enableCellEdit: false}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					Restangular.one('evaluaciones/update').customPUT(rowEntity).then((r)->
						toastr.success 'Evaluaciones actualizada con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)


	Restangular.all('evaluaciones').getList().then((data)->
		$scope.evaluaciones = data
		$scope.gridOptions.data = $scope.evaluaciones;
	)


	$scope.setActual = (row)->
		row.actualizando = true
		console.log row

		Restangular.one('evaluaciones/set-actual').customPUT(row).then((r)->
			toastr.success 'Actualizado con éxito', 'Actualizado'
			row.actualizando = false
			
			elseRows = $filter('filter')($scope.evaluaciones, {categoria_id: row.categoria_id})

			for elserow in elseRows
				if elserow.id != row.id
					elserow.actual = 0

		, (r2)->
			toastr.warning 'No se cambió como actual o no'
			console.log 'No estableció como actual o no', r2
			row.actualizando = false
		)

	$scope.editar = (row)->
		$scope.$parent.creando = false
		$scope.$parent.editando = true
		$scope.$parent.currentEvaluacion = row

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'evaluaciones/removeEvaluacion.tpl.html'
			controller: 'RemoveEvaluacionCtrl'
			resolve: 
				elemento: ()->
					row
				categoriasking: ()->
					$scope.categoriasking
		})
		modalInstance.result.then( (elemento)->
			$scope.evaluaciones = $filter('filter')($scope.evaluaciones, {id: '!'+elemento.id})
			console.log 'Resultado del modal: ', elemento
		)



	return

])


.controller('RemoveEvaluacionCtrl', ['$scope', '$modalInstance', 'elemento', 'categoriasking', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, categoriasking, Restangular, toastr)->
	$scope.elemento = elemento
	$scope.categoriasking = categoriasking
	console.log 'elemento', elemento, categoriasking

	$scope.ok = ()->

		Restangular.all('evaluaciones/destroy').customDELETE(elemento.id).then((r)->
			toastr.success 'Evaluacion eliminada con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar evaluación.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
			$modalInstance.dismiss('Error')
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




