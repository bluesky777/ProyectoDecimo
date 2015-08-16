'use strict'

angular.module('WissenSystem')

.controller('PanelCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', '$translate', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user, toastr, $translate) ->

		$scope.conectar = ()->
		
			Restangular.oneUrl('pregunta_king').get().then((r)->
				console.log 'Conectado con éxito: ', r
			, (r2)->
				console.log 'Error conectando!', r2
			)

		$scope.cambiarIdioma = (idioma)->
			$translate.use(idioma)
			
		return
	]
)