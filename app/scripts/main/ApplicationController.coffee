'use strict'

angular.module('WissenSystem')

.controller('ApplicationController', ['$scope', 'USER_ROLES', 'AuthService', 'toastr', '$state', '$rootScope', 'Restangular', '$filter', '$timeout', 'MySocket', ($scope, USER_ROLES, AuthService, toastr, $state, $rs, Restangular, $filter, $timeout, MySocket)->


	$scope.isAuthorized = AuthService.isAuthorized
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.USER_ROLES = USER_ROLES

	$scope.isLoginPage = false


	$scope.navFull = true
	$scope.toggleNav = ()->
		$scope.navFull = !$scope.navFull
		$rs.navOffCanvas = !$rs.navOffCanvas
		console.log("navOffCanvas: "+$scope.navOffCanvas)
		$timeout(()->
			$rs.$broadcast("c3.resize")
		, 260)


	
	$scope.tema = 'theme-zero'
	$scope.cambiarTema = (actual)->
		$scope.tema = actual


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
		if r2.status == 404
			answer = confirm("Si es la primera vez, debes actializar la página ¿Actualizar ahora?")
			if (answer)
				location.reload()
		else
			console.log 'No se trajeron los idiomas del sistema.', r2
	)
	
	# Traemos evento actual.
	$scope.in_evento_actual = {}
	
	







])




