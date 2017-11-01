angular.module('WissenSystem')

.controller('ViewPreguntaEvalCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$mdToast', '$uibModal', '$filter', 'toastr',
	($scope, App, Restangular, $state, $cookies, $rootScope, $mdToast, $modal, $filter, toastr) ->
		

		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)


		$scope.actualizarOrdenPregEval = (preguntaking)->

			Restangular.all('pregunta_evaluacion/actualizar-orden-pregunta').customPUT({ pg_id: preguntaking.pg_id, orden: preguntaking.orden_nuevo, pregunta_eval_id: preguntaking.pregunta_eval_id }).then((r)->
				toastr.success 'Ordenado con éxito.'
			, (r2)->
				toastr.warning 'No se pudo ordenar.', 'Problema'
				console.log 'Error ordenando pregunta: ', r2
				$scope.quitando = false
			)



		$scope.quitarPregunta = (pregunta_king)->
			console.log 'Aqui quito la preg', pregunta_king.pregunta_eval_id, $scope.preguntasevaluacion2

			$scope.quitando = true

			datos = 
				pregunta_id: pregunta_king.id
				evaluacion_id: $scope.selected
				pregunta_eval_id: pregunta_king.pregunta_eval_id

			Restangular.all('pregunta_evaluacion/quitar-pregunta').customPUT(datos).then((r)->
				toastr.success 'Pregunta quitada con éxito.'
				$scope.quitando = false

				$scope.$emit 'preguntaQuitada', pregunta_king.pregunta_eval_id
			, (r2)->
				toastr.warning 'No se pudo asignar la pregunta.', 'Problema'
				console.log 'Error asignando pregunta: ', r2
				$scope.quitando = false
			)


	]
)


