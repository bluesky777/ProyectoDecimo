angular.module('WissenSystem')

.controller('ExamenRespuestaCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$uibModal', 'App', '$rootScope', 'resolved_user', '$interval', '$timeout', 'MySocket', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, $rootScope, resolved_user, $interval, $timeout, MySocket)->

	$scope.USER = resolved_user
	$scope.imagesPath = App.images
	$scope.pregunta_actual = 0
	$scope.pregunta_actual_porc = 0
	$scope.total_preguntas = 0
	$scope.cambiarTema('theme-one')
	$scope.waiting_question = false

	AuthService.verificar_acceso()




	$scope.incializar = ()->

		if !$rootScope.examen_actual
			console.log 'No hay examen actual'
			$state.transitionTo 'panel' 
		else if !$rootScope.examen_actual.id
			console.log 'Examen no válido', $rootScope.examen_actual
			$state.transitionTo 'panel' 


		$scope.categoria_traducida = $filter('categoriasTraducidas')([$rootScope.examen_actual.categoria], $scope.USER.idioma_main_id)
		if $scope.categoria_traducida.length > 0
			$scope.categoria_traducida = $scope.categoria_traducida[0]


		$scope.examen_actual = $rootScope.examen_actual


		# *************************************************
		# Evantos del examen
		# *************************************************

		$scope.$on 'respuesta_elegida', (event, indice)->

			if $scope.USER.evento_actual.gran_final
				$scope.waiting_question = true
			$timeout(()->
				$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
				$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100

				$scope.check_por_terminado()

			, 500)

			



		$scope.$on 'tiempo_preg_terminado', (event)->
			console.log 'Tiempo pregunta terminado'
			$scope.waiting_question = true
			MySocket.sc_answered 'incorrect', $rootScope.tiempo

			preg_check = $filter('preguntaActual')($scope.examen_actual.preguntas)
			if preg_check.length == 1
				pregs_trad = $filter('porIdioma')(preg_check[0].preguntas_traducidas, $scope.USER.idioma_main_id)
				if pregs_trad.length > 0
					if pregs_trad[0].opciones.length > 0
						pregs_trad[0].opciones[0].respondida = true
					else
						toastr.warning 'No hay opciones para esta pregunta'
						console.log 'No hay opciones para esta pregunta', pregs_trad[0]
					datos = 
						examen_actual_id: 		$scope.examen_actual.examen_id
						pregunta_top_id: 		preg_check[0].id
						pregunta_sub_id: 		pregs_trad[0].id
						idioma_id: 				pregs_trad[0].idioma_id
						tipo_pregunta: 			preg_check[0].tipo_pregunta
						tiempo:					$rootScope.tiempo

					ruta = 'examenes_respuesta/responder-pregunta'
					Restangular.all(ruta).customPUT(datos).then((r)->
						console.log 'Guardado el time out'
					, (r2)->
						toastr.warning 'No se pudo guardar respuesta.', 'Problema'
						console.log 'No se pudo guardar respuesta: ', r2
					)

				else
					toastr.warning 'No hay traducción para esta pregunta'
					console.log 'No hay traducción para esta pregunta', preg_check[0]

			$scope.check_por_terminado()

		$scope.$on 'tiempo_exam_terminado', (event)->
			console.log 'Tiempo examen terminado'
			$state.go 'panel'




		destroy_next_question = $rootScope.$on 'next_question', (event)-> # Hay otro listening en TimerDir
			if $scope.waiting_question != false
				pregtemp = $filter('preguntaActual')($scope.examen_actual.preguntas, $scope.pregunta_actual)[0]
				pregunta = $filter('filter')($scope.examen_actual.preguntas, {pregunta_id: pregtemp.pregunta_id})[0]
				console.log pregunta
				$scope.waiting_question = false

		destroy_goto_question_on = $rootScope.$on 'goto_question_no', (event, numero)->
			console.log numero
			if $scope.waiting_question != false
				$scope.pregunta_actual = numero
				pregtemp = $filter('preguntaActual')($scope.examen_actual.preguntas, numero)[0]
				pregunta = $filter('filter')($scope.examen_actual.preguntas, {pregunta_id: pregtemp.pregunta_id})[0]
				console.log pregunta
				$scope.waiting_question = false



		$scope.$on('$destroy', ()->
			window.onbeforeunload = undefined
			destroy_next_question() # remove listener.
			destroy_goto_question_on()
		);



		# *************************************************
		# Configuramos tiempo y cantidad
		# *************************************************

		$scope.tiempo_max = if $scope.USER.evento_actual.gran_final then $rootScope.examen_actual.duracion_preg else ($rootScope.examen_actual.duracion_exam*60)


		$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
		$scope.total_preguntas = $filter('cantPregsEvaluacion')($scope.examen_actual.preguntas)
		$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100
		




	if $state.params.examen_respuesta_id

		dato =
			exa_resp_id: $state.params.examen_respuesta_id

		Restangular.all('examenes_respuesta/continuar').customPUT(dato).then((r)->
			$rootScope.examen_actual = r
			terminado = $scope.check_por_terminado()

			if not terminado
				toastr.success 'Continuamos el examen.'
				$scope.incializar()
		, (r2)->
			toastr.warning 'No se pudo continuar el examen.', 'Problema'
			console.log 'Error continuando el examen: ', r2
		)
	else
		$scope.incializar()



	$scope.check_por_terminado = ()->

		preg_check = $filter('preguntaActual')($scope.examen_actual.preguntas)
		if preg_check.length == 1
			if preg_check[0].terminado
				console.log 'Todas las respuestas contestadas', preg_check
				toastr.success 'Examen terminado'
				$state.go 'panel'
				return true
		return false



	$scope.finalizar_examen = ()->

		console.log 'Finalizar examen'

	###	
	$scope.$on('$locationChangeStart', ( event, param1, param2 )->
		answer = confirm("No debes salir del examen, ¿Seguro de continuar?")
		if (!answer)
			event.preventDefault()
	);
	###




])

