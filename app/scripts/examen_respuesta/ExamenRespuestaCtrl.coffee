angular.module('WissenSystem')

.controller('ExamenRespuestaCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$modal', 'App', '$rootScope', 'resolved_user', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, $rootScope, resolved_user)->

	$scope.USER = resolved_user
	
	if !$rootScope.examen_actual
		console.log 'No hay examen actual'


		



])

