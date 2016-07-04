angular.module('WissenSystem')

.factory('MySocket', ['$websocket', 'App', '$q', '$rootScope', ($websocket, App, $q, $rootScope) ->

	#Open a WebSocket connection
	url = 'ws://' + localStorage.getItem('dominio') + ':8787'
	console.log url
	dataStream = $websocket(url)

	collection = []

	dataStream.onMessage((message)->
		console.log "Llevó msg de tipo string: ", JSON.parse(message.data)
		collection.push(JSON.parse(message.data))
	)

	dataStream.onOpen((datos)->
		console.log 'Acabamos de conectarnos', datos
	)



	methods = {
		collection: collection,
		get: ()->
		  dataStream.send(JSON.stringify({ action: 'get' }))
	}

	return methods

])