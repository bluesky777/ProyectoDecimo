angular.module('WissenSystem')
.controller('EvaluacionesCtrl', ['$scope', 'Restangular', 'uiGridConstants', 'App', ($scope, Restangular, uiGridConstants, App)->
	

	$scope.imgSystemPath = App.imgSystemPath
	$scope.perfilPath = App.perfilPath
	$scope.creando = false
	$scope.editando = false

	$scope.imagenes = [
		{
			id: 1
			nombre: 'gato-dormido-ordenador.jpg'
			public: true
		}
		{
			id: 2
			nombre: 'gato-dormido-ordenador.jpg'
			public: true
		}
	]


	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'


	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', width: 50, enableCellEdit: false, enableColumnMenu: false}
			{ name: 'edit', displayName:'Edit', width: 60, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'nombre', filter: {condition: uiGridConstants.filter.CONTAINS}, enableHiding: false }
			{ field: 'alias', width: 70, filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Alias'}
			{ field: 'lider', filter: { condition: uiGridConstants.filter.CONTAINS }}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					Restangular.one('evaluaciones/update', rowEntity.id).customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Evaluaciones actualizada con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)


	Restangular.all('usuarios').getList().then((data)->
		$scope.gridOptions.data = data;
	)

	$scope.crearNuevo = ()->
		$scope.creando = true

	$scope.cancelarNuevo = ()->
		$scope.creando = false

	$scope.cancelarEdit = ()->
		$scope.editando = false

	$scope.guardando = false
	$scope.guardarNuevo = ()->
		$scope.guardando = true
		console.log('Evaluaciones guardada')
		$scope.guardando = false
		$scope.creando = false


	return

])

