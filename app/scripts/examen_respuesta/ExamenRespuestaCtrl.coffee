angular.module('WissenSystem')

.controller('ExamenRespuestaCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$uibModal', 'App', '$rootScope', 'resolved_user', '$interval', '$timeout', 'MySocket', 'SocketData', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, $rootScope, resolved_user, $interval, $timeout, MySocket, SocketData)->

	$scope.USER 				= resolved_user
	$scope.imagesPath 			= App.images
	$scope.pregunta_actual 		= 0
	$scope.pregunta_actual_porc = 0
	$scope.total_preguntas 		= 0
	$scope.waiting_question 	= false
	$scope.opcion_eligida 		= ''
	$scope.cambiarTema('theme-one')

	AuthService.verificar_acceso()


	$interval(()->
		MySocket.emit('hasta_que_pregunta_esta_free')
	, 5000)


	$scope.incializar = ()->

		if !$rootScope.examen_actual
			console.log 'No hay examen actual'
			$state.transitionTo 'panel'
		else if !$rootScope.examen_actual.id and !$rootScope.examen_actual.rowid
			console.log 'Examen no válido', $rootScope.examen_actual
			$rootScope.permiso_de_salir = true
			$state.transitionTo 'panel'


		MySocket.emit('set_my_examen_id', { examen_actual_id: $rootScope.examen_actual.examen_id })


		$scope.categoria_traducida = $filter('categoriasTraducidas')([$rootScope.examen_actual.categoria], $scope.USER.idioma_main_id)
		if $scope.categoria_traducida.length > 0
			$scope.categoria_traducida = $scope.categoria_traducida[0]


		$scope.examen_actual = $rootScope.examen_actual


		# *************************************************
		# Eventos del examen
		# *************************************************

		$scope.$on 'respuesta_elegida', (event, indice, valor)->
			if valor
				if valor == 'incorrect'
					$scope.opcion_eligida = 'Incorrecta'
				else if valor == 'correct'
					$scope.opcion_eligida = 'Correcta'

			if $scope.USER.evento_actual.gran_final

				if SocketData.config.info_evento.free_till_question

					if SocketData.config.info_evento.free_till_question > $scope.pregunta_actual # Solo "mayor que" pues la pregunta actual no ha avanzado en este punto
						$scope.waiting_question = false
						$scope.$broadcast 'next_question' # Para reiniciar el tiempo
					else
						$scope.waiting_question = true
				else
					$scope.waiting_question = true

			llamado_preventivo = $timeout(()->
				$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
				$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100

				$scope.check_por_terminado()

			, 500)





		$scope.$on 'tiempo_preg_terminado', (event)->
			$scope.opcion_eligida = 'Incorrecta'
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

					preg_check_id = if preg_check[0].rowid then preg_check[0].rowid else preg_check[0].id
					preg_check_id = if pregs_trad[0].rowid then pregs_trad[0].rowid else pregs_trad[0].id

					datos =
						examen_actual_id: 		$scope.examen_actual.examen_id
						pregunta_top_id: 		preg_check_id
						pregunta_sub_id: 		pregs_trad_id
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

			$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
			$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100

			$scope.check_por_terminado()

		$scope.$on 'tiempo_exam_terminado', (event)->
			# Marcaremos el examen como terminado
			Restangular.all('examenes_respuesta/set-terminado').customPUT({ exa_id: $scope.examen_actual.examen_id, timeout: 1 }).then((r)->
				toastr.success 'Se te acabó el tiempo', 'Examen finalizado'
				$rootScope.permiso_de_salir = true
				$state.go 'panel'
			, (r2)->
				toastr.warning 'No se estableció como terminado.'
			)




		destroy_next_question = $rootScope.$on 'next_question', (event)-> # Hay otro listening en TimerDir
			if $scope.waiting_question != false
				$scope.siguiente_pregunta()



		destroy_goto_question_on = $rootScope.$on 'goto_question_no', (event, numero)->
			if $scope.waiting_question != false
				$scope.pregunta_actual 		= numero
				$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100

				pregtemp = $filter('preguntaActual')($scope.examen_actual.preguntas, numero)[0]
				pregunta = $filter('filter')($scope.examen_actual.preguntas, {pregunta_id: pregtemp.pregunta_id})[0]
				$scope.waiting_question = false
				$scope.$broadcast 'goto_question_no', numero


		destroy_set_free_till_question_on = $rootScope.$on 'set_free_till_question', (event, free_till_question)->
			$scope.$apply()
			if SocketData.config.info_evento.free_till_question
				if SocketData.config.info_evento.free_till_question >= $scope.pregunta_actual and $scope.waiting_question != false

					$scope.siguiente_pregunta()




		$scope.$on('$destroy', ()->
			window.onbeforeunload = undefined
			destroy_next_question() # remove listener.
			destroy_goto_question_on()
			destroy_set_free_till_question_on()

			if angular.isDefined(llamado_preventivo)
				$interval.cancel(llamado_preventivo)
				llamado_preventivo = undefined
		);



		# *************************************************
		# Configuramos tiempo y cantidad
		# *************************************************

		if !$scope.USER.evento_actual
			$scope.USER.evento_actual = $scope.evento_actual

		$scope.tiempo_max = if $scope.USER.evento_actual.gran_final then $rootScope.examen_actual.duracion_preg else ($rootScope.examen_actual.duracion_exam*60)
		console.log $scope.tiempo_max, '$scope.tiempo_max'

		$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
		$scope.total_preguntas = $filter('cantPregsEvaluacion')($scope.examen_actual.preguntas)
		$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100




	$scope.siguiente_pregunta = ()->
		$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
		$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100

		pregtemp = $filter('preguntaActual')($scope.examen_actual.preguntas, $scope.pregunta_actual)[0]
		pregunta = $filter('filter')($scope.examen_actual.preguntas, {pregunta_id: pregtemp.pregunta_id})[0]
		$scope.waiting_question = false
		$scope.$broadcast 'next_question'




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

				# Marcaremos el examen como terminado
				Restangular.all('examenes_respuesta/set-terminado').customPUT({ exa_id: $scope.examen_actual.examen_id }).then((r)->
					toastr.success 'Examen terminado'
					$rootScope.permiso_de_salir = true
					$state.go 'panel'
				, (r2)->
					toastr.warning 'No se estableció como terminado.'
				)

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

