'use strict'

angular.module('WissenSystem')

.controller('ProyectandoCtrl', ['$scope', 'Restangular', '$state', '$stateParams', '$rootScope', 'AuthService', 'App', 'resolved_user', '$filter', 'MySocket', 'SocketData', 'Fullscreen' 
	($scope, Restangular, $state, $stateParams, $rootScope, AuthService, App, resolved_user, $filter, MySocket, SocketData, Fullscreen) ->

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

		
		$scope.logout = ()->
			MySocket.desloguear()
			AuthService.logout()
			$scope.in_evento_actual = {}

			Restangular.one('login/logout').customPUT().then((r)->
				console.log 'Desconectado con éxito: ', r
			, (r2)->
				console.log 'Error desconectando!', r2
			)

			#$state.go 'login'

		$rootScope.$on('me_desloguearon', (ev, client)->
			$scope.logout()
		);  


				
		return
	]
)


