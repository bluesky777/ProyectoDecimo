angular.module('WissenSystem')

.factory('MySocket', ['App', '$q', '$rootScope', 'Perfil', '$interval', '$cookies', '$http', '$state', 'SocketData', 'SocketClientes', '$filter', (App, $q, $rootScope, Perfil, $interval, $cookies, $http, $state, SocketData, SocketClientes, $filter) ->

	#Open a WebSocket connection
	# Verifico que no tenga puerto asignado
	dominioSplit 	= localStorage.getItem('dominio').split(':')
	dominioSolo 	= ''

	if 'http' in dominioSplit[0]
		dominioSolo 	= dominioSplit[1]
	else
		dominioSolo 	= dominioSplit[0]


	url 		= 'ws://' + dominioSolo + ':8787'
	socket = io.connect('localhost:8787');

	@mensajes = []




	socket.on('te_conectaste', (data)->
		SocketData.conectado data.datos
		Perfil.setResourceId data.datos.resourceId
		registered = if localStorage.getItem('registered_boolean') == null then false else localStorage.getItem('registered_boolean') 
		registered = if registered=='false' then false else true
		Perfil.setResgistered(registered)

		if Perfil.User().id
			@emit('loguear', {usuario: Perfil.User(), registered: registered } )
		else
			nombre_p = if localStorage.getItem('nombre_punto') == null then false else localStorage.getItem('nombre_punto') 
			if nombre_p
				@emit('reconocer:punto:registered', { nombre_punto: nombre_p, registered: registered })
			else
				@emit('reconocer:punto:registered', { nombre_punto: nombre_p, registered: registered })
				#$rootScope.$emit 'reconocido:mi_nombre_punto', {nombre_punto: data.datos.nombre_punto }
	);
	socket.on('logueado:yo', (data)->
		console.log 'Me validó el chat'
	);
	socket.on('logueado:alguien', (data)->
		SocketData.logueado data.clt
		$rootScope.$emit 'clt_registrado', {clientes: SocketClientes.clientes }
	);

	socket.on('user:left', (data)->
		SocketData.desconectar data.resourceId
		$rootScope.$emit 'desconectado:alguien', {clientes: SocketClientes.clientes }
	);


	socket.on('conectado:alguien', (data)->
		client = SocketData.cliente data.clt.resourceId
		if client
			SocketData.actualizar_clt data.clt
		else
			console.log('Nuevo conectado', data.clt);
			SocketData.conectado(data.clt)
			$rootScope.$emit 'clt_registrado', {clientes: SocketClientes.clientes }
	);
	socket.on('take:clientes', (data)->
		SocketData.fix_clientes(data.clts)
		SocketData.config.info_evento 	= data.info_evento
	);
	socket.on('take:usuarios', (data)->
		SocketData.usuarios_all = data.usuarios
	);
	socket.on('reconocido:punto:registered', (data)->
		cliente 				= SocketData.cliente data.resourceId
		cliente.nombre_punto 	= $filter('clearhtml')(data.nombre_punto)
		cliente.registered 		= data.registered
		SocketData.actualizar_clt cliente

		if cliente.resourceId == Perfil.getResourceId()
			$rootScope.$emit 'reconocido:mi_nombre_punto', {nombre_punto: data.nombre_punto }
	);

	socket.on('unregistered', (data)->
		SocketData.actualizar_clt data.client # Viene el cliente con sus propiedades ya arregladas para unregistrar
	);


	############################################
	# Eventos del Socket

	###
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
		console.log 'Error de Socket'
	)

	dataStream.onMessage((message)->
		message = JSON.parse(message.data)
		#console.log "Llegó msg: ", message
		switch message.comando 
			when "conectado"
				SocketData.conectado message.cliente
				if message.yo_resource_id
					Perfil.setResourceId message.yo_resource_id

			when "validado"
				Perfil.setResourceId message.yo.resourceId
				client = SocketData.cliente message.yo.resourceId
				if client
					SocketData.actualizar_clt message.yo
				else
					SocketData.clientes.push(message.yo)
				

			when "desconectado"
				SocketData.desconectar message.clt

			when "registrado"
				client = SocketData.cliente message.clt.resourceId
				if client
					SocketData.actualizar_clt message.clt
				else
					SocketData.clientes.push(message.clt)
					$rootScope.$emit 'clt_registrado', {clientes: SocketData.clientes }

			
			when "take_clts"
				SocketData.clientes = message.clts
				SocketData.config.info_evento = message.info_evento
				
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

			when "a_establecer_fondo"
				SocketData.config.info_evento.img_name = message.img_name

			when "a_mostrar_solo_fondo"
				$state.transitionTo 'proyectando'

			when "a_cambiar_teleprompter"
				SocketData.config.info_evento.msg_teleprompter = message.msg_teleprompter
				$state.transitionTo 'proyectando'

			when "sesion_closed"
				if message.clt.resourceId == Perfil.getResourceId()
					unregister()
					$rootScope.lastState 		= null
					$rootScope.lastStateParam 	= null
					$rootScope.permiso_de_salir = true
					Perfil.deleteUser()
					$state.transitionTo 'login'
					$cookies.remove('xtoken')
					delete $http.defaults.headers.common['Authorization']
				
			when "nombre_punto_cambiado"
				client = SocketData.cliente message.resourceId
				client.nombre_punto = $filter('clearhtml')(message.nombre)
				$rootScope.$emit 'nombre_punto_cambiado', {nombre: client.nombre_punto, resourceId: message.resourceId }
				
			when "take_usuarios"
				SocketData.usuarios_all = message.usuarios
				
			when "change_the_categ_selected"
				client = SocketData.cliente Perfil.getResourceId()
				client.categsel = message.categsel
				SocketData.actualizar_clt client, message.categsel
				$rootScope.$emit 'categ_selected_change', message.categsel
				
			when "change_a_categ_selected"
				client = SocketData.cliente message.resourceId
				client.categsel = message.categsel
				SocketData.actualizar_clt client, message.categsel
				
			when "a_categ_selected_change"
				client = SocketData.cliente message.resourceId
				client.categsel = message.categsel
				SocketData.actualizar_clt client
				
			when "empezar_examen"
				$rootScope.$emit 'empezar_examen'
				
			when "sc_show_participantes"
				get_clts()
				$state.go('proyectando.participantes')

			when "sc_show_barras"
				get_clts()
				$state.go('proyectando.grafico_barras')

			when "sc_show_question"
				SocketData.config.pregunta 			= message.pregunta
				SocketData.config.no_question 		= message.no_question
				SocketData.config.reveal_answer 	= false 
				$state.go('proyectando.question')

			when "sc_show_logo_entidad_partici"
				SocketData.config.show_logo_entidad_partici = message.valor

			when "sc_show_puntaje_particip"
				SocketData.config.cliente_to_show = message.cliente
				$state.go('proyectando.puntaje_particip')

			when "sc_show_puntaje_examen"
				SocketData.config.puntaje_to_show = message.examen
				$state.go('proyectando.puntaje_particip')

			when "sc_answered" # Me avisan que alguien respondió algo
				client = SocketData.cliente message.resourceId
				client = message.cliente
				SocketData.actualizar_clt client

				if message.resourceId != Perfil.getResourceId()
					if message.cliente.answered == 'correct'
						audio = new Audio('/sounds/Pin.wav');
						audio.play();
					else
						audio = new Audio('/sounds/Error.wav');
						audio.play();

			when "next_question" # Me ordenan que vaya a la siguente pregunta
				SocketData.set_waiting()
				$rootScope.$emit 'next_question'

			when "goto_question_no" # Me ordenan que vaya a la pregunta tal
				SocketData.set_waiting()
				$rootScope.$emit 'goto_question_no', message.numero

			when "set_free_till_question" # Dar libertad al participante de responder hasta esta pregunta
				SocketData.config.info_evento.free_till_question = message.free_till_question
				$rootScope.$emit 'set_free_till_question', message.free_till_question # Si estaba esperando pregunta, con esto arranca

					
	)
	###
	#  / Eventos del Socket 
	############################################



		
	io_on = (eventName, callback)->
		socket.on(eventName, ()->
			args = arguments
			$rootScope.$apply( ()->
				callback.apply(socket, args)
			);
		);

	emit = (eventName, data, callback)->
		socket.emit(eventName, data, ()->
			args = arguments;
			$rootScope.$apply( ()->
				if callback
					callback.apply(socket, args);
			);
		)

		
	registrar = (registrar_boolean, cliente)->
		if cliente
			@emit('registrar', { registrar_boolean: registrar_boolean })
		else
			@emit('registrar', { cliente: cliente, registrar_boolean: registrar_boolean })


	unregister = ()->
		@emit('unregister')


	conectar = (qr)->
		nombre_p = if localStorage.getItem('nombre_punto') == null then false else localStorage.getItem('nombre_punto') 
		if qr
			@emit('conectar',  { qr: qr, nombre_punto: nombre_p })
		else
			@emit('conectar', { nombre_punto: nombre_p })


	got_qr = (qr, usuario_id)->
		if usuario_id
			datos = { qr: qr, 'usuario_id': usuario_id, from_token: $cookies.get('xtoken') }
			@emit.send('got_qr', datos)
		else
			@emit.send('got_qr', { qr: qr, from_token: $cookies.get('xtoken') })

	let_him_enter = (usuario_id, resourceId)->
		if usuario_id
			@emit('let_him_enter', { 'usuario_id': usuario_id, from_token: $cookies.get('xtoken'), resourceId: resourceId })



	get_clts = ()->
		if socket.connected
			@emit('get_clts')
		else
			SocketClientes.cliente 					= []
			SocketClientes.registrados_logueados 	= []
			SocketClientes.registrados_no_logged 	= []
			SocketClientes.sin_registrar 			= []


	send_email = (mensaje)->
		@emit('correspondencia', { mensaje: mensaje })


	establecer_fondo = (img_name)->
		@emit('establecer_fondo', { img_name: img_name })


	mostrar_solo_fondo = (img_name)->
		@emit('mostrar_solo_fondo', { img_name: img_name })


	cambiar_teleprompter = (msg_teleprompter)->
		@emit('cambiar_teleprompter', { msg_teleprompter: msg_teleprompter })


	send_email_to = (mensaje, clt)->
		@emit('correspondencia', { mensaje: mensaje, to: clt.resourceId })

	cerrar_sesion = (resourceId)->
		@emit('cerrar_sesion', { resourceId: resourceId })

	guardar_nombre_punto = (resourceId, nombre)->
		nombre = $filter('clearhtml')(nombre)
		@emit('guardar_nombre_punto', { resourceId: resourceId, nombre: nombre })

	get_usuarios = ()->
		#console.log SocketData.usuarios_all.length
		if SocketData.usuarios_all.length == 0
			xtoken = $cookies.get('xtoken')
			@emit('get_usuarios', { from_token: xtoken })

	change_a_categ_selected = (resourceId, categoria_id)->
		client = SocketData.cliente resourceId
		client.categsel = categoria_id
		SocketData.actualizar_clt client, categoria_id
		dataStream.send({ comando: 'change_a_categ_selected',  resourceId: resourceId, categsel: categoria_id })

	# El participante selecciona una categoría por su cuenta y llama a esta función
	change_my_categ_selected = (categoria_id)->
		client = SocketData.cliente Perfil.getResourceId()
		client.categsel = categoria_id
		SocketData.actualizar_clt client, categoria_id
		dataStream.send({ comando: 'warn_my_categ_selected', categsel: categoria_id })

	empezar_examen = ()->
		dataStream.send({ comando: 'empezar_examen' })
		audio = new Audio('/sounds/Sirviendo.wav');
		audio.play();

	empezar_examen_cliente = (resourceId)->
		dataStream.send({ comando: 'empezar_examen_cliente', resourceId: resourceId })

	sc_show_participantes = ()->
		dataStream.send({ comando: 'sc_show_participantes' })

	sc_show_barras = ()->
		dataStream.send({ comando: 'sc_show_barras' })

	sc_show_question = (no_question, pregunta)->
		dataStream.send({ comando: 'sc_show_question', no_question: no_question, pregunta: pregunta })

	sc_reveal_answer = ()->
		dataStream.send({ comando: 'sc_reveal_answer' })

	sc_show_logo_entidad_partici = (valor)->
		dataStream.send({ comando: 'sc_show_logo_entidad_partici', valor: valor })

	sc_show_puntaje_particip = (client)->
		dataStream.send({ comando: 'sc_show_puntaje_particip', cliente: client })

	sc_show_puntaje_examen = (examen)->
		dataStream.send({ comando: 'sc_show_puntaje_examen', examen: examen })

	sc_answered = (valor, tiempo)->
		resourceId = Perfil.getResourceId()
		dataStream.send({ comando: 'sc_answered', resourceId: resourceId, valor: valor, tiempo: tiempo })

	sc_next_question = ()->
		SocketData.set_waiting()
		dataStream.send({ comando: 'next_question' })
		audio = new Audio('/sounds/Siguiente.wav');
		audio.play();

	sc_next_question_cliente = (cliente)->
		client = SocketData.cliente cliente.resourceId
		client.answered = 'waiting'
		dataStream.send({ comando: 'next_question', resourceId: cliente.resourceId })

	sc_goto_question_no_clt = (cliente, numero)->
		client = SocketData.cliente cliente.resourceId
		client.answered = 'waiting'
		dataStream.send({ comando: 'goto_question_no_clt', resourceId: cliente.resourceId, numero: numero })

	liberar_hasta_pregunta = (numero)->
		dataStream.send({ comando: 'liberar_hasta_pregunta', numero: numero })
		SocketData.config.info_evento.preg_actual = numero





	############################################
	# Metodos externos
	methods = {
		usuarios_all: 				@usuarios_all,
		mensajes: ()->
			@mensajes
		conectar: 					conectar,
		readyState: ()->
			socket.connected
		on: 						io_on
		emit: 						emit
		registrar: 					registrar
		unregister:					unregister
		got_qr: 					got_qr
		send_email: 				send_email
		establecer_fondo: 			establecer_fondo
		mostrar_solo_fondo: 		mostrar_solo_fondo
		cambiar_teleprompter: 		cambiar_teleprompter
		send_email_to: 				send_email_to
		get_clts: 					get_clts
		cerrar_sesion: 				cerrar_sesion
		guardar_nombre_punto:		guardar_nombre_punto
		get_usuarios:				get_usuarios
		let_him_enter:				let_him_enter
		change_a_categ_selected:	change_a_categ_selected
		change_my_categ_selected:	change_my_categ_selected
		empezar_examen:				empezar_examen
		empezar_examen_cliente:		empezar_examen_cliente
		sc_show_participantes:		sc_show_participantes
		sc_show_barras:				sc_show_barras
		sc_show_question:			sc_show_question
		sc_reveal_answer:			sc_reveal_answer
		sc_show_logo_entidad_partici:	sc_show_logo_entidad_partici
		sc_show_puntaje_particip:	sc_show_puntaje_particip
		sc_show_puntaje_examen:		sc_show_puntaje_examen
		sc_answered:				sc_answered
		sc_next_question:			sc_next_question
		sc_next_question_cliente:	sc_next_question_cliente
		sc_goto_question_no_clt:	sc_goto_question_no_clt
		liberar_hasta_pregunta:		liberar_hasta_pregunta
	}

	return methods

])


.factory('SocketData', ['SocketClientes', '$rootScope', '$filter', (SocketClientes, $rootScope, $filter) ->
	
	@cliente_to_show		= []
	usuarios_all	= []
	mensajes		= []
	@clt_selected	= {}
	token_auth		= ''
	config			= 
		pregunta: {}, 
		reveal_answer: false, 
		show_logo_entidad_partici: false 
		info_evento: { examen_iniciado: false, preg_actual: 0 }


	desconectar = (resourceId)=>
		SocketClientes.clientes 				= $filter('filter')(SocketClientes.clientes, {resourceId: '!'+resourceId})
		SocketClientes.sin_registrar 			= $filter('filter')(SocketClientes.sin_registrar, {resourceId: '!'+resourceId})
		SocketClientes.registrados_logueados 	= $filter('filter')(SocketClientes.registrados_logueados, {resourceId: '!'+resourceId})
		SocketClientes.registrados_no_logged 	= $filter('filter')(SocketClientes.registrados_no_logged, {resourceId: '!'+resourceId})
		console.log 'desconectado  ', SocketClientes.clientes

		


	cliente = (resourceId)=>
		for clt in SocketClientes.clientes
			if clt.resourceId == resourceId
				return clt
		return false


	actualizar_clt = (client, propiedad)=>
		for clt, indice in SocketClientes.clientes
			if clt.resourceId == client.resourceId
				SocketClientes.clientes.splice indice, 1, client

		return false



	fix_clientes = (clientes)=>
		SocketClientes.clientes = clientes
		SocketClientes.registrados_logueados.splice(0, SocketClientes.registrados_logueados.length)
		SocketClientes.registrados_no_logged.splice(0, SocketClientes.registrados_no_logged.length)
		SocketClientes.sin_registrar.splice(0, SocketClientes.sin_registrar.length)

		for client in SocketClientes.clientes
			if client.registered
				if client.logged
					SocketClientes.registrados_logueados.push(client)
				else
					SocketClientes.registrados_no_logged.push(client)
			else
				SocketClientes.sin_registrar.push(client)

		return true


	conectado = (client)=>
		added 	= false
		index 	= 0

		for clt, indice in SocketClientes.clientes
			if clt.resourceId == client.resourceId
				added 	= true
				index 	= indice
					
		if not added
			SocketClientes.clientes.push client
			if client.registered
				SocketClientes.registrados_no_logged.push client
			else
				SocketClientes.sin_registrar.push client


		return true


	logueado = (client)=>
		console.log('logueando', client)
		if client.registered
			found 		= false
			index 		= 0
			for clt, indice in SocketClientes.registrados_no_logged
				if clt.resourceId == client.resourceId
					found 		= true
					index 		= indice

			if found
				SocketClientes.registrados_no_logged.splice index, 1

				for clt, indice in SocketClientes.clientes
					if clt.resourceId == client.resourceId
						SocketClientes.clientes.splice indice, 1, client

				for clt, indice in SocketClientes.registrados_logueados
					if clt.resourceId == client.resourceId
						SocketClientes.registrados_logueados.push client
				


		else
			ya_logueado = false
			for clt, indice in SocketClientes.sin_registrar
				if clt.resourceId == client.resourceId
					if clt.logged
						ya_logueado = true
						index 		= indice
					
			if not ya_logueado
				for clt, indice in SocketClientes.clientes
					if clt.resourceId == client.resourceId
						SocketClientes.clientes.splice indice, 1, client
		
		return true

	deslogueado = (client)=>
		is_logueado 	= false
		index 			= 0

		for clt, indice in SocketClientes.clientes
			if clt.resourceId == client.resourceId and clt.logged == client.logged
				is_logueado 	= true
				index 			= indice
					
		if is_logueado
			SocketClientes.clientes.splice index, 1, client
			
			if client.registered
				if client.logged 
					SocketClientes.registrados_logueados.push client
					SocketClientes.registrados_no_logged.splice index, 1
				else
					SocketClientes.registrados_no_logged.push client
					SocketClientes.registrados_logueados.splice index, 1
			else
				SocketClientes.sin_registrar.splice index, 1, client

		else
			SocketClientes.clientes.push client
			if client.registered
				SocketClientes.sin_registrar.push client
			else
				SocketClientes.sin_registrar.splice index, 1, client


		return true

	set_waiting = ()=>
		for clt, indice in SocketClientes.clientes
			clt.answered = 'waiting'
		return false






	methods = {
		usuarios_all: 				usuarios_all,
		mensajes: 					mensajes
		desconectar: 				desconectar
		token_auth:					token_auth
		cliente:					cliente
		fix_clientes: 				fix_clientes
		conectado:					conectado
		logueado:					logueado
		deslogueado:				deslogueado
		actualizar_clt:				actualizar_clt
		config:						config
		set_waiting:				set_waiting
		clt_selected:				@clt_selected
	}

	return methods


])

.factory('SocketClientes', ['$rootScope', ($rootScope) ->
	
	@clientes 					= []
	@registrados_logueados 		= []
	@registrados_no_logged 		= []
	@sin_registrar 				= []

	{
		clientes: 					@clientes,
		registrados_logueados: 		@registrados_logueados,
		registrados_no_logged: 		@registrados_no_logged,
		sin_registrar: 				@sin_registrar,
	}
])
