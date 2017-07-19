'use strict'

angular.module('WissenSystem')

# Este archivo lo estoy compartiendo con el estado ver_todos_los_examenes_por_entidades y ver_todos_los_examenes
.controller('VerTodosLosExamenesCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'examenes',  
	($scope, Restangular, toastr, $filter, $uibModal, App, examenes) ->

		$scope.examenes = examenes

	]
)

.controller('VerTodosLosExamenesPorEntCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'entidades',  
	($scope, Restangular, toastr, $filter, $uibModal, App, entidades) ->

		$scope.entidades = entidades

	]
)


