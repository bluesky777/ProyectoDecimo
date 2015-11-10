angular.module('WissenSystem')

.directive('timerDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/timerDir.tpl.html"
	scope: 
		tiempomax: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'TimerCtrl'
		

])

.controller('TimerCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$state', '$rootScope', '$interval', 'Perfil', ($scope, Restangular, toastr, $filter, $state, $rootScope, $interval, Perfil)->

	$rootScope.tiempo = 58
	$scope.tiempo = $rootScope.tiempo;   


	$scope.gran_final = $scope.$parent.USER.evento_actual.gran_final 
	$scope.duracion_exam = $rootScope.examen_actual.duracion_exam 
	$scope.duracion_preg = $rootScope.examen_actual.duracion_preg 
		 
	
	$interval(()-> 



		$rootScope.tiempo++
		$scope.tiempo = $rootScope.tiempo

		n = new Date($rootScope.tiempo * 1000); #llevar todo a milisegundos 

		segundos = n.getSeconds()
		minutos = n.getMinutes()

		segundos = if segundos < 10 then '0'+segundos else segundos
		minutos = if minutos < 10 then '0'+minutos else minutos

		$scope.tiempo_formateado = minutos + ':' + segundos

		#console.log $scope.$parent.USER, $scope.tiempo, ($scope.tiempo*60000), $scope.duracion_exam < ($scope.tiempo*60000)

		if $scope.gran_final

			if $scope.duracion_preg < ($scope.tiempo*1000) # tiempo de milis a segundos

				$scope.$emit 'tiempo_preg_terminado'

		else
			

			if $scope.duracion_exam < ($scope.tiempo*60000) # tiempo de milis a segundos

				$scope.$emit 'tiempo_exam_terminado'




	, 1000, 0)


	
	

])

