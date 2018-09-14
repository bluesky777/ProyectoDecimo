'use strict'

angular.module('WissenSystem')


.controller('ExamenDetalleCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'examen', '$location', '$anchorScroll', '$timeout',
	($scope, Restangular, toastr, $filter, $uibModal, App, examen, $location, $anchorScroll, $timeout) ->

		$scope.imagesPath = App.images

		$scope.examen     = examen

		for respuesta in $scope.examen.respuestas
			respuesta.created_at = new Date(respuesta.created_at)

		###
		$timeout(()->
			$location.hash('cuadro-para-scroll');
			$anchorScroll();
		, 1000)
		###

	]
)



