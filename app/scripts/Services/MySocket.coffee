angular.module('WissenSystem')

.factory('MySocket', ['$websocket', 'App', '$q', '$rootScope', 'Perfil', '$interval', '$cookies', '$http', '$state', ($websocket, App, $q, $rootScope, Perfil, $interval, $cookies, $http, $state) ->

	#Open a WebSocket connection
	url = 'ws://' + localStorage.getItem('dominio') + ':8787'
	dataStream = $websocket(url, {reconnectIfNotNormalClose: true})

	clientes = []
	@usuarios_all = []
	datos = {}
	@mensajes = []


	registrar = (usuario)->
		console.log "Entra para registrar"
		dataStream.send({ comando: 'registrar',  usuario: usuario })





	############################################
	# Eventos del Socket
	dataStream.onMessage((message)->
		message = JSON.parse(message.data)
		#console.log "Llegó msg: ", message
		switch message.comando 
			when "conectado"
				datos = message.cliente

			when "validado"
				console.log 'validado'

			when "registrado"
				clientes.push(message.clt)

			when "take_clts"
				clientes = message.clts

			when "got_your_qr"
				if message.seleccionar
					@usuarios_all = message.usuarios
					$rootScope.$emit 'lleganUsuarios', {usuarios_all: @usuarios_all, token: message.token }

				else if message.token
					$cookies.put('xtoken', message.token)
					$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')
					$state.go 'panel'

			when "correspondencia"
				@mensajes = if @mensajes is undefined then [] else @mensajes

				message.mensaje.from = JSON.parse(message.mensaje.from)
				@mensajes.push message.mensaje
				
				$rootScope.$emit 'llegaCorrespondencia', {mensajes: @mensajes }
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
		if qr
			dataStream.send({ comando: 'conectar',  qr: qr })
		else
			dataStream.send({ comando: 'conectar' })


		
	got_qr = (qr, usuario_id)->
		if usuario_id
			datos = { comando: 'got_qr',  qr: qr, 'usuario_id': usuario_id }
			console.log 'enviando', datos
			dataStream.send(datos)
		else
			console.log 'Enviando por aquíiiiiii'
			dataStream.send({ comando: 'got_qr',  qr: qr })



		
	enviar_correspondencia = (mensaje)->
		dataStream.send({ comando: 'correspondencia',  mensaje: mensaje })




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
		got_qr: 					got_qr
		enviar_correspondencia: 	enviar_correspondencia
	}

	return methods

])