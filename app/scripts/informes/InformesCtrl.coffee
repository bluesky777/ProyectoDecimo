'use strict'

angular.module('WissenSystem')

.controller('InformesCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'toastr', 'datos', '$filter', '$uibModal', 'App', 'MySocket',
	($scope, $http, Restangular, $state, $rootScope, toastr, datos, $filter, $uibModal, App, MySocket) ->

		$scope.eventos_infor 		= datos.eventos
		$scope.selected         = { entidades: [], categorias:[] }

		$scope.sortType         = 'promedio';
		$scope.sortReverse      = false;
		$scope.searchExam       = '';
		$scope.views            = App.views;
		$scope.imagesPath       = App.images;


		$scope.saveConfig = ()->
			localStorage.config = JSON.stringify($scope.config)


		if localStorage.config
			if localStorage.config.gran_final
				$scope.config.gran_final = false
			if localStorage.config.orientacion
				$scope.config.orientacion = 'vertical'
			if localStorage.config.todas_entidades
				$scope.config.todas_entidades = false
			if localStorage.config.todas_categorias
				$scope.config.todas_categorias = false

			$scope.config = JSON.parse(localStorage.config)

		else
			$scope.config =
				gran_final: 		false
				orientacion: 		'vertical'
				todas_entidades:	false
				todas_categorias: 	false
			$scope.saveConfig()

		if localStorage.requested_entidades
			$scope.selected.entidades = JSON.parse(localStorage.requested_entidades)

		if localStorage.requested_categorias
			$scope.selected.categorias = JSON.parse(localStorage.requested_categorias)


		for evento in $scope.eventos_infor
			if evento.actual
				$scope.selected.evento_id 	= evento.id
				$scope.selected.evento 		= evento
				$scope.selected.categorias_cargadas 	= evento.categorias



		$scope.cargar_entidades_categorias = ()->
			for evento in $scope.eventos_infor
				if evento.id == selected.evento_id
					$scope.selected.evento 		= evento
					$scope.selected.categorias_cargadas 	= evento.categorias



		$scope.cargar_evaluaciones = (categoria)->
			$scope.selected.categoria 		= categoria
			$scope.selected.evaluaciones 	= []

			for evaluac in categoria.evaluaciones
				if evaluac.actual
					$scope.selected.evaluacion = evaluac
					evaluac.selected = true

				$scope.selected.evaluaciones.push evaluac



		$scope.cargar_preguntas = (evaluacion)->
			$scope.selected.evaluacion 	= evaluacion
			$scope.selected.preguntas 	= []

			for evalu in $scope.selected.evaluaciones
				evalu.selected = if evaluacion==evalu then true else false

			for preguntasking in evaluacion.preguntas_evaluacion
				for preguntatraduc in preguntasking.preguntas_traducidas
					if preguntatraduc.idioma_id == $scope.USER.idioma_main_id
						preguntatraduc.tipo_pregunta 	= preguntasking.tipo_pregunta
						$scope.selected.preguntas.push preguntatraduc




		$scope.tabSeleccionado = (tab)->
			$scope.config.tab_seleccionado = tab
			$scope.saveConfig()

		$scope.$watch('config.orientacion', ()->
			$scope.saveConfig()
		)
		$scope.$watch('config.gran_final', ()->
			$scope.saveConfig()
		)
		$scope.$watch('config.todas_entidades', ()->
			$scope.saveConfig()
		)
		$scope.$watch('config.todas_categorias', ()->
			$scope.saveConfig()
		)




		$scope.cargarResultados = ()->
			Restangular.one('puestos/calcular-resultados').customPUT({ gran_final: $scope.config.gran_final, evento_id: $scope.selected.evento_id }).then((r)->
				toastr.success 'Calculados con éxito'
			, (r2)->
				toastr.error 'No se pudo calcular'
			)


		$scope.traerTodosLosExamenes = ()->
			$state.go('panel.informes.ver_todos_los_examenes', {gran_final: $scope.config.gran_final, evento_id: $scope.selected.evento_id })

		$scope.traerTodosLosExamenesPorEntidades = ()->
			if $scope.config.todas_entidades
				delete localStorage.requested_entidades
			else
				localStorage.requested_entidades = JSON.stringify($scope.selected.entidades)
			$state.go('panel.informes.ver_todos_los_examenes_por_entidades', {gran_final: $scope.config.gran_final, evento_id: $scope.selected.evento_id }, {reload: true})




		$scope.traerExamenesEntidadesCategorias = ()->

			if $scope.config.todas_entidades
				delete localStorage.requested_entidades
			else
				localStorage.requested_entidades = JSON.stringify($scope.selected.entidades)

			if $scope.config.todas_categorias
				delete localStorage.requested_categorias
			else
				localStorage.requested_categorias = JSON.stringify($scope.selected.categorias)

			$state.go('panel.informes.ver_examenes_por_entidades_categorias', {gran_final: $scope.config.gran_final, evento_id: $scope.selected.evento_id }, {reload: true})



		$scope.traerExamenesCategorias = ()->

			if $scope.config.todas_entidades
				delete localStorage.requested_entidades
			else
				localStorage.requested_entidades = JSON.stringify($scope.selected.entidades)

			if $scope.config.todas_categorias
				delete localStorage.requested_categorias
			else
				localStorage.requested_categorias = JSON.stringify($scope.selected.categorias)

			$state.go('panel.informes.ver_examenes_por_categorias', {gran_final: $scope.config.gran_final, evento_id: $scope.selected.evento_id }, {reload: true})


		$scope.traerExamenesCategoria = ()->
			if $scope.$parent.cmdCategSelected.id
				categoria_id = $scope.$parent.cmdCategSelected.id
				Restangular.all('informes/examenes-categoria').getList({gran_final: $scope.gran_final, categoria_id: categoria_id}).then((r)->
					$scope.categorias = r
					$scope.mostrando = 'por_categorias';
				, (r2)->
					toastr.warning 'No se trajeron los exámenes por entidad y categorías', 'Problema'
					console.log 'No se trajeron los exámenes por entidad y categorías ', r2
				)
			else
				toastr.warning 'Selecciona una categoría.'


		$scope.mostrarPuesto = (examen, puesto, entidad)->
			examen.puesto = puesto
			if entidad
				examen.logo_nombre 		= entidad.logo_nombre
				examen.alias_entidad 	= entidad.alias_entidad
				examen.nombre_entidad 	= entidad.nombre_entidad
				examen.lider_nombre 	= entidad.lider_nombre
			MySocket.sc_show_puntaje_examen(examen)


		$scope.eliminarExamen = (examen)->
			modalInstance = $uibModal.open({
				templateUrl: App.views + 'informes/seguroEliminExam.tpl.html'
				controller: 'SeguroEliminExamCtrl'
				resolve:
					examen: ()->
						examen
			})
			modalInstance.result.then( (r)->
				toastr.success 'Examen de ' + examen.nombres + ' ' + examen.apellidos + ' eliminado.'

				examen_id 				= if r.rowid then r.rowid else r.id
				$scope.examenes 	= $filter('filter')($scope.examenes, {examen_id: '!'+ examen_id})


				entidad = $filter('filter')($scope.entidades, {entidad_id: examen.entidad_id }, true)

				if entidad
					if entidad.length > 0
						entidad = entidad[0]

						if entidad.examenes
							entidad.examenes 	= $filter('filter')(entidad.examenes, {examen_id: '!'+examen_id })

						if entidad.categorias
							categoria 			= $filter('filter')(entidad.categorias, {categoria_id: examen.categoria_id })[0]
							categoria.examenes 	= $filter('filter')(categoria.examenes, {examen_id: '!'+examen_id })

				categoria 	= $filter('filter')($scope.categorias, {categoria_id: examen.categoria_id }, true)

				if categoria
					if categoria.length > 0
						categoria = categoria[0]
						if categoria.examenes
							categoria.examenes = $filter('filter')(categoria.examenes, {examen_id: '!'+examen_id })

			)



	]
)


