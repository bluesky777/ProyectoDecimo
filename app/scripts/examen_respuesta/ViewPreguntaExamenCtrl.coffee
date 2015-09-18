angular.module('WissenSystem')

.controller('ViewPreguntaExamenCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$modal', 'App', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App)->

	
	$scope.USER = $scope.$parent.USER

	$scope.idioma = $scope.USER.idioma_main_id
	
	$scope.elegirOpcion = (pregunta, opcion)->
		angular.forEach pregunta.opciones, (opt)->
			opt.elegida = false

		opcion.elegida = true

		

	$scope.indexChar = (index)->
		return String.fromCharCode(65 + index)




])



angular.module('WissenSystem')

.directive('viewPreguntaExamen',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/viewPreguntaExamenDir.tpl.html"
	scope: 
		preguntaking: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'ViewPreguntaExamenCtrl'
		

])



