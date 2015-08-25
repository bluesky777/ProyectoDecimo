'use strict'

angular.module('WissenSystem')

.controller('ApplicationController', ['$scope', 'USER_ROLES', 'AuthService', 'toastr', '$state', '$rootScope', 'Restangular', ($scope, USER_ROLES, AuthService, toastr, $state, $rootScope, Restangular)->

	$scope.USER= {}

	$scope.toastr = toastr

	$scope.verificar_acceso = AuthService.verificar_acceso
	$scope.isAuthorized = AuthService.isAuthorized
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.USER_ROLES = USER_ROLES

	$scope.isLoginPage = false

	$scope.navFull = true
	$scope.toggleNav = ()->
		$scope.navFull = !$scope.navFull

	$scope.floatingSidebar = 0
	$scope.toggleFloatingSidebar = ()->
		$scope.floatingSidebar = if $scope.floatingSidebar then false else true



	# Traemos los idiomas del sistema.
	$scope.idiomas = []
	Restangular.all('idiomas').getList().then((r)->
		$scope.idiomas = r
	(r2)->
		console.log 'No se trajeron los idiomas del sistema.', r2
	)
	


	$scope.traerEventos = ()->
		Restangular.all('eventos').getList().then((r)->
			$scope.eventos = r
		(r2)->
			console.log 'No se trajeron los eventos.'
		)

	$scope.traerEventos()




])