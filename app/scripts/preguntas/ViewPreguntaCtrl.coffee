angular.module('WissenSystem')

.controller('ViewPreguntaCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$mdToast', '$modal',
	($scope, App, Restangular, $state, $cookies, $rootScope, $mdToast, $modal) ->

		$scope.elegirOpcion = (pregunta, opcion)->
			angular.forEach pregunta.opciones, (opt)->
				opt.elegida = false

			opcion.elegida = true

		$scope.toggleMostrarAyuda = (pregunta)->
			pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda



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
			modalInstance.result.then( (alum)->
				$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
				console.log 'Resultado del modal: ', alum
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

		Restangular.all('preguntasking/destroy/'+pregunta.id).remove().then((r)->
			toastr.success 'Pregunta eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la pregunta.', 'Problema'
			console.log 'Error eliminando pregunta: ', r2
		)
		$modalInstance.close(pregunta)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





.filter('porIdioma', [ ->
	(input, idioma) ->


		if input
			
			resultado = []

			idioma = parseFloat(idioma)

			for elemento in input

				idioma_id = parseFloat(elemento.idioma_id)
				
				if idioma == idioma_id
					resultado.push elemento

			return resultado
		else
			return false
])



