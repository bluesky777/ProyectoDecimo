angular.module('WissenSystem')

.factory('MySocket', ['$websocket', 'App', '$q', '$rootScope', 'Perfil', ($websocket, App, $q, $rootScope, Perfil) ->

	#Open a WebSocket connection
	url = 'ws://' + localStorage.getItem('dominio') + ':8787'
	dataStream = $websocket(url)

	collection = []

	dataStream.onMessage((message)->
		console.log "Llegó msg de tipo string: ", JSON.parse(message.data)
		collection.push(JSON.parse(message.data))
	)

	dataStream.onOpen((datos)->
		console.log 'Acabamos de conectarnos', datos
	)



	methods = {
		collection: collection,
		get: ()->
			dataStream.send(JSON.stringify({ action: 'get' }))
		registrar: (usuario)->
			console.log "Entra para registrar"
			dataStream.send(JSON.stringify({ comando: 'registrar',  usuario: usuario }))
	}

	return methods

])