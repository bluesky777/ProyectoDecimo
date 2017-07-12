angular.module('WissenSystem')

.controller('ViewGrupoEvalCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', '$uibModal', '$filter',
	($scope, App, Restangular, $state, $cookies, $rootScope, toastr, $modal, $filter) ->
		
		$scope.quitando = false


			

		$scope.quitarPregunta = (pregunta_king)->
			
			$scope.quitando = true

			console.log pregunta_king, evaluacion = $filter('filter')($scope.$parent.evaluaciones, {grupo_pregs_id: pregunta_king.id})

			evaluacion = $filter('filter')($scope.$parent.evaluaciones, {grupo_pregs_id: pregunta_king.id})[0]

			datos = 
				pregunta_id: pregunta_king.id
				evaluacion_id: evaluacion.evaluacion_id
				pregunta_eval_id: pregunta_king.pregunta_eval_id

			Restangular.all('pregunta_evaluacion/quitar-pregunta').customPUT(datos).then((r)->
				toastr.success 'Pregunta quitada con éxito.'
				$scope.quitando = false

				$scope.$emit 'preguntaQuitada', pregunta_king.pregunta_eval_id
			, (r2)->
				toastr.warning 'No se pudo quitar la pregunta grupo.', 'Problema'
				console.log 'Error quitando pregunta: ', r2
				$scope.quitando = false
			)


	]
)













