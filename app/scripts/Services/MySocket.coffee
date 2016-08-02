angular.module('WissenSystem')

.factory('MySocket', ['$websocket', 'App', '$q', '$rootScope', 'Perfil', '$interval', '$cookies', '$http', '$state', 'SocketData', '$filter', ($websocket, App, $q, $rootScope, Perfil, $interval, $cookies, $http, $state, SocketData, $filter) ->

	#Open a WebSocket connection
	url = 'ws://' + localStorage.getItem('dominio') + ':8787'
	dataStream = $websocket(url, {reconnectIfNotNormalClose: true})

	clientes = []
	@usuarios_all = []
	datos = {}
	@mensajes = []


	registrar = (usuario)->
		nombre_p = if localStorage.getItem('nombre_punto') == null then false else localStorage.getItem('nombre_punto')
		dataStream.send({ comando: 'registrar',  usuario: usuario, nombre_punto: nombre_p })


	unregister = ()->
		console.log "Entra para unregistrar"
		dataStream.send({ comando: 'unregister' })





	############################################
	# Eventos del Socket
	dataStream.onMessage((message)->
		message = JSON.parse(message.data)
		#console.log "Llegó msg: ", message
		switch message.comando 
			when "conectado"
				SocketData.conectado message.cliente

			when "validado"
				Perfil.setResourceId message.yo.resourceId
				SocketData.clientes.push(message.yo)

			when "desconectado"
				SocketData.desconectar message.clt

			when "registrado"
				client = SocketData.cliente message.clt.resourceId
				if client
					SocketData.cambiar_registro message.clt
				else
					SocketData.clientes.push(message.clt)
					$rootScope.$emit 'clt_registrado', {clientes: SocketData.clientes }

			when "unregistered"
				SocketData.cambiar_registro message.client

			when "take_clts"
				SocketData.clientes = message.clts
				
			when "got_your_qr"
				if message.seleccionar
					SocketData.usuarios_all = message.usuarios
					SocketData.token_auth = message.token

				else if message.token
					$cookies.put('xtoken', message.token)
					$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')
					$state.go 'panel'

			when "correspondencia"
				@mensajes = if @mensajes is undefined then [] else @mensajes

				message.mensaje.from = JSON.parse(message.mensaje.from)
				@mensajes.push message.mensaje
				
				$rootScope.$emit 'llegaCorrespondencia', {mensajes: @mensajes }

			when "sesion_closed"
				if message.clt.resourceId == Perfil.getResourceId()
					unregister()
					$rootScope.lastState = null
					$rootScope.lastStateParam = null
					Perfil.deleteUser()
					$state.transitionTo 'login'
					$cookies.remove('xtoken')
					delete $http.defaults.headers.common['Authorization']
				
			when "nombre_punto_cambiado"
				client = SocketData.cliente message.resourceId
				client.nombre_punto = $filter('clearhtml')(message.nombre)
				$rootScope.$emit 'nombre_punto_cambiado', {nombre: client.nombre_punto }
				
			when "take_usuarios"
				SocketData.usuarios_all = message.usuarios
				
			when "enter"
				if message.token
					$cookies.put('xtoken', message.token)
					$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')
					$state.go 'panel'
				


					
	)


	dataStream.onOpen((datos)->
		if Perfil.User().id
			registrar(Perfil.User())
		else
			conectar()
	)
	dataStream.onClose((datos)->
		SocketData.clientes = []
	)
	dataStream.onError((datos)->
		console.log 'Error de Socket', datos
	)
	#  / Eventos del Socket 
	############################################




		
	conectar = (qr)->
		nombre_p = if localStorage.getItem('nombre_punto') == null then false else localStorage.getItem('nombre_punto') 
		if qr
			dataStream.send({ comando: 'conectar',  qr: qr, nombre_punto: nombre_p })
		else
			dataStream.send({ comando: 'conectar', nombre_punto: nombre_p })


		
	got_qr = (qr, usuario_id)->
		if usuario_id
			datos = { comando: 'got_qr',  qr: qr, 'usuario_id': usuario_id, from_token: $cookies.get('xtoken') }
			dataStream.send(datos)
		else
			dataStream.send({ comando: 'got_qr',  qr: qr, from_token: $cookies.get('xtoken') })

	let_him_enter = (usuario_id, resourceId)->
		if usuario_id
			datos = { comando: 'let_him_enter', 'usuario_id': usuario_id, from_token: $cookies.get('xtoken'), resourceId: resourceId }
			dataStream.send(datos)


	get_clts = ()->
		datos = { comando: 'get_clts' }
		dataStream.send(datos)

		
	send_email = (mensaje)->
		dataStream.send({ comando: 'correspondencia',  mensaje: mensaje })


	send_email_to = (mensaje, clt)->
		dataStream.send({ comando: 'correspondencia',  mensaje: mensaje, to: clt.resourceId })

	cerrar_sesion = (resourceId)->
		dataStream.send({ comando: 'cerrar_sesion',  resourceId: resourceId })

	guardar_nombre_punto = (resourceId, nombre)->
		nombre = $filter('clearhtml')(nombre)
		dataStream.send({ comando: 'guardar_nombre_punto',  resourceId: resourceId, nombre: nombre })

	get_usuarios = ()->
		console.log SocketData.usuarios_all.length
		if SocketData.usuarios_all.length == 0
			xtoken = $cookies.get('xtoken')
			dataStream.send({ comando: 'get_usuarios',  from_token: xtoken })





	############################################
	# Metodos externos
	methods = {
		clientes: 					clientes,
		usuarios_all: 				@usuarios_all,
		mensajes: ()->
			@mensajes
		conectar: 					conectar,
		readyState: ()->
			dataStream.readyState
		getClts: ()->
			dataStream.send({ comando: 'get_clts' })
		registrar: 					registrar
		unregister:					unregister
		got_qr: 					got_qr
		send_email: 				send_email
		send_email_to: 				send_email_to
		get_clts: 					get_clts
		cerrar_sesion: 				cerrar_sesion
		guardar_nombre_punto:		guardar_nombre_punto
		get_usuarios:				get_usuarios
		let_him_enter:				let_him_enter
	}

	return methods

])


.factory('SocketData', ['$websocket', 'App', '$rootScope', '$filter', ($websocket, App, $rootScope, $filter) ->
	
	@clientes		= []
	usuarios_all	= []
	mensajes		= []
	token_auth		= ''


	desconectar = (clt)->
		console.log  clt, @clientes, $filter('filter')(@clientes, {resourceId: '!'+clt.resourceId})
		@clientes = $filter('filter')(@clientes, {resourceId: '!'+clt.resourceId})


	cliente = (resourceId)->
		for clt in @clientes
			if clt.resourceId == resourceId
				return clt
		return false


	cambiar_registro = (client)->
		for clt, indice in @clientes
			if clt.resourceId == client.resourceId
				@clientes.splice indice, 1
				@clientes.push client
		console.log @clientes
		return false


	conectado = (client)->
		added = false
		for clt in @clientes
			if clt.resourceId == client.resourceId
				added = true
		
		if not added
			@clientes.push client
		return true






	methods = {
		clientes: 					@clientes,
		usuarios_all: 				usuarios_all,
		mensajes: 					mensajes
		desconectar: 				desconectar
		token_auth:					token_auth
		cliente:					cliente
		cambiar_registro:			cambiar_registro
		conectado:					conectado
	}

	return methods


])
