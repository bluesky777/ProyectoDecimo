'use strict'

angular.module('WissenSystem')

.controller('ApplicationController', ['$scope', 'USER_ROLES', 'AuthService', 'toastr', '$state', '$rootScope', 'Restangular', '$filter', '$timeout', 'MySocket', '$translate', ($scope, USER_ROLES, AuthService, toastr, $state, $rs, Restangular, $filter, $timeout, MySocket, $translate)->


	$scope.isAuthorized = AuthService.isAuthorized
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.USER_ROLES = USER_ROLES

	$scope.isLoginPage = false


	$scope.navFull = true

	if localStorage.navFull
		$scope.navFull = if localStorage.navFull=='false' then false else true

	$scope.toggleNav = ()->
		$scope.navFull = !$scope.navFull
		$scope.navOffCanvas = !$scope.navOffCanvas
		localStorage.navFull = $scope.navFull

		$timeout(()->
			$scope.$broadcast("c3.resize")
		, 260)



	$scope.tema = 'theme-zero'
	$scope.cambiarTema = (actual)->
		$scope.tema = actual


	# Función para idiomas del sistema
	$scope.idiomas_del_sistema = (idioma_user_id)->
		$scope.idiomas_usados = $filter('idiomas_del_sistema')($scope.idiomas)

		for idiom in $scope.idiomas_usados
			idiom.actual = false

		if idioma_user_id
			for idiom in $scope.idiomas_usados
				if idiom.rowid == idioma_user_id or idiom.id == idioma_user_id
					idiom.actual = true
					$translate.use(idiom.abrev)
		else
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

			if localStorage.recargado_automaticamente
				cantidad = parseInt(localStorage.recargado_automaticamente);


				if cantidad > 2
					answer = confirm("No se ha podido establecer conexión. ¿Deseas recargar? (tal vez debas borrar datos de navegación)")
					if (answer)
						location.reload()

				else
					localStorage.recargado_automaticamente = 1 + cantidad;
					location.reload()

			else
				localStorage.recargado_automaticamente = 1
				location.reload()


		else
			console.log 'No se trajeron los idiomas del sistema.', r2
	)

	# Traemos evento actual.
	$scope.in_evento_actual = {}









])




