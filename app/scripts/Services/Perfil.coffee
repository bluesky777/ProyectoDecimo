angular.module('WissenSystem')

.factory('Perfil', ['Restangular', 'App', '$q', '$cookies', '$rootScope', 'AUTH_EVENTS', '$http', (Restangular, App, $q, $cookies, $rootScope, AUTH_EVENTS, $http) ->

	user = {}

	setUser: (usuario) ->
		user = usuario

	User: ->
		return user

	id: ->
		user.user_id
	idioma: ->
		user.idioma_system

	setImagen: (imagen_id, imagen_nombre)->
		user.imagen_id = imagen_id
		user.imagen_nombre = imagen_nombre

	deleteUser: ()->
		user = {}

])