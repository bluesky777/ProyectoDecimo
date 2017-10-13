angular.module('WissenSystem')

.directive('timerDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/timerDir.tpl.html"
	scope: 
		tiempomax: "="

	controller: 'TimerCtrl'
		

])

.controller('TimerCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$state', '$rootScope', '$interval', 'Perfil', ($scope, Restangular, toastr, $filter, $state, $rootScope, $interval, Perfil)->

	$rootScope.tiempo 		= -1
	$rootScope.tiempo_preg 	= 0
	$scope.tiempo 			= $rootScope.tiempo;  


	$rootScope.dt_start_exam = 0
	$rootScope.dt_start_preg = 0


		 
	$scope.start = ()->

		$interval.cancel($rootScope.promiseInterval)

		$rootScope.dt_start_exam = Date.now() # Momento en que inicia el cronómetro
		$rootScope.dt_start_preg = $rootScope.dt_start_exam # Para calcular por pregunta

		$rootScope.promiseInterval = $interval(()-> 

			if $scope.$parent.waiting_question
				$scope.stop()
			else
				
				if !$rootScope.pause_tiempo
				
					diff_exam 		= Date.now() - $rootScope.dt_start_exam; # milliseconds elapsed since start
					diff_preg 		= Date.now() - $rootScope.dt_start_preg; # milliseconds elapsed since start
					
					$rootScope.tiempo 		= diff_exam
					$rootScope.tiempo_preg 	= diff_preg
					#$scope.tiempo 			= $rootScope.tiempo
					$scope.tiempo_seg 		= Math.floor(diff_exam / 1000)

					n = new Date(diff_exam); #llevar todo a milisegundos 

					segundos 	= n.getSeconds()
					minutos 	= n.getMinutes()

					segundos 	= if segundos < 10 then '0'+segundos else segundos
					minutos 	= if minutos < 10 then '0'+minutos else minutos

					$scope.tiempo_formateado = minutos + ':' + segundos

					#console.log $scope.$parent.USER, $scope.tiempo, ($scope.tiempo*60000), $scope.duracion_exam < ($scope.tiempo*60000)

					if $scope.$parent.USER.evento_actual.gran_final
						
						if $rootScope.examen_actual.duracion_preg*1000 <= $rootScope.tiempo
							$scope.stop()
							$scope.$emit 'tiempo_preg_terminado'

					else
						#console.log 'No gran final', $rootScope.examen_actual.duracion_exam, $scope.tiempo, $rootScope.examen_actual.duracion_exam < ($scope.tiempo)

						if $rootScope.examen_actual.duracion_exam*60*1000 < $rootScope.tiempo

							$scope.stop()
							$scope.$emit 'tiempo_exam_terminado'

				else # Tengo que hacer algo si está el tiempo pausado
					# Pero aún no sé

		, 100)



	$scope.start()

	$scope.stop = ()->
		$interval.cancel($rootScope.promiseInterval)


	$scope.$on 'next_question', (event)->
		$rootScope.tiempo = 0

		if $scope.$parent.USER.evento_actual.gran_final
			$scope.start()


	$scope.$on 'goto_question_no', (event)->
		$rootScope.tiempo = 0 

		if $scope.$parent.USER.evento_actual.gran_final
			$scope.start()




	


	
	

])

