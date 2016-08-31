angular.module('WissenSystem')

.controller('ViewPreguntaCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$mdToast', '$uibModal', '$filter',
	($scope, App, Restangular, $state, $cookies, $rootScope, $mdToast, $modal, $filter) ->
		
		$scope.elegirOpcion = (pregunta, opcion)->
			angular.forEach pregunta.opciones, (opt)->
				opt.elegida = false

			opcion.elegida = true

		$scope.toggleMostrarAyuda = (pregunta)->
			pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda


		$scope.asignarAEvaluacion = (pg_pregunta)->
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/asignarPregunta.tpl.html'
				controller: 'AsignarPreguntaCtrl'
				resolve: 
					pregunta: ()->
						pg_pregunta
					evaluaciones: ()->
						$scope.evaluaciones
			})
			modalInstance.result.then( (elem)->
				console.log 'Resultado del modal: ', elem
			)


		$scope.cambiarCategoria = (pg_pregunta)->
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/cambiarCategoria.tpl.html'
				controller: 'CambiarCategoriaCtrl'
				resolve: 
					pregunta: ()->
						pg_pregunta
					categorias: ()->
						$scope.$parent.categorias
					idiomaPreg: ()->
						$scope.$parent.idiomaPreg
			})
			modalInstance.result.then( (elem)->
				#$scope.$emit 'preguntaAsignada', elem
				pg_pregunta.categoria_id = elem
				console.log 'Resultado del modal: ', elem
			)


		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)

			

		$scope.editarPregunta = (pg_pregunta)->
			$scope.$parent.$parent.preguntaEdit = pg_pregunta
			$scope.$parent.$parent.editando 	= true


		$scope.eliminarPregunta = (pregunta)->
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/removePregunta.tpl.html'
				controller: 'RemovePreguntaCtrl'
				resolve: 
					pregunta: ()->
						pregunta
			})
			modalInstance.result.then( (elem)->
				$scope.pg_preguntas = $filter('filter')($scope.pg_preguntas, {id: "!" + elem.pg_id, tipo_pregunta: "!undefined" }, true)
			)


		$scope.previewPregunta = (pg_pregunta)->
			pg_pregunta.showDetail = if pg_pregunta.showDetail then false else true


	]
)


.controller('RemovePreguntaCtrl', ['$scope', '$uibModalInstance', 'pregunta', 'Restangular', 'toastr', ($scope, $modalInstance, pregunta, Restangular, toastr)->
	$scope.pregunta = pregunta

	$scope.ok = ()->

		Restangular.all('preguntas/destroy/'+pregunta.pg_id).remove().then((r)->
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



.controller('CambiarCategoriaCtrl', ['$scope', '$uibModalInstance', 'pregunta', 'categorias', 'idiomaPreg', 'Restangular', 'toastr', '$filter', ($scope, $modalInstance, pregunta, categorias, idiomaPreg, Restangular, toastr, $filter)->
	$scope.categorias = categorias
	$scope.pregunta = pregunta
	$scope.idiomaPreg = idiomaPreg
	$scope.cambiando = false
	$scope.categoria = false


	$scope.ok = ()->

		$scope.cambiando = true

		datos = 
			pregunta_id: pregunta.id
			categoria_id: $scope.categoria

		Restangular.all('preguntas/cambiar-categoria').customPUT(datos).then((r)->
			toastr.success 'Pregunta cambiada de categoría.'
			$scope.cambiando = false

			$modalInstance.close(datos.categoria_id)
		, (r2)->
			toastr.warning 'No se pudo asignar la pregunta.', 'Problema'
			console.log 'Error asignando pregunta: ', r2
			$scope.cambiando = false
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





