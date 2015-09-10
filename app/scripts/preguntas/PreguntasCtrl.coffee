'use strict'

angular.module('WissenSystem')

.controller('PreguntasCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'preguntasServ', '$filter', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, preguntasServ, $filter) ->

		$scope.preguntas_king = []

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
		$scope.examen = 0

		$scope.preguntas_king = []
		$scope.categorias = []

		$scope.traerDatos = ()->

			# Las categorias
			Restangular.all('categorias/categorias-usuario').getList().then((r)->
				$scope.categorias = r

				if $scope.categorias.length > 0
					$scope.categoria = r[0].id # Que se Seleccione la primera opción

					$scope.traerExamenes()
					$scope.traerPreguntas()
			, (r2)->
				console.log 'No se trajeron las categorías ', r2
			)

			

		$scope.traerDatos()


		$scope.traerExamenes = ()->
			# Los exámenes
			Restangular.all('examenes').getList().then((r)->
				$scope.examenes = r
				if $scope.examenes.length > 0
					$scope.examen = r[0].id # Que se Seleccione la primera opción
			, (r2)->
				console.log 'No se trajeron los exámenes ', r2
			)


		$scope.traerPreguntas = ()->
			# Las preguntas
			Restangular.all('preguntas').getList({categoria_id: $scope.categoria}).then((r)->
				$scope.preguntas_king = r
				$scope.inicializado = true
			, (r2)->
				console.log 'Pailas la promesa de las preguntas ', r2
				$scope.inicializado = true
			)





		$scope.$on 'finalizaEdicionPreg', (elem)->
			#console.log 'elem', elem


		$scope.$on 'preguntaEliminada', (e, elem)->
			$scope.preguntas_king = $filter('filter')($scope.preguntas_king, {id: "!" + elem.id, tipo_pregunta: "!undefined" }, true)
			console.log 'Recibido eliminación', elem, $filter('filter')($scope.preguntas_king, {id: "!" + elem.id, tipo_pregunta: "!undefined" })


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



.filter('pregsByCats', [ ->
	(input, categoria) ->

		
		
		resultado = []

		for preg in input
	
			if parseFloat(preg.categoria_id) == parseFloat(categoria)
				resultado.push preg


		return resultado
])








