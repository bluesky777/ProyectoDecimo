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


	#url 		= 'ws://' + dominioSolo + ':8787'
	socket = io.connect(dominioSolo + ':8787');



	socket.on('te_conectaste', (data)->
		SocketData.conectado data.datos
		Perfil.setResourceId data.datos.resourceId
		registered = if localStorage.getItem('registered_boolean') == null then false else localStorage.getItem('registered_boolean') 
		registered = if registered=='false' then false else true
		Perfil.setRegistered(registered)

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
		Perfil.setResourceId data.yo.resourceId
		$rootScope.$emit('logueado:yo:agregado_a_arrays', data.yo)
		SocketData.logueado data.yo
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
			SocketData.conectado(data.clt)
			$rootScope.$emit 'clt_registrado', {clientes: SocketClientes.clientes }
	);
	socket.on('take:clientes', (data)->
		SocketData.fix_clientes(data.clts)
		SocketData.config.info_evento 	= data.info_evento
	);
	socket.on('take:usuarios', (data)->
		SocketClientes.usuarios_all = data.usuarios
	);
	socket.on('reconocido:punto:registered', (data)->
		cliente 				= SocketData.cliente data.resourceId
		cliente.nombre_punto 	= $filter('clearhtml')(data.nombre_punto)
		cliente.registered 		= data.registered
		SocketData.actualizar_clt cliente

		if cliente.resourceId == Perfil.getResourceId()
			$rootScope.$emit 'reconocido:mi_nombre_punto', {nombre_punto: data.nombre_punto }
	);

	socket.on('deslogueado', (data)->
		SocketData.deslogueado data.client # Viene el cliente con sus propiedades ya arregladas para unregistrar
	);
	socket.on('got_your_qr', (data)->
		if data.seleccionar
			SocketClientes.usuarios_all = data.usuarios
			SocketData.token_auth = data.from_token
			console.log(data)
		else if data.usuario_id
			Restangular.one('qr/validar-usuario').customPUT({user_id: data.usuario_id, token_auth: data.from_token }).then((r)->
				if r.token
					SocketClientes.usuarios_all = []
					$cookies.put('xtoken', r.token)
					$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')
					$state.go 'panel'
					location.refresh()
			, (r2)->
				toastr.warning 'No se pudo ingresar'
				console.log 'No se pudo ingresar ', r2
			)
	);


	socket.on('correspondencia', (data)->
		SocketClientes.mensajes.push data.mensaje
		$rootScope.$emit 'llegaCorrespondencia'
	);
	socket.on('a_establecer_fondo', (data)->
		SocketData.config.info_evento.img_name = data.img_name
	);

	socket.on('a_mostrar_solo_fondo', (data)->
		$state.transitionTo 'proyectando'
	);

	socket.on('a_cambiar_teleprompter', (data)->
		SocketData.config.info_evento.msg_teleprompter = data.msg_teleprompter
		$state.transitionTo 'proyectando'
	);

	socket.on('sesion_closed', (data)->
		if data.clt.resourceId == Perfil.getResourceId()
			unregister()
			$rootScope.lastState 		= null
			$rootScope.lastStateParam 	= null
			$rootScope.permiso_de_salir = true
			Perfil.deleteUser()
			$state.transitionTo 'login'
			$cookies.remove('xtoken')
			delete $http.defaults.headers.common['Authorization']
	);

	socket.on('nombre_punto_cambiado', (data)->
		client 					= SocketData.cliente data.resourceId
		client.nombre_punto 	= $filter('clearhtml')(data.nombre)
		$rootScope.$emit 'nombre_punto_cambiado', {nombre: client.nombre_punto, resourceId: data.resourceId }	
	);
	socket.on('take_usuarios', (data)->
		SocketClientes.usuarios_all = data.usuarios
	);

	socket.on('change_the_categ_selected', (data)->
		client 				= SocketData.cliente Perfil.getResourceId()
		client.categsel 	= data.categsel
		SocketData.actualizar_clt client, data.categsel
		$rootScope.$emit 'categ_selected_change', data.categsel
	);
	socket.on('change_a_categ_selected', (data)->
		client 				= SocketData.cliente data.resourceId
		client.categsel 	= data.categsel
		SocketData.actualizar_clt client, data.categsel
	);

	socket.on('a_categ_selected_change', (data)->
		client 				= SocketData.cliente data.resourceId
		client.categsel 	= data.categsel
		SocketData.actualizar_clt client
	);
	socket.on('empezar_examen', (data)->
		$rootScope.$emit 'empezar_examen'
	);
	socket.on('sc_show_participantes', (data)->
		get_clts()
		$state.go('proyectando.participantes')
	);
	socket.on('sc_show_barras', (data)->
		get_clts()
		$state.go('proyectando.grafico_barras')
	);
	socket.on('sc_show_question', (data)->
		SocketData.config.pregunta 			= data.pregunta
		SocketData.config.no_question 		= data.no_question
		SocketData.config.reveal_answer 	= false 
		$state.go('proyectando.question')
	);
	socket.on('sc_show_logo_entidad_partici', (data)->
		SocketData.config.show_logo_entidad_partici = data.valor
	);
	socket.on('sc_show_puntaje_particip', (data)->
		SocketData.config.cliente_to_show = message.cliente
		$state.go('proyectando.puntaje_particip')
	);
	socket.on('sc_show_puntaje_examen', (data)->
		SocketData.config.puntaje_to_show = message.examen
		$state.go('proyectando.puntaje_particip')
	);
	socket.on('sc_answered', (data)-> # Me avisan que alguien respondió algo
		client = SocketData.cliente data.resourceId
		client = data.cliente
		SocketData.actualizar_clt client

		if data.resourceId != Perfil.getResourceId()
			if data.cliente.answered == 'correct'
				audio = new Audio('/sounds/Pin.wav');
				audio.play();
			else
				audio = new Audio('/sounds/Error.wav');
				audio.play();

	);
	socket.on('next_question', (data)-> # Me avisan que alguien respondió algo
		SocketData.set_waiting()
		$rootScope.$emit 'next_question'
	);
	socket.on('goto_question_no', (data)-> # Me avisan que alguien respondió algo
		SocketData.set_waiting()
		$rootScope.$emit 'goto_question_no', message.numero
	);
	socket.on('set_free_till_question', (data)-> # Me avisan que alguien respondió algo
		SocketData.config.info_evento.free_till_question = message.free_till_question
		$rootScope.$emit 'set_free_till_question', message.free_till_question # Si estaba esperando pregunta, con esto arranca
	);


		
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


	desloguear = ()->
		@emit('desloguear')


	conectar = (qr)->
		nombre_p = if localStorage.getItem('nombre_punto') == null then false else localStorage.getItem('nombre_punto') 
		if qr
			@emit('conectar',  { qr: qr, nombre_punto: nombre_p })
		else
			@emit('conectar', { nombre_punto: nombre_p })


	got_qr = (qr, usuario_id)->
		if usuario_id
			datos = { qr: qr, 'usuario_id': usuario_id, from_token: $cookies.get('xtoken') }
			@emit('got_qr', datos)
		else
			@emit('got_qr', { qr: qr, from_token: $cookies.get('xtoken') })

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
		@emit('guardar:nombre_punto', { resourceId: resourceId, nombre: nombre })

	get_usuarios = ()->
		#console.log SocketClientes.usuarios_all.length
		if SocketClientes.usuarios_all.length == 0
			xtoken = $cookies.get('xtoken')
			@emit('get_usuarios', { from_token: xtoken })

	change_a_categ_selected = (resourceId, categoria_id)->
		client = SocketData.cliente resourceId
		client.categsel = categoria_id
		SocketData.actualizar_clt client, categoria_id
		@emit('change_a_categ_selected',  { resourceId: resourceId, categsel: categoria_id })

	# El participante selecciona una categoría por su cuenta y llama a esta función
	change_my_categ_selected = (categoria_id)->
		client = SocketData.cliente(Perfil.getResourceId())
		client.categsel = categoria_id
		SocketData.actualizar_clt(client, categoria_id)
		@emit('warn_my_categ_selected', { categsel: categoria_id })

	empezar_examen = ()->
		@emit('empezar_examen')
		audio = new Audio('/sounds/Sirviendo.wav');
		audio.play();

	empezar_examen_cliente = (resourceId)->
		@emit('empezar_examen_cliente', { resourceId: resourceId })

	sc_show_participantes = ()->
		@emit('sc_show_participantes')

	sc_show_barras = ()->
		@emit('sc_show_barras')

	sc_show_question = (no_question, pregunta)->
		@emit('sc_show_question', { no_question: no_question, pregunta: pregunta })

	sc_reveal_answer = ()->
		@emit('sc_reveal_answer')

	sc_show_logo_entidad_partici = (valor)->
		@emit('sc_show_logo_entidad_partici', { valor: valor })

	sc_show_puntaje_particip = (client)->
		@emit('sc_show_puntaje_particip', { cliente: client })

	sc_show_puntaje_examen = (examen)->
		@emit('sc_show_puntaje_examen', { examen: examen })

	sc_answered = (valor, tiempo)->
		resourceId = Perfil.getResourceId()
		@emit('sc_answered', { resourceId: resourceId, valor: valor, tiempo: tiempo })

	sc_next_question = ()->
		SocketData.set_waiting()
		@emit({ 'next_question' })
		audio = new Audio('/sounds/Siguiente.wav');
		audio.play();

	sc_next_question_cliente = (cliente)->
		client = SocketData.cliente(cliente.resourceId)
		client.answered = 'waiting'
		@emit('next_question', { resourceId: cliente.resourceId })

	sc_goto_question_no_clt = (cliente, numero)->
		client = SocketData.cliente(cliente.resourceId)
		client.answered = 'waiting'
		@emit('goto_question_no_clt', { resourceId: cliente.resourceId, numero: numero })

	liberar_hasta_pregunta = (numero)->
		@emit('liberar_hasta_pregunta', { numero: numero })
		SocketData.config.info_evento.preg_actual = numero





	############################################
	# Metodos externos
	methods = {
		usuarios_all: 				@usuarios_all,
		conectar: 					conectar,
		readyState: ()->
			socket.connected
		on: 						io_on
		emit: 						emit
		registrar: 					registrar
		desloguear:					desloguear
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


