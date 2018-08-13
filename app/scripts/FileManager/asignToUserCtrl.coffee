'use strict'

angular.module("WissenSystem")

.controller('AsignToUserCtrl', ['$scope', '$uibModalInstance', 'toastr', 'usuarios', 'perfilPath', 'App', ($scope, $uibModalInstance, toastr, usuarios, perfilPath, App)->

	if usuarios.length > 0
		if usuarios[0].rowid
			$scope.con_rowid = true

	$scope.usuarios = usuarios
	$scope.imagesPath = App.images
	$scope.perfilPath = perfilPath

	$scope.asignar = (usu)->
		$uibModalInstance.close(usu)

	$scope.cancelar = ()->
		$uibModalInstance.dismiss('cancel')

	return

])
