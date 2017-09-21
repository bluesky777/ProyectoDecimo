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

		 
	$scope.start = ()->

		$interval.cancel($rootScope.promiseInterval)

		$rootScope.promiseInterval = $interval(()-> 

			
			if $scope.$parent.waiting_question
				$scope.stop()
			else
				if !$rootScope.pause_tiempo
					$rootScope.tiempo++
					$rootScope.tiempo_preg++
					$scope.tiempo = $rootScope.tiempo

					n = new Date($rootScope.tiempo * 1000); #llevar todo a milisegundos 

					segundos = n.getSeconds()
					minutos = n.getMinutes()

					segundos = if segundos < 10 then '0'+segundos else segundos
					minutos = if minutos < 10 then '0'+minutos else minutos

					$scope.tiempo_formateado = minutos + ':' + segundos

					#console.log $scope.$parent.USER, $scope.tiempo, ($scope.tiempo*60000), $scope.duracion_exam < ($scope.tiempo*60000)

					if $scope.$parent.USER.evento_actual.gran_final

						if $rootScope.examen_actual.duracion_preg <= $scope.tiempo
							$scope.stop()
							$scope.$emit 'tiempo_preg_terminado'

					else
						#console.log 'No gran final', $rootScope.examen_actual.duracion_exam, $scope.tiempo, $rootScope.examen_actual.duracion_exam < ($scope.tiempo)

						if $rootScope.examen_actual.duracion_exam*60 < $scope.tiempo

							$scope.stop()
							$scope.$emit 'tiempo_exam_terminado'

		, 1000, 0)



	$scope.start()

	$scope.stop = ()->
		$interval.cancel($rootScope.promiseInterval)


	$scope.$on 'next_question', (event)->
		$rootScope.tiempo = 0
		$scope.tiempo = $rootScope.tiempo;  

		if $scope.$parent.USER.evento_actual.gran_final
			$scope.start()


	$scope.$on 'goto_question_no', (event)->
		$rootScope.tiempo = 0
		$scope.tiempo = $rootScope.tiempo;  

		if $scope.$parent.USER.evento_actual.gran_final
			$scope.start()




	


	
	

])

