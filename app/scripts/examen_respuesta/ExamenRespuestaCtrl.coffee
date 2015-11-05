angular.module('WissenSystem')

.controller('ExamenRespuestaCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$modal', 'App', '$rootScope', 'resolved_user', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, $rootScope, resolved_user)->

	$scope.USER = resolved_user
	$scope.imagesPath = App.images


	$scope.cambiarTema('theme-one')

	
	if !$rootScope.examen_actual
		console.log 'No hay examen actual'

	$scope.$on '$destroy', ()->
		console.log 'En destrucción!'
		window.onbeforeunload = undefined

	$scope.categoria_traducida = $filter('categoriasTraducidas')([$rootScope.examen_actual.categoria], $scope.USER.idioma_main_id)
	if $scope.categoria_traducida.length > 0
		$scope.categoria_traducida = $scope.categoria_traducida[0]
	console.log 'categoria_traducida', $scope.categoria_traducida



])

