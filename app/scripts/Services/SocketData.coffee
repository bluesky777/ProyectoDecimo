angular.module('WissenSystem')


.factory('SocketData', ['SocketClientes', '$rootScope', '$filter', '$q', 'Perfil', (SocketClientes, $rootScope, $filter, $q, Perfil) ->

	@cliente_to_show		= []
	@clt_selected	= {}
	token_auth		= ''
	config			=
		pregunta: {},
		reveal_answer: false,
		show_logo_entidad_partici: false
		info_evento: { examen_iniciado: false, preg_actual: 0, free_till_question: -1, img_name: '', puestos_ordenados: true }


	desconectar = (resourceId)=>
		SocketClientes.clientes 				= $filter('filter')(SocketClientes.clientes, {resourceId: '!'+resourceId})
		SocketClientes.sin_registrar 			= $filter('filter')(SocketClientes.sin_registrar, {resourceId: '!'+resourceId})
		SocketClientes.registrados_logueados 	= $filter('filter')(SocketClientes.registrados_logueados, {resourceId: '!'+resourceId})
		SocketClientes.registrados_no_logged 	= $filter('filter')(SocketClientes.registrados_no_logged, {resourceId: '!'+resourceId})
		#console.log 'desconectado  ', SocketClientes.clientes




	cliente = (resourceId)=>
		found = false
		for clt in SocketClientes.clientes
			if clt.resourceId == resourceId
				found = clt
				return found

		return found


	get_cliente = (resourceId)=>
		d = $q.defer();
		for clt in SocketClientes.clientes
			if clt.resourceId == resourceId
				d.resolve(clt)

		return d.promise


	cambiar_mi_categsel = (categsel_id, categsel_nombre, categsel_abrev)=>
		client = cliente(Perfil.getResourceId())
		client.categsel 			= categsel_id
		client.categsel_id 			= categsel_id
		client.categsel_nombre 		= categsel_nombre
		client.categsel_abrev 		= categsel_abrev

		actualizar_clt(client)




	actualizar_clt = (client)=>
		for clt, indice in SocketClientes.clientes
			if clt.resourceId == client.resourceId
				SocketClientes.clientes.splice indice, 1, client
		if client.registered
			if client.logged
				for clt, indice in SocketClientes.registrados_logueados
					if clt.resourceId == client.resourceId
						SocketClientes.registrados_logueados.splice indice, 1, client
			else
				for clt, indice in SocketClientes.registrados_no_logged
					if clt.resourceId == client.resourceId
						SocketClientes.registrados_no_logged.splice indice, 1, client
		else
			for clt, indice in SocketClientes.sin_registrar
				if clt.resourceId == client.resourceId
					SocketClientes.sin_registrar.splice indice, 1, client


		return false



	fix_clientes = (clientes)=>
		for client in clientes
			categsel_n = $filter('categSelectedDeUsuario')(client.user_data.inscripciones, SocketClientes.categorias_king, Perfil.User().idioma_main_id, client.categsel)
			if categsel_n.length > 0
				client.categsel_nombre 	= categsel_n[0].nombre
				client.categsel_abrev 	= categsel_n[0].abrev
				client.categsel_id 		= categsel_n[0].categoria_id



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

		categsel_n = $filter('categSelectedDeUsuario')(client.user_data.inscripciones, SocketClientes.categorias_king, Perfil.User().idioma_main_id, client.categsel)
		if categsel_n.length > 0
			client.categsel_nombre 		= categsel_n[0].nombre
			client.categsel_abrev 	= categsel_n[0].abrev
			client.categsel_id 		= categsel_n[0].categoria_id

		if client.registered
			for clt, indice in SocketClientes.registrados_no_logged
				if clt
					if clt.resourceId == client.resourceId
						SocketClientes.registrados_no_logged.splice indice, 1

			for clt, indice in SocketClientes.registrados_logueados
				if clt
					if clt.resourceId == client.resourceId
						SocketClientes.registrados_logueados.splice(indice, 1, client)



		else
			found 	= false
			for clt, indice in SocketClientes.sin_registrar
				if clt.resourceId == client.resourceId
					SocketClientes.sin_registrar.splice(indice, 1, client)
					found 	= true
			if not found
				SocketClientes.sin_registrar.push(client)

		# Ahora lo buscamos en el array de todos los clientes
		found 		= false
		index 		= 0
		for clt, indice in SocketClientes.clientes
			if clt.resourceId == client.resourceId
				found 		= true
				index 		= indice
		if found
			SocketClientes.clientes.splice index, 1, client



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
		for clt, indice in SocketClientes.registrados_logueados
			clt.answered = 'waiting'
		for clt, indice in SocketClientes.sin_registrar
			clt.answered = 'waiting'
		return false






	methods = {
		desconectar: 				desconectar
		token_auth:					token_auth
		cliente:					cliente
		get_cliente:				get_cliente
		cambiar_mi_categsel:		cambiar_mi_categsel
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
	@usuarios_all				= []
	@mensajes					= []
	@categorias_king			= []
	@participantes				= []

	{
		clientes: 					@clientes,
		registrados_logueados: 		@registrados_logueados,
		registrados_no_logged: 		@registrados_no_logged,
		sin_registrar: 				@sin_registrar,
		usuarios_all: 				@usuarios_all,
		mensajes: 					@mensajes
		categorias_king: 			@categorias_king
		participantes: 				@participantes
	}
])
