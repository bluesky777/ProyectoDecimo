'use strict'

angular.module('WissenSystem')

.directive('puestosDir',['App', (App)-> 
	restrict: 'E'
	templateUrl: "#{App.views}informes/puestosDir.tpl.html"
	controller: 'PuestosDirCtrl'
])


.controller('PuestosDirCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 
	($scope, Restangular, toastr, $filter) ->

		$scope.traerTodosLosExamenes = ()->
			Restangular.all('informes/todos-los-examenes').getList().then((r)->
				$scope.examenes = r
			, (r2)->
				toastr.warning 'No se trajeron los exámenes', 'Problema'
				console.log 'No se trajeron los exámenes ', r2
			)
		$scope.traerTodosLosExamenes()

		

	]
)


