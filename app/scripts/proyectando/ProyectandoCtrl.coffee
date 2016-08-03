'use strict'

angular.module('WissenSystem')

.controller('ProyectandoCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user, toastr, $translate, $filter, $modal, MySocket) ->


		$scope.USER = resolved_user
		#console.log '$scope.USER', $scope.USER
		$scope.imagesPath = App.images

		AuthService.verificar_acceso()


		$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
			$scope.cambiarTema('theme-zero')

			
		$scope.openMenu = ($mdOpenMenu, ev)->
			originatorEv = ev
			$mdOpenMenu(ev)

		$scope.cambiarIdioma = (idioma)->
			

			Restangular.one('idiomas/cambiar-idioma').customPUT({idioma_id: idioma.id}).then((r)->
				$translate.use(idioma.abrev)
				$scope.USER.idioma_main_id = idioma.id

				$scope.idiomas_del_sistema()

				for idiom in $scope.idiomas_usados
					idiom.actual = if idiom.abrev == idioma.abrev then true else false


				toastr.success 'Idioma cambiado por ' + idioma.abrev
			(r2)->
				console.log 'No se pudo cambiar el idioma.', r2
			)
			


			
		$scope.set_system_event = (evento)->
			Restangular.one('eventos/set-evento-actual').customPUT({'id': evento.id}).then((r)->
				console.log 'Evento cambiado: ', r

				angular.forEach $scope.USER.eventos, (eventito, key) ->
					eventito.actual = false

				evento.actual = true
				
				toastr.success 'Evento actual cambiado por ' + evento.alias

			, (r2)->
				console.log 'Error conectando!', r2
				toastr.warning 'No se pudo cambiar el evento actual.'

			)



		$scope.evento_actual = {}

		# Función para establecer en el frontend el evento actual del usuario
		$scope.el_evento_actual = ()->

			if $scope.USER
				if AuthService.isAuthorized('can_work_like_admin')
					try

						$scope.evento_actual = $filter('filter')($scope.USER.eventos, {id: $scope.USER.evento_selected_id})[0]

					catch
						$scope.evento_actual = {}
					finally
						$rootScope.$broadcast 'cambia_evento_actual'
				else
					$scope.evento_actual = $scope.USER.evento_actual

		$scope.el_evento_actual()


			
		$scope.set_user_event = (evento)->
			Restangular.one('eventos/set-user-event').customPUT({'evento_id': evento.id}).then((r)->
				console.log 'Evento cambiado: ', r

				$scope.USER.evento_selected_id = evento.id
				$scope.el_evento_actual() # Actualizamos el modelo del evento actual
				toastr.success 'Evento actual cambiado por ' + evento.alias

				$rootScope.$broadcast 'cambio_evento_user' # Anunciamos el cambio de evento.

			, (r2)->
				console.log 'Error conectando!', r2
				toastr.warning 'No se pudo cambiar el evento actual.'

			)

		$scope.logout = ()->
			MySocket.unregister()
			AuthService.logout()
			$scope.in_evento_actual = {}

			Restangular.one('login/logout').customPUT().then((r)->
				console.log 'Desconectado con éxito: ', r
			, (r2)->
				console.log 'Error desconectando!', r2
			)

			#$state.go 'login'




		# Traemos los eventos
		$scope.traerEventos = ()->
			Restangular.all('eventos').getList().then((r)->
				$scope.USER.eventos = r
				$scope.el_evento_actual()
			(r2)->
				console.log 'No se trajeron los eventos.'
			)


				
		return
	]
)


