'use strict'

angular.module('WissenSystem')

.controller('PreguntasCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'preguntasServ', '$filter', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, preguntasServ, $filter) ->


		$scope.preguntas_king = []
		$scope.evalu_seleccionada = {id: -1}


		$scope.grupo = 'grupo'
		$scope.king = 'king'

		$scope.comprobar_evento_actual = ()->
			if $scope.evento_actual

				if $scope.evento_actual.idioma_principal_id

					$scope.idiomaPreg = {
						selected: $scope.evento_actual.idioma_principal_id
					}
			else
				toastr.warning 'Pimero debes crear o seleccionar un evento actual'


		$scope.comprobar_evento_actual()

		$scope.$on 'cambio_evento_user', ()->
			$scope.comprobar_evento_actual()

		$scope.$on 'cambia_evento_actual', ()->
			$scope.comprobar_evento_actual()



		$scope.creando = false
		$scope.inicializado = false # Se inicializa cuando haya respuesta por preguntas

		$scope.showDetail = false
		$scope.categoria = 0
		$scope.evaluacion_id = 0

		$scope.preguntas_king = []
		$scope.preguntas_king2 = []
		$scope.categorias = []

		$scope.traerDatos = ()->

			# Las categorias
			Restangular.all('categorias/categorias-usuario').getList().then((r)->
				$scope.categorias = r

				if $scope.categorias.length > 0
					$scope.categoria = r[0].id # Que se Seleccione la primera opción

					$scope.traerEvaluaciones()
					$scope.traerPreguntas()
			, (r2)->
				console.log 'No se trajeron las categorías ', r2
			)

			

		$scope.traerDatos()


		$scope.traerEvaluaciones = ()->
			# Los exámenes
			Restangular.all('evaluaciones').getList({categoria_id: $scope.categoria}).then((r)->
				$scope.evaluaciones = r
				#if $scope.evaluaciones.length > 0
				#	$scope.evaluacion = r[0].id # Que se Seleccione la primera opción
			, (r2)->
				console.log 'No se trajeron las evaluaciones ', r2
			)


		$scope.traerPreguntas = ()->
			# Las preguntas
			Restangular.all('preguntas').getList({categoria_id: $scope.categoria}).then((r)->
				$scope.preguntas_king = r
				$scope.preguntas_king2 = r
				$scope.inicializado = true
				console.log '$scope.inicializado', $scope.inicializado
			, (r2)->
				console.log 'Pailas la promesa de las preguntas ', r2
				$scope.inicializado = true
			)



		$scope.traerPreguntasYEvaluaciones = ()->
			$scope.traerPreguntas()
			$scope.traerEvaluaciones()


		$scope.traerPreguntasDeEvaluacion = ()->

			if $scope.evaluacion_id == 'sin_asignar'
				Restangular.all('pregunta_evaluacion/solo-sin-asignar').getList({categoria_id: $scope.categoria}).then((r)->
					$scope.preguntas_king = r
				, (r2)->
					console.log 'No se trajo las preguntas sin asignar ', r2
					$scope.inicializado = true
				)

			else

				$scope.traerPreguntas()

				found = $filter('filter')($scope.evaluaciones, {id: $scope.evaluacion_id} )

				if found.length > 0
					$scope.preguntas_evaluacion = found[0].preguntas_evaluacion

				console.log '$scope.evaluacion', $scope.evaluacion_id, $scope.preguntas_evaluacion



		$scope.selectEvaluacion = (evalu, $event)->
			
			$scope.evalu_seleccionada = evalu

			for evaluacion in $scope.evaluaciones
				evaluacion.selected = false

			evalu.selected = true

			found = $filter('filter')($scope.evaluaciones, {id: evalu.id} )

			if found.length > 0
				$scope.preguntas_evaluacion2 = found[0].preguntas_evaluacion





		$scope.$on 'finalizaEdicionPreg', (elem)->
			#console.log 'elem', elem


		$scope.$on 'preguntaEliminada', (e, elem)->
			$scope.preguntas_king = $filter('filter')($scope.preguntas_king, {id: "!" + elem.id, tipo_pregunta: "!undefined" }, true)
			console.log 'Recibido eliminación', elem, $filter('filter')($scope.preguntas_king, {id: "!" + elem.id, tipo_pregunta: "!undefined" })


		$scope.$on 'preguntaQuitada', (e, elem)->
			$scope.preguntas_evaluacion2 = $filter('filter')($scope.preguntas_evaluacion2, {id: "!" + elem})
			console.log 'Recibido quitada', elem, 


		$scope.$on 'grupoEliminado', (e, elem)->
			$scope.preguntas_king = $filter('filter')($scope.preguntas_king, (pregunta_king, index)->

				if pregunta_king.tipo_pregunta # No la eliminamos si es una preguntaking que tiene tipo_pregunta
					return true
				else if pregunta_king.id != elem.id
					return true
				else
					return false
			)

	]
)



.filter('pregsByCatsAndEvaluacion', ['$filter', ($filter)->
	(input, categoria, preguntas_evaluacion, evaluacion_id) ->
		
		
		resultado = []

		for preg in input
	
			if parseFloat(preg.categoria_id) == parseFloat(categoria)
				
				if evaluacion_id and parseFloat(evaluacion_id) != 0

					found = false

					if preg.tipo_pregunta
						found = $filter('filter')(preguntas_evaluacion, {pregunta_id: preg.id})
					else
						found = $filter('filter')(preguntas_evaluacion, {grupo_pregs_id: preg.id})

					if found
						if found.length > 0
							preg.pregunta_eval_id 	= found[0].id
							preg.orden 				= found[0].orden
							resultado.push preg

				else
					resultado.push preg


		return resultado
])








