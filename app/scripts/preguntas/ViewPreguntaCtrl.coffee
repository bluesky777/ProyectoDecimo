angular.module('WissenSystem')

.controller('ViewPreguntaCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$mdToast', '$uibModal', '$filter',
	($scope, App, Restangular, $state, $cookies, $rootScope, $mdToast, $modal, $filter) ->
		
		$scope.elegirOpcion = (pregunta, opcion)->
			angular.forEach pregunta.opciones, (opt)->
				opt.elegida = false

			opcion.elegida = true

		$scope.toggleMostrarAyuda = (pregunta)->
			pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda


		$scope.asignarAEvaluacion = (pregunta_king)->
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/asignarPregunta.tpl.html'
				controller: 'AsignarPreguntaCtrl'
				resolve: 
					pregunta: ()->
						pregunta_king
					evaluaciones: ()->
						$scope.evaluaciones
			})
			modalInstance.result.then( (elem)->
				#$scope.$emit 'preguntaAsignada', elem
				console.log 'Resultado del modal: ', elem
			)


		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)

			

		$scope.editarPregunta = (pregunta_king)->
			pregunta_king.editando = true


		$scope.eliminarPregunta = (pregunta)->
			console.log 'Presionado para eliminar fila: ', pregunta

			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/removePregunta.tpl.html'
				controller: 'RemovePreguntaCtrl'
				resolve: 
					pregunta: ()->
						pregunta
			})
			modalInstance.result.then( (elem)->
				$scope.$emit 'preguntaEliminada', elem
				console.log 'Resultado del modal: ', elem
			)


		$scope.previewPregunta = (pregunta_king)->
			if pregunta_king.showDetail == true
				pregunta_king.showDetail = false
			else
				pregunta_king.showDetail = true



	]
)


.controller('RemovePreguntaCtrl', ['$scope', '$uibModalInstance', 'pregunta', 'Restangular', 'toastr', ($scope, $modalInstance, pregunta, Restangular, toastr)->
	$scope.pregunta = pregunta

	$scope.ok = ()->

		Restangular.all('preguntas/destroy/'+pregunta.id).remove().then((r)->
			toastr.success 'Pregunta eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la pregunta.', 'Problema'
			console.log 'Error eliminando pregunta: ', r2
		)
		$modalInstance.close(pregunta)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('AsignarPreguntaCtrl', ['$scope', '$uibModalInstance', 'pregunta', 'evaluaciones', 'Restangular', 'toastr', '$filter', ($scope, $modalInstance, pregunta, evaluaciones, Restangular, toastr, $filter)->
	$scope.pregunta = pregunta
	$scope.evaluaciones = evaluaciones
	$scope.asignando = false
	$scope.selected = false

	$scope.ok = ()->

		$scope.asignando = true

		datos = 
			pregunta_id: pregunta.id
			evaluacion_id: $scope.selected

		Restangular.all('pregunta_evaluacion/asignar-pregunta').customPUT(datos).then((r)->
			toastr.success 'Pregunta asignada con éxito.'
			$scope.asignando = false

			evalua = $filter('filter')(evaluaciones, {id: $scope.selected})[0]
			evalua.preguntas_evaluacion.push r
			
			$modalInstance.close(r)
		, (r2)->
			toastr.warning 'No se pudo asignar la pregunta.', 'Problema'
			console.log 'Error asignando pregunta: ', r2
			$scope.asignando = false
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





