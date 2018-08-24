angular.module('WissenSystem')

.controller('CategoriasCtrl', ['$scope', 'Restangular', 'toastr',  ($scope, Restangular, toastr)->

	$scope.selectedTab = 0

	if localStorage.selectedTabCategoria
		$scope.selectedTab = localStorage.selectedTabCategoria

	$scope.selectTab = (indice)->
		localStorage.selectedTabCategoria = indice


	$scope.comprobar_evento_actual = ()->
		if $scope.evento_actual

			if $scope.evento_actual.idioma_principal_id

				$scope.idiomaPreg = {
					selected: $scope.evento_actual.idioma_principal_id
				}
		else
			toastr.warning 'Pimero debes crear o seleccionar un evento actual'


	$scope.categorias_king = []
	$scope.niveles_king = []
	$scope.disciplinas_king = []



	$scope.comprobar_evento_actual()

	$scope.$on 'cambio_evento_user', ()->
		$scope.comprobar_evento_actual()

	$scope.$on 'cambia_evento_actual', ()->
		$scope.comprobar_evento_actual()

])

