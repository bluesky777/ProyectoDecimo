angular.module('WissenSystem')

.controller('ViewPreguntaExamenCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$rootScope', '$state', '$modal', 'App', ($scope, Restangular, toastr, $filter, $rootScope, $state, $modal, App)->

	
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
						$scope.preguntaking
					pregunta_traduc: ()->
						pregunta
					opcion: ()->
						opcion
					examen_actual: ()->
						$scope.examen_actual
					agrupada: ()->
						return false
			})
			modalInstance.result.then( (option)->
				opcion.respondida = true
				$scope.$emit 'respuesta_elegida', indice
			)
			



	$scope.toggleMostrarAyuda = (pregunta)->
		pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda

		

	$scope.indexChar = (index)->
		return String.fromCharCode(65 + index)




])




.directive('viewPreguntaExamen',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/viewPreguntaExamenDir.tpl.html"
	scope: 
		preguntaking: 	"="
		indice: 		"=" 
		idiomapreg:		"=" 

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'ViewPreguntaExamenCtrl'
		

])




.controller('SeguroRespuestaPregKingCtrl', ['$scope', '$modalInstance', 'opcion', 'Restangular', 'toastr', '$filter', 'examen_actual', 'preguntatop', 'pregunta_traduc', 'agrupada', '$rootScope', ($scope, $modalInstance, opcion, Restangular, toastr, $filter, examen_actual, preguntatop, pregunta_traduc, agrupada, $rootScope)->

	$scope.opcion = opcion

	$scope.examen_actual = examen_actual

	datos = 
		examen_actual_id: 		examen_actual.id
		pregunta_top_id: 		preguntatop.id
		pregunta_sub_id: 		pregunta_traduc.id
		idioma_id: 				pregunta_traduc.idioma_id
		tipo_pregunta: 			preguntatop.tipo_pregunta
		opcion_id: 				opcion.id
		tiempo:					$rootScope.tiempo


	$scope.ok = ()->

		pregking = 'examenes_respuesta/responder-pregunta'
		grupopreg = 'examenes_respuesta/responder-pregunta-agrupada'

		ruta = if agrupada then grupopreg else pregking
		
		Restangular.all(ruta).customPUT(datos).then((r)->
			#toastr.success 'Iniciamos el examen.' 
			$modalInstance.close(r)
		, (r2)->
			toastr.warning 'No se pudo guardar respuesta.', 'Problema'
			console.log 'No se pudo guardar respuesta: ', r2
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



