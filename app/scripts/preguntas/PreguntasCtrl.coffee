'use strict'

angular.module('WissenSystem')

.controller('PreguntasCtrl', ['$scope', 'App', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'preguntasServ', '$filter', '$timeout', '$uibModal', 
	($scope, App, $http, Restangular, $state, $cookies, $rootScope, toastr, preguntasServ, $filter, $timeout, $modal) ->

		$scope.pg_preguntas = []
		$scope.evalu_seleccionada = {id: -1}


		$scope.creando 		= false
		$scope.editando 	= false
		$scope.editandoContenido = false
		$scope.inicializado = false # Se inicializa cuando haya respuesta por preguntas
		$scope.preguntaEdit = {}
		$scope.contenidoEdit = {}

		$scope.showDetail 	= false
		$scope.showOptions 	= false
		$scope.showCorrects = false
		$scope.categoria 	= 0
		$scope.evaluacion_id = 0
		$scope.preguntas_evaluacion = []

		$scope.categorias 	= []


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

		$scope.traerDatos = ()->

			# Las categorias
			Restangular.all('categorias/categorias-usuario').getList().then((r)->
				$scope.categorias = r

				if $scope.categorias.length > 0

					if localStorage.getItem("selected_categpreg") == null
						localStorage.setItem('selected_categpreg', r[0].id)
						$scope.categoria = r[0].id # Que se Seleccione la primera opción
					else
						$scope.categoria = localStorage.getItem("selected_categpreg")

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
			Restangular.all('preguntas').getList({categoria_id: $scope.categoria, idioma_id: $scope.idiomaPreg.selected}).then((r)->
				$scope.pg_preguntas = r
				$scope.pg_preguntas = $filter('pregsByCatsAndEvaluacion')($scope.pg_preguntas, $scope.categoria, $scope.preguntas_evaluacion, $scope.evaluacion_id)
				$scope.inicializado = true
			, (r2)->
				console.log 'Pailas la promesa de las preguntas ', r2
				$scope.inicializado = true
			)


		$scope.filtrarPreguntas = ()->
			$scope.pg_preguntas	= $filter('pregsByCatsAndEvaluacion')($scope.pg_preguntas, $scope.categoria, $scope.preguntas_evaluacion, $scope.evaluacion_id)
			

		$scope.cambiarRutaImagenes = ()->
			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/cambiarRutaImagenes.tpl.html'
				controller: 'CambiarRutaImagenes'
			})
			modalInstance.result.then( (elem)->
				console.log 'Rutas Cambiadas'
			)


		$scope.traerPreguntasYEvaluaciones = ()->
			localStorage.setItem('selected_categpreg', $scope.categoria)
			$scope.traerPreguntas()
			$scope.traerEvaluaciones()


		$scope.traerPreguntasDeEvaluacion = ()->

			if $scope.evaluacion_id == 'sin_asignar'
				Restangular.all('pregunta_evaluacion/solo-sin-asignar').getList({categoria_id: $scope.categoria}).then((r)->
					$scope.pg_preguntas = r
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

			found = $filter('filter')($scope.evaluaciones, {id: evalu.id}, true )

			if found.length > 0
				$scope.preguntas_evaluacion2 = found[0].preguntas_evaluacion





		$scope.$on 'finalizaEdicionPreg', (elem)->
			#console.log 'elem', elem


		$scope.$on 'preguntaQuitada', (e, elem)->
			$scope.preguntas_evaluacion2 = $filter('filter')($scope.preguntas_evaluacion2, {id: "!" + elem})
			console.log 'Recibido quitada', elem, 


		$scope.$on 'grupoEliminado', (e, elem)->
			$scope.pg_preguntas = $filter('filter')($scope.pg_preguntas, (pregunta_king, index)->

				if pregunta_king.tipo_pregunta # No la eliminamos si es una preguntaking que tiene tipo_pregunta
					return true
				else if pregunta_king.id != elem.id
					return true
				else
					return false
			)

	]
)



.controller('CambiarRutaImagenes', ['$scope', '$uibModalInstance', 'Restangular', 'toastr', ($scope, $modalInstance, Restangular, toastr)->
	
	$scope.ruta_anterior 	= 'http://192.168.0.10'
	$scope.ruta_nueva 		= 'http://' + localStorage.getItem('dominio')


	Restangular.all('preguntas/con-imagenes').getList().then((r)->
		$scope.preguntas = r
	, (r2)->
		toastr.warning 'No se trajeron las preguntas con imágenes.', 'Problema'
	)

	$scope.ok = ()->

		$scope.cambiando = true

		datos = 
			ruta_anterior: 	$scope.ruta_anterior
			ruta_nueva: 	$scope.ruta_nueva

		Restangular.one('perfiles/cambiar-ruta-imagenes').customPUT(datos).then((r)->
			toastr.success 'Rutas cambiadas.'
			$modalInstance.close(datos)
		, (r2)->
			toastr.warning 'No se pudo cambiar rutas.', 'Problema'
			console.log 'Error cambiando rutas: ', r2
			$scope.cambiando = false
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




.filter('pregsByCatsAndEvaluacion', ['$filter', ($filter)->
	(input, categoria, preguntas_evaluacion, evaluacion_id) ->
		
		filtered = [];
		angular.forEach(input, (item)->
			filtered.push(item);
		)

		
		resultado = []

		for preg in filtered
	
			if parseFloat(preg.categoria_id) == parseFloat(categoria)

				if evaluacion_id and parseFloat(evaluacion_id) != 0

					found = false

					if preg.tipo_pregunta
						found = $filter('filter')(preguntas_evaluacion, {pregunta_id: preg.pg_id}, true)
					else
						found = $filter('filter')(preguntas_evaluacion, {grupo_pregs_id: preg.pg_id}, true)

					if found
						if found.length > 0
							preg.pregunta_eval_id 	= found[0].id
							preg.orden 				= found[0].orden
							resultado.push preg

				else
					resultado.push preg

		return resultado
])








