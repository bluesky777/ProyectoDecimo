'use strict'

angular.module('WissenSystem')


.controller('VerTodosLosExamenesCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'examenes',  
	($scope, Restangular, toastr, $filter, $uibModal, App, examenes) ->

		$scope.examenes = examenes

	]
)


