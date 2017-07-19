'use strict'

angular.module('WissenSystem')


.controller('VerExamenesPorEntidadesCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'entidades',  
	($scope, Restangular, toastr, $filter, $uibModal, App, entidades) ->

		$scope.entidades = entidades

	]
)


