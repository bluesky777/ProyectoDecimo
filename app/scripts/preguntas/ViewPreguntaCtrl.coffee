angular.module('WissenSystem')

.controller('ViewPreguntaCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$location', '$anchorScroll', '$uibModal', '$filter', 'MySocket',
	($scope, App, Restangular, $state, $cookies, $rootScope, $location, $anchorScroll, $modal, $filter, MySocket) ->


		$scope.enviar_pregunta_pantalla = (pg_pregunta)->

			categ_found = {}
			for categ in $scope.$parent.categorias
				if categ.id == parseInt($scope.$parent.categoria)
					categ_found = categ
					categ_found = $filter('catsByIdioma')(categ.categorias_traducidas, $scope.$parent.idiomaPreg.selected)
					if categ_found.length > 0
						categ_found = categ_found[0]

			pregunta =
				descrip_categ: 		categ_found.descripcion
				enunciado: 			pg_pregunta.enunciado
				id: 				pg_pregunta.pg_id
				idioma: 			categ_found.idioma
				idioma_id: 			pg_pregunta.idioma_id
				nombre_categ:		categ_found.nombre
				cantidad_pregs:		-1
				opciones: 			pg_pregunta.opciones
				pregunta_id: 		pg_pregunta.pg_id
				tipo_pregunta: 		pg_pregunta.tipo_pregunta

			$scope.pregunta_mostrada = pregunta
			MySocket.sc_show_question(-1, pregunta)


		$scope.opcion_seleccionada = -1
		$scope.selec_opc_in_question = (opcion)->
			$scope.opcion_seleccionada = opcion
			MySocket.selec_opc_in_question(opcion)

		$scope.sc_reveal_answer = ()->
			if $scope.opcion_seleccionada < 0
				alert('Primero debes elegir opción.')
				return

			MySocket.sc_reveal_answer()

			for opcion, indice in $scope.pregunta_mostrada.opciones
				if indice == $scope.opcion_seleccionada
					if opcion.is_correct
						audio = new Audio('/sounds/Revelada_correcta.wav');
						audio.play();
					else
						audio = new Audio('/sounds/Revalada_incorrecta.wav');
						audio.play();



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
			$location.hash('content');
			$anchorScroll();


		$scope.eliminarPregunta = (pregunta)->
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/removePregunta.tpl.html'
				controller: 'RemovePreguntaCtrl'
				resolve:
					pregunta: ()->
						pregunta
			})
			modalInstance.result.then( (elem)->
				frescas = []
				for preg, indice in $scope.$parent.$parent.pg_preguntas
					if preg.pg_id != elem.pg_id
						frescas.push preg

				$scope.$parent.$parent.pg_preguntas = frescas
				$scope.$parent.$parent.filtrarPreguntas()
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

			# Si no es PHP, entonces a Electron
			Restangular.all('preguntas/destroy').customPUT({rowid: pregunta.pg_id}).then((r)->
				toastr.success 'Pregunta eliminada con éxito.', 'Eliminada'
			, (r2)->
				toastr.warning 'No se pudo eliminar la pregunta.', 'Problema'
				console.log 'Error eliminando pregunta: ', r2
			)

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

	$scope.selected = evaluaciones[evaluaciones.length - 1].id

	$scope.ok = ()->

		$scope.asignando = true

		datos =
			pregunta_id: pregunta.pg_id
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
	$scope.idiomaPreg = idiomaPreg
	$scope.cambiando = false
	$scope.categoria = false

	$scope.categoria = categorias[categorias.length - 1].id


	if Array.isArray(pregunta)
		$scope.preguntas = pregunta
	else
		$scope.pregunta = pregunta



	$scope.ok = ()->

		$scope.cambiando = true

		if $scope.preguntas

			promesas = $scope.preguntas.map (preg) ->

				datos =
					pregunta_id: preg.pg_id
					categoria_id: $scope.categoria

				restan = Restangular.all('preguntas/cambiar-categoria')
				promes = restan.customPUT(datos)
				return promes

			Promise.all(promesas).then((r)->
				toastr.success 'Preguntas cambiadas de categoría.'
				$scope.cambiando = false

				$modalInstance.close($scope.categoria)
			, (r2)->
				toastr.warning 'No se pudo asignar las preguntas.', 'Problema'
				console.log 'Error asignando preguntas: ', r2
				$scope.cambiando = false
			)


		else

			datos =
				pregunta_id: pregunta.pg_id
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





