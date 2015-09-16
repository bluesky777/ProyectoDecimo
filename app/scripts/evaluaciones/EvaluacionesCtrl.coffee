angular.module('WissenSystem')
.controller('EvaluacionesCtrl', ['$scope', 'Restangular', 'App', 'toastr', ($scope, Restangular, App, toastr)->
	

	$scope.comprobar_evento_actual = ()->
		if $scope.evento_actual

			if $scope.evento_actual.idioma_principal_id

				$scope.idioma = {
					selected: $scope.evento_actual.idioma_principal_id
				}
		else
			toastr.warning 'Pimero debes crear o seleccionar un evento actual'


	$scope.comprobar_evento_actual()

	$scope.$on 'cambio_evento_user', ()->
		$scope.comprobar_evento_actual()

	$scope.$on 'cambia_evento_actual', ()->
		$scope.comprobar_evento_actual()



	$scope.imgSystemPath = App.imgSystemPath
	$scope.perfilPath = App.perfilPath
	$scope.creando = false
	$scope.editando = false
	$scope.newEvaluacion = {}
	$scope.currentEvalua = {}
	$scope.categorias_king = []



	Restangular.all('categorias/categorias-usuario').getList().then((data)->
		$scope.categorias_king = data
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
		Restangular.one('evaluaciones/store').customPOST($scope.newEvaluacion).then((r)->
			$scope.evaluaciones.push r
			console.log $scope.evaluaciones
			$scope.guardando = false
			$scope.creando = false
			toastr.success 'Evaluación guardada con éxito'
			console.log 'Evaluación guardada con éxito', r
		(r2)->
			toastr.warning 'Evaluación guardada con éxito'
			$scope.guardando = false
			console.log 'No se pudo guardar la evaluación', r2
		)
		

	return

])

