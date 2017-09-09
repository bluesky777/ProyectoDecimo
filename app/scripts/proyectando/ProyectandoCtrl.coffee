'use strict'

angular.module('WissenSystem')

.controller('ProyectandoCtrl', ['$scope', '$http', '$state', '$stateParams', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket', 'SocketData', 'Fullscreen' 
	($scope, $http, $state, $stateParams, $rootScope, AuthService, Perfil, App, resolved_user, toastr, $translate, $filter, $modal, MySocket, SocketData, Fullscreen) ->

		$scope.SocketData = SocketData
		$scope.examen = SocketData.config.puntaje_to_show
		

		$scope.USER = resolved_user
		#console.log '$scope.USER', $scope.USER
		$scope.imagesPath = App.images

		AuthService.verificar_acceso()


		$scope.categorias_traducidas = $filter('categoriasTraducidas')($scope.USER.categorias_evento, $scope.USER.idioma_main_id)




		
		$rootScope.reload = ()->
			$state.go $state.current, $stateParams, {reload: true}

		$scope.setFullScreen = ()->
			Fullscreen.toggleAll()

		$scope.openMenu = ($mdOpenMenu, ev)->
			originatorEv = ev
			$mdOpenMenu(ev)


				
		return
	]
)


