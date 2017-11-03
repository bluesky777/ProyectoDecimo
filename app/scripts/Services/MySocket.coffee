angular.module('WissenSystem')

.factory('MySocket', ['App', '$q', '$rootScope', 'Perfil', '$timeout', '$cookies', '$http', '$state', 'SocketData', 'SocketClientes', '$filter', 'webNotification', (App, $q, $rootScope, Perfil, $timeout, $cookies, $http, $state, SocketData, SocketClientes, $filter, webNotification) ->


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

		if !localStorage.getItem('registered_boolean')
			localStorage.registered_boolean = false

		registered = if localStorage.getItem('registered_boolean') then localStorage.getItem('registered_boolean')  else false 
		registered = if registered=='false' then false else registered
		Perfil.setRegistered(registered)

		if Perfil.User().id
			@emit('loguear', {usuario: Perfil.User(), registered: registered, nombre_punto: localStorage.nombre_punto} )
		else
			nombre_p = if localStorage.getItem('nombre_punto') == null then false else localStorage.getItem('nombre_punto') 
			if nombre_p
				@emit('reconocer:punto:registered', { nombre_punto: nombre_p, registered: registered })
			else
				@emit('reconocer:punto:registered', { nombre_punto: nombre_p, registered: registered })
				#$rootScope.$emit 'reconocido:mi_nombre_punto', {nombre_punto: data.datos.nombre_punto }
	);
	socket.on('logueado:yo', (data)->
		if SocketClientes.categorias_king.length == 0
			if data.categorias_king
				SocketClientes.categorias_king = data.categorias_king

		SocketData.config.info_evento = data.info_evento
		Perfil.setResourceId data.yo.resourceId
		$rootScope.$emit('logueado:yo:agregado_a_arrays', data.yo)
		SocketData.logueado data.yo
	);
	socket.on('logueado:alguien', (data)->
		if SocketClientes.categorias_king.length == 0
			if data.categorias_king
				SocketClientes.categorias_king = data.categorias_king
		SocketData.logueado data.clt
		$rootScope.$apply()
	);

	socket.on('user:left', (data)->
		SocketData.desconectar data.resourceId
		#$rootScope.$emit 'desconectado:alguien', {clientes: SocketClientes.clientes }
		$rootScope.$apply()
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

		if $state.is('proyectando.grafico_barras')
			SocketClientes.participantes = []
			for client in SocketClientes.clientes
				if client.categsel > 0
					SocketClientes.participantes.push(client)

		$rootScope.$apply()
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
			$rootScope.$emit 'reconocido:mi_nombre_punto', {nombre_punto: data.nombre_punto } # En LoginCtrl
	);

	socket.on('deslogueado', (data)->
		# No actualiza la lista de clientes registrados en control a menos que le de get_clts() # bueno, tal vez si
		#SocketData.deslogueado data.client # Viene el cliente con sus propiedades ya arregladas para unregistrar
		get_clts()
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

		webNotification.showNotification(data.mensaje.from.user_data.nombres + ' ' + data.mensaje.from.user_data.apellidos, {
			body: data.mensaje.texto,
			icon: 'images/system/favicon-myvc.ico',
			autoClose: 6000 
		}, (error, hide)->
			if (error) 
				console.log('Unable to show notification: ' + error.message);
			else
				setTimeout(()->
					console.log('Hiding notification....');
					hide();
				, 6000);
		)

		$rootScope.$emit 'llegaCorrespondencia' # En chatContainerDir
	);
	socket.on('a_establecer_fondo', (data)->
		SocketData.config.info_evento.img_name = data.img_name
		$rootScope.$apply()
	);

	socket.on('a_mostrar_solo_fondo', (data)->
		$state.transitionTo 'proyectando'
	);

	socket.on('a_cambiar_teleprompter', (data)->
		SocketData.config.info_evento.msg_teleprompter = data.msg_teleprompter
		$state.transitionTo 'proyectando'
		$rootScope.$apply()
	);

	socket.on('sesion_closed', (data)->
		if data.clt.resourceId == Perfil.getResourceId()
			unregister()
			localStorage.lastState 		= null
			localStorage.lastStateParam 	= null
			$rootScope.permiso_de_salir = true
			Perfil.deleteUser()
			$state.transitionTo 'login'
			$cookies.remove('xtoken')
			delete $http.defaults.headers.common['Authorization']
	);

	socket.on('cerrar:tu_sesion', (data)->
		$rootScope.$emit 'me_desloguearon'	# En PanelCtrl
	);

	socket.on('me_registraron', (data)->
		localStorage.registered_boolean = true
		client 				= SocketData.cliente(Perfil.getResourceId())
		client.registered 	= true
		SocketData.actualizar_clt(client)
		$rootScope.$apply()
	);
	socket.on('me_desregistraron', (data)->
		localStorage.registered_boolean = false
		client 				= SocketData.cliente(Perfil.getResourceId())
		client.registered 	= false
		SocketData.actualizar_clt(client)
		$rootScope.$apply()
	);

	socket.on('nombre_punto_cambiado', (data)->
		client 					= SocketData.cliente data.resourceId
		client.nombre_punto 	= $filter('clearhtml')(data.nombre)
		$rootScope.$emit 'nombre_punto_cambiado', {nombre: client.nombre_punto, resourceId: data.resourceId }	
	);
	socket.on('take_usuarios', (data)->
		SocketClientes.usuarios_all = data.usuarios
	);

	# Siendo participante, me ordenan que cambie mi categoría
	socket.on('change_the_categ_selected', (data)->
		client 				= SocketData.cliente Perfil.getResourceId()
		SocketData.cambiar_mi_categsel(data.categsel, data.categsel_nombre, data.categsel_abrev)
		$rootScope.$emit 'categ_selected_change', data.categsel # En IniciarCtrl
	);
	socket.on('change_a_categ_selected', (data)->
		client 						= SocketData.cliente data.resourceId
		client.categsel 			= data.categsel
		client.categsel_id 			= data.categsel
		client.categsel_nombre 		= data.categsel_nombre
		client.categsel_abrev 		= data.categsel_abrev
		SocketData.actualizar_clt client
	);

	socket.on('a_categ_selected_change', (data)->
		client 						= SocketData.cliente data.resourceId
		client.categsel 			= data.categsel
		client.categsel_id 			= data.categsel
		client.categsel_nombre 		= data.categsel_nombre
		client.categsel_abrev 		= data.categsel_abrev
		SocketData.actualizar_clt client
	);

	socket.on('empezar_examen', (data)->
		$rootScope.$emit 'empezar_examen' # En IniciarCtrl
	);

	socket.on('sc_show_participantes', (data)->
		rolesFound = $filter('filter')(Perfil.User().roles, {name: 'Pantalla'})
		if rolesFound
			if rolesFound.length > 0
				get_clts()
				if $state.is('proyectando.participantes')
					$rootScope.$apply()
				else
					$state.go('proyectando.participantes')
	);

	socket.on('sc_mostrar_resultados_actuales', (data)->
		rolesFound = $filter('filter')(Perfil.User().roles, {name: 'Pantalla'})
		if rolesFound
			if rolesFound.length > 0
				$rootScope.examenes_cargados = data.examenes_cargados
				if $state.is('proyectando.puntajes_actuales')
					$rootScope.$apply()
				else
					$state.go('proyectando.puntajes_actuales')
	);

	socket.on('sc_show_barras', (data)->
		get_clts()
		
		SocketClientes.participantes = []
		for client in SocketClientes.clientes
			if client.categsel > 0
				SocketClientes.participantes.push(client)
		$state.go('proyectando.grafico_barras')
		$rootScope.$apply()
	);

	socket.on('sc_show_question', (data)->
		role = Perfil.User().roles[0].name

		if (role == 'Pantalla' or role == 'Presentador' or role == 'Admin')

			SocketData.config.pregunta 			= data.pregunta
			SocketData.config.no_question 		= data.no_question
			SocketData.config.reveal_answer 	= false 

			if (Perfil.User().roles[0].name == 'Pantalla')
				$state.go('proyectando.question')

			$rootScope.$apply()

	);

	#socket.on('selec_opc_in_question' ... 		En SCQuestionCtrl
	#socket.on('sc_reveal_answer' ... 			En SCQuestionCtrl

	socket.on('sc_show_logo_entidad_partici', (data)->
		SocketData.config.show_logo_entidad_partici = data.valor
		$rootScope.$apply()
	);

	socket.on('sc_show_puntaje_particip', (data)->
		SocketData.config.cliente_to_show = data.cliente
		$state.go('proyectando.puntaje_particip')
		$rootScope.$apply()
	);

	socket.on('sc_show_puntaje_examen', (data)->
		SocketData.config.puntaje_to_show = data.examen
		$state.go('proyectando.puntaje_particip')
		$rootScope.$apply()
	);

	socket.on('sc_answered', (data)-> # Me avisan que alguien respondió algo
		get_clts()

		if not $state.includes('proyectando') 
			if !$rootScope.silenciar_respuestas 
				if !$rootScope.silenciar_todo
					if data.resourceId != Perfil.getResourceId()
						if data.cliente.answered == 'correct'
							audio = new Audio('/sounds/Pin.wav');
							audio.play();
						else
							audio = new Audio('/sounds/Error.wav');
							audio.play();
	);

	socket.on('next_question', (data)-> 
		SocketData.set_waiting()
		$rootScope.$apply()
		$rootScope.$emit 'next_question'
	);

	socket.on('goto_question_no', (data)-> 
		SocketData.set_waiting()
		$rootScope.$emit 'goto_question_no', data.numero
	);

	socket.on('set_free_till_question', (data)-> 
		SocketData.config.info_evento.free_till_question = data.free_till_question
		$rootScope.$emit 'set_free_till_question', data.free_till_question # En ExamenRespuestaCtrl y ParticipantesCtrl, Si estaba esperando pregunta, con esto arranca
	);


	socket.on('set_puestos_ordenados', (data)-> 
		SocketData.config.info_evento.puestos_ordenados = data.puestos_ordenados
		#$rootScope.$emit 'set_puestos_ordenados', data.puestos_ordenados # En ExamenRespuestaCtrl y ParticipantesCtrl, Si estaba esperando pregunta, con esto arranca
	);


	#on enter() #en LoginCtrl y PanelCtrl


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
		registered = if localStorage.getItem('registered_boolean') == null then false else localStorage.getItem('registered_boolean') 
		registered = if registered=='false' then false else true
		@emit('desloguear', {registered: registered, nombre_punto: localStorage.nombre_punto})


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
			socket.emit('get_clts')
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

	cerrar_sesion_a = (resourceId)->
		@emit('cerrar_sesion_a', { resourceId: resourceId })

	registrar_a = (resourceId)->
		@emit('registrar_a', { resourceId: resourceId })

	desregistrar_a = (resourceId)->
		@emit('desregistrar_a', { resourceId: resourceId })

	guardar_nombre_punto = (resourceId, nombre)->
		nombre = $filter('clearhtml')(nombre)
		@emit('guardar:nombre_punto', { resourceId: resourceId, nombre: nombre })

	get_usuarios = ()->
		#console.log SocketClientes.usuarios_all.length
		if SocketClientes.usuarios_all.length == 0
			xtoken = $cookies.get('xtoken')
			@emit('get_usuarios', { from_token: xtoken })

	change_a_categ_selected = (resourceId, categoria_id)->
		client 			= SocketData.cliente resourceId
		client.categsel = categoria_id

		categsel_n = $filter('categSelectedDeUsuario')(client.user_data.inscripciones, SocketClientes.categorias_king, Perfil.User().idioma_main_id, client.categsel)
		if categsel_n.length > 0 
			client.categsel_nombre 	= categsel_n[0].nombre
			client.categsel_abrev 	= categsel_n[0].abrev
			client.categsel_id 		= categsel_n[0].categoria_id

		SocketData.actualizar_clt client, categoria_id

		@emit('change_a_categ_selected',  { resourceId: resourceId, categsel: categoria_id, categsel_nombre: client.categsel_nombre, categsel_abrev: client.categsel_abrev })

	# El participante selecciona una categoría por su cuenta y llama a esta función
	change_my_categ_selected = (categoria_id, nombre, abrev)->
		@emit('warn_my_categ_selected', { categsel: categoria_id, categsel_nombre: nombre, categsel_abrev: abrev })

	empezar_examen = ()->
		@emit('empezar_examen')
		if !$rootScope.silenciar_todo
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

	selec_opc_in_question = (opcion)->
		@emit('selec_opc_in_question', { opcion: opcion })

	sc_reveal_answer = ()->
		@emit('sc_reveal_answer')

	sc_show_logo_entidad_partici = (valor)->
		@emit('sc_show_logo_entidad_partici', { valor: valor })

	sc_show_puntaje_particip = (client)-> # No está funcionando
		if client.puesto = 1
			$timeout(()->
				@emit('sc_show_puntaje_particip', { cliente: client })
			, 1800)
			if !$rootScope.silenciar_todo
				audio = new Audio('/sounds/Siguiente.wav');
				audio.play();
		else
			@emit('sc_show_puntaje_particip', { cliente: client })

	sc_show_puntaje_examen = (examen)->
		if examen.puesto == 1
			$timeout(()=>
				@emit('sc_show_puntaje_examen', { examen: examen })
			, 1800)
			if !$rootScope.silenciar_todo
				audio = new Audio('sounds/Primer_lugar.wav');
				audio.play();
		else
			@emit('sc_show_puntaje_examen', { examen: examen })

	sc_answered = (valor, tiempo)->
		resourceId = Perfil.getResourceId()
		@emit('sc_answered', { resourceId: resourceId, valor: valor, tiempo: tiempo })

	sc_next_question = ()->
		SocketData.set_waiting()
		@emit('next_question')
		if !$rootScope.silenciar_todo
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

	
	sc_mostrar_resultados_actuales = (examenes_cargados)->
		@emit('sc_mostrar_resultados_actuales', { examenes_cargados: examenes_cargados })


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
		cerrar_sesion_a: 			cerrar_sesion_a
		registrar_a: 				registrar_a
		desregistrar_a: 			desregistrar_a
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
		selec_opc_in_question:		selec_opc_in_question
		sc_reveal_answer:			sc_reveal_answer
		sc_show_logo_entidad_partici:	sc_show_logo_entidad_partici
		sc_show_puntaje_particip:	sc_show_puntaje_particip
		sc_show_puntaje_examen:		sc_show_puntaje_examen
		sc_answered:				sc_answered
		sc_next_question:			sc_next_question
		sc_next_question_cliente:	sc_next_question_cliente
		sc_goto_question_no_clt:	sc_goto_question_no_clt
		sc_mostrar_resultados_actuales: sc_mostrar_resultados_actuales
		liberar_hasta_pregunta:		liberar_hasta_pregunta
	}

	return methods

])


