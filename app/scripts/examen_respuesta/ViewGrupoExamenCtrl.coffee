angular.module('WissenSystem')

.controller('ViewGrupoExamenCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$rootScope', '$state', '$uibModal', 'App', ($scope, Restangular, toastr, $filter, $rootScope, $state, $modal, App)->

	
	$scope.USER = $scope.$parent.USER

	$scope.idioma = $scope.USER.idioma_main_id
	
	$scope.examen_actual = $rootScope.examen_actual


	$scope.elegirOpcion = (pregunta, opcion, indice)->
		angular.forEach pregunta.opciones, (opt)->
			opt.elegida = false

		opcion.elegida = true



		if $scope.examen_actual.one_by_one

			opcion.letra = $scope.indexChar(indice)

			modalInstance = $modal.open({
				templateUrl: App.views + 'examen_respuesta/seguroRespuesta.tpl.html'
				controller: 'SeguroRespuestaPregKingCtrl'
				resolve: 
					preguntatop: ()->
						$scope.grupoking
					pregunta_traduc: ()->
						pregunta
					opcion: ()->
						opcion
					examen_actual: ()->
						$scope.examen_actual
					agrupada: ()->
						true
			})
			modalInstance.result.then( (option)->
				opcion.respondida = true
				$scope.$emit 'respuesta_elegida', indice
				toastr.success 'Respuestuesta guardada'
			)
			
	
	$scope.indexChar = (index)->
		return String.fromCharCode(65 + index)

	$scope.toggleMostrarAyuda = (pregunta)->
		pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda

		


])



.directive('viewGrupoExamen',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/viewGrupoExamenDir.tpl.html"
	scope: 
		grupoking: 	"="
		indice: 	"=" 
		idiomapreg:	"=" 

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'ViewGrupoExamenCtrl'
		

])






