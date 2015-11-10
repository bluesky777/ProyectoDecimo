angular.module('WissenSystem')

.controller('ExamenRespuestaCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$modal', 'App', '$rootScope', 'resolved_user', '$interval', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, $rootScope, resolved_user, $interval)->

	$scope.USER = resolved_user
	$scope.imagesPath = App.images
	$scope.pregunta_actual = 0
	$scope.pregunta_actual_porc = 0
	$scope.total_preguntas = 0
	$scope.cambiarTema('theme-one')



	$scope.incializar = ()->

		if !$rootScope.examen_actual
			console.log 'No hay examen actual'
			$state.transitionTo 'panel' 
		else if !$rootScope.examen_actual.id
			console.log 'Examen no válido', $rootScope.examen_actual
			$state.transitionTo 'panel' 


		$scope.$on '$destroy', ()->
			console.log 'En destrucción!'
			window.onbeforeunload = undefined

		$scope.categoria_traducida = $filter('categoriasTraducidas')([$rootScope.examen_actual.categoria], $scope.USER.idioma_main_id)
		if $scope.categoria_traducida.length > 0
			$scope.categoria_traducida = $scope.categoria_traducida[0]


		$scope.examen_actual = $rootScope.examen_actual


		# *************************************************
		# Evantos del examen
		# *************************************************

		$scope.$on 'respuesta_elegida', (event, indice)->
			$scope.pregunta_actual = $scope.pregunta_actual + 1
			$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100
			console.log 'pregunta_actual_porc', $scope.pregunta_actual_porc


		$scope.$on 'tiempo_preg_terminado', (event)->
			console.log 'Tiempo pregunta terminado'

		$scope.$on 'tiempo_exam_terminado', (event)->
			console.log 'Tiempo examen terminado'





		# *************************************************
		# Configuramos tiempo y cantidad
		# *************************************************

		$scope.tiempo_max = if $scope.USER.gran_final then $rootScope.examen_actual.duracion_preg else $rootScope.examen_actual.duracion_exam
		$scope.tiempo_max = $scope.tiempo_max * 60
		#console.log '$scope.tiempo_max', $scope.tiempo_max, $rootScope.examen_actual


		$scope.pregunta_actual = $filter('noPregActual')($scope.examen_actual.preguntas)
		$scope.total_preguntas = $filter('cantPregsEvaluacion')($scope.examen_actual.preguntas)
		$scope.pregunta_actual_porc = $scope.pregunta_actual / $scope.total_preguntas * 100
		console.log 'no Preg Actual ', $scope.pregunta_actual, 'de', $scope.total_preguntas, $scope.pregunta_actual_porc




	if $state.params.examen_respuesta_id

		dato =
			exa_resp_id: $state.params.examen_respuesta_id

		Restangular.all('examenes_respuesta/continuar').customPUT(dato).then((r)->
			toastr.success 'Continuamos el examen.' 
			$rootScope.examen_actual = r
			$scope.incializar()
		, (r2)->
			toastr.warning 'No se pudo continuar el examen.', 'Problema'
			console.log 'Error continuando el examen: ', r2
		)
	else
		$scope.incializar()



	$scope.guardando = ()->

		console.log 'Guardando'



	$scope.finalizar_examen = ()->

		console.log 'Finalizar examen'

	



])

