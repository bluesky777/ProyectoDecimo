'use strict'

angular.module("WissenSystem")

.controller('AsignToUserCtrl', ['$scope', '$mdDialog', 'toastr', 'usuarios', 'perfilPath', ($scope, $mdDialog, toastr, usuarios, perfilPath)->
	$scope.usuarios = usuarios
	$scope.perfilPath = perfilPath

	$scope.asignar = (usu)->
		$mdDialog.hide(usu)

	$scope.cancelar = ()->
		$mdDialog.hide()

	return

])