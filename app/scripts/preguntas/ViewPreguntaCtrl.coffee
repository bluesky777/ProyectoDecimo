angular.module('WissenSystem')

.controller('ViewPreguntaCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$mdToast', '$modal', '$filter',
	($scope, App, Restangular, $state, $cookies, $rootScope, $mdToast, $modal, $filter) ->
		
		$scope.elegirOpcion = (pregunta, opcion)->
			angular.forEach pregunta.opciones, (opt)->
				opt.elegida = false

			opcion.elegida = true

		$scope.toggleMostrarAyuda = (pregunta)->
			pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda


		$scope.asignarExamen = ()->
			console.log "Asignando pregunta a un exámen"


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



.controller('RemovePreguntaCtrl', ['$scope', '$modalInstance', 'pregunta', 'Restangular', 'toastr', ($scope, $modalInstance, pregunta, Restangular, toastr)->
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





