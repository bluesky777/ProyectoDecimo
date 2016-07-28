angular.module('WissenSystem')

.factory('MySocket', ['$websocket', 'App', '$q', '$rootScope', 'Perfil', '$interval', '$cookies', '$http', '$state', 'SocketData', ($websocket, App, $q, $rootScope, Perfil, $interval, $cookies, $http, $state, SocketData) ->

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
				datos = message.cliente

			when "validado"
				Perfil.setResourceId message.yo.resourceId
				SocketData.clientes.push(message.yo)

			when "desconectado"
				SocketData.desconectar message.clt

			when "registrado"
				SocketData.clientes.push(message.clt)
				$rootScope.$emit 'clt_registrado', {clientes: SocketData.clientes }

			when "take_clts"
				SocketData.clientes = message.clts
				$rootScope.$emit 'take_clts', {clientes: SocketData.clientes }

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
				


					
	)


	dataStream.onOpen((datos)->
		if Perfil.User().id
			registrar(Perfil.User())
	)
	dataStream.onClose((datos)->
		console.log 'Desconectado', datos
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
			console.log 'enviando', datos
			dataStream.send(datos)
		else
			console.log 'Enviando por aquíiiiiii'
			dataStream.send({ comando: 'got_qr',  qr: qr, from_token: $cookies.get('xtoken') })



	get_clts = ()->
		datos = { comando: 'get_clts' }
		dataStream.send(datos)


		
	send_email = (mensaje)->
		dataStream.send({ comando: 'correspondencia',  mensaje: mensaje })


	send_email_to = (mensaje, clt)->
		dataStream.send({ comando: 'correspondencia',  mensaje: mensaje, to: clt.resourceId })

	cerrar_sesion = (resourceId)->
		dataStream.send({ comando: 'cerrar_sesion',  resourceId: resourceId })




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



	methods = {
		clientes: 					@clientes,
		usuarios_all: 				usuarios_all,
		mensajes: 					mensajes
		desconectar: 				desconectar
		token_auth:					token_auth
	}

	return methods


])
