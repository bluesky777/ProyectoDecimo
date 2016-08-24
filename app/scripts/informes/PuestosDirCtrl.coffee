'use strict'

angular.module('WissenSystem')

.directive('puestosDir',['App', (App)-> 
	restrict: 'E'
	templateUrl: "#{App.views}informes/puestosDir.tpl.html"
	controller: 'PuestosDirCtrl'
])


.controller('PuestosDirCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'MySocket', 'SocketData' , '$uibModal', 'App',  
	($scope, Restangular, toastr, $filter, MySocket, SocketData, $uibModal, App) ->

		$scope.SocketData 	= SocketData
		$scope.mostrando 	= false; # 'todos', 'por_entidades', 'por_entidades_categorias', 'por_categorias'
		$scope.sortType     = 'promedio'; 
		$scope.sortReverse  = false;  
		$scope.searchExam   = ''; 
		$scope.gran_final	= true;


		$scope.traerTodosLosExamenes = ()->
			Restangular.all('informes/todos-los-examenes').getList({gran_final: $scope.gran_final}).then((r)->
				$scope.examenes = r
				$scope.mostrando = 'todos';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes', 'Problema'
				console.log 'No se trajeron los exámenes ', r2
			)

		$scope.traerExamenesEntidades = ()->
			Restangular.all('informes/examenes-entidades').getList({gran_final: $scope.gran_final}).then((r)->
				$scope.entidades = r
				$scope.mostrando = 'por_entidades';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes por entidad', 'Problema'
				console.log 'No se trajeron los exámenes por entidad', r2
			)
		
		$scope.traerExamenesEntidadesCategorias = ()->
			Restangular.all('informes/examenes-entidades-categorias').getList({gran_final: $scope.gran_final}).then((r)->
				$scope.entidades = r
				$scope.mostrando = 'por_entidades_categorias';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes por entidad y categorías', 'Problema'
				console.log 'No se trajeron los exámenes por entidad y categorías ', r2
			)
		
		
		$scope.traerExamenesCategorias = ()->
			Restangular.all('informes/examenes-categorias').getList({gran_final: $scope.gran_final}).then((r)->
				$scope.categorias = r
				$scope.mostrando = 'por_categorias';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes por entidad y categorías', 'Problema'
				console.log 'No se trajeron los exámenes por entidad y categorías ', r2
			)

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
				$scope.examenes 	= $filter('filter')($scope.examenes, {examen_id: '!'+r.id })

				entidad = $filter('filter')($scope.entidades, {entidad_id: examen.entidad_id })[0]
				
				if entidad
					if entidad.examenes
						entidad.examenes 	= $filter('filter')(entidad.examenes, {examen_id: '!'+r.id })
				
				
					if entidad.categorias
						categoria 			= $filter('filter')(entidad.categorias, {categoria_id: examen.categoria_id })[0]
						categoria.examenes 	= $filter('filter')(categoria.examenes, {examen_id: '!'+r.id })
				
				categoria 	= $filter('filter')($scope.categorias, {categoria_id: examen.categoria_id })[0]
				if categoria
					if categoria.examenes
						categoria.examenes = $filter('filter')(categoria.examenes, {examen_id: '!'+r.id })
				
			)


		#$scope.traerExamenesCategorias()

		

	]
)


