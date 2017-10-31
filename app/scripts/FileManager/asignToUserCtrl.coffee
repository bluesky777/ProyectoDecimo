'use strict'

angular.module("WissenSystem")

.controller('AsignToUserCtrl', ['$scope', '$uibModalInstance', 'toastr', 'usuarios', 'perfilPath', 'App', ($scope, $uibModalInstance, toastr, usuarios, perfilPath, App)->
	$scope.usuarios = usuarios
	$scope.imagesPath = App.images
	$scope.perfilPath = perfilPath

	$scope.asignar = (usu)->
		$uibModalInstance.close(usu)

	$scope.cancelar = ()->
		$uibModalInstance.dismiss('cancel')

	return

])