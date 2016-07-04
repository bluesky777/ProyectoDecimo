angular.module('WissenSystem')

.factory('MySocket', ['$websocket', 'App', '$q', '$rootScope', ($websocket, App, $q, $rootScope) ->

	#Open a WebSocket connection
	dataStream = $websocket('ws://' + App.dominio + ':8787')

	collection = []

	dataStream.onMessage((message)->
		collection.push(JSON.parse(message.data))
	)

	methods = {
		collection: collection,
		get: ()->
		  dataStream.send(JSON.stringify({ action: 'get' }))
	}

	return methods

])