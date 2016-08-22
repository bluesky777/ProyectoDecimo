'use strict'

angular.module('WissenSystem')

.directive('puestosDir',['App', (App)-> 
	restrict: 'E'
	templateUrl: "#{App.views}informes/puestosDir.tpl.html"
	controller: 'PuestosDirCtrl'
])


.controller('PuestosDirCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 
	($scope, Restangular, toastr, $filter) ->

		$scope.mostrando 	= false; # 'todos', 'por_entidades', 'por_entidades_categorias', 'por_categorias'
		$scope.sortType     = 'promedio'; 
		$scope.sortReverse  = false;  
		$scope.searchExam   = '';   


		$scope.traerTodosLosExamenes = ()->
			Restangular.all('informes/todos-los-examenes').getList().then((r)->
				$scope.examenes = r
				$scope.mostrando = 'todos';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes', 'Problema'
				console.log 'No se trajeron los exámenes ', r2
			)

		$scope.traerExamenesEntidades = ()->
			Restangular.all('informes/examenes-entidades').getList().then((r)->
				$scope.entidades = r
				$scope.mostrando = 'por_entidades';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes por entidad', 'Problema'
				console.log 'No se trajeron los exámenes por entidad', r2
			)
		
		$scope.traerExamenesEntidadesCategorias = ()->
			Restangular.all('informes/examenes-entidades-categorias').getList().then((r)->
				$scope.entidades = r
				$scope.mostrando = 'por_entidades_categorias';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes por entidad y categorías', 'Problema'
				console.log 'No se trajeron los exámenes por entidad y categorías ', r2
			)
		
		
		$scope.traerExamenesCategorias = ()->
			Restangular.all('informes/examenes-categorias').getList().then((r)->
				$scope.categorias = r
				$scope.mostrando = 'por_categorias';
			, (r2)->
				toastr.warning 'No se trajeron los exámenes por entidad y categorías', 'Problema'
				console.log 'No se trajeron los exámenes por entidad y categorías ', r2
			)

		$scope.traerExamenesCategorias()

		

	]
)


