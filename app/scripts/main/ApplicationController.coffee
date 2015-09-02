'use strict'

angular.module('WissenSystem')

.controller('ApplicationController', ['$scope', 'USER_ROLES', 'AuthService', 'toastr', '$state', '$rootScope', 'Restangular', '$filter', ($scope, USER_ROLES, AuthService, toastr, $state, $rootScope, Restangular, $filter)->


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


	# Función para idiomas del sistema
	$scope.idiomas_del_sistema = ()->
		$scope.idiomas_usados = $filter('idiomas_del_sistema')($scope.idiomas)

		for idiom in $scope.idiomas_usados
			if idiom.abrev == 'ES'
				idiom.actual = true




	# Traemos los idiomas del sistema.
	$scope.idiomas = []
	Restangular.all('idiomas').getList().then((r)->
		$scope.idiomas = r
		$scope.idiomas_del_sistema()
	(r2)->
		console.log 'No se trajeron los idiomas del sistema.', r2
	)
	







])




