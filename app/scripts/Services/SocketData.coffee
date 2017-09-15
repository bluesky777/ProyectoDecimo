angular.module('WissenSystem')


.factory('SocketData', ['SocketClientes', '$rootScope', '$filter', '$q', (SocketClientes, $rootScope, $filter, $q) ->
	
	@cliente_to_show		= []
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


	actualizar_clt = (client, propiedad)=>
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
		
		if client.registered
			found 		= false
			index 		= 0
			for clt, indice in SocketClientes.registrados_no_logged
				if clt.resourceId == client.resourceId
					found 		= true
					index 		= indice

			if found
				SocketClientes.registrados_no_logged.splice index, 1

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
				for clt, indice in SocketClientes.sin_registrar
					if clt.resourceId == client.resourceId
						SocketClientes.sin_registrar.splice indice, 1, client
		
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
		return false






	methods = {
		desconectar: 				desconectar
		token_auth:					token_auth
		cliente:					cliente
		get_cliente:				get_cliente
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

	{
		clientes: 					@clientes,
		registrados_logueados: 		@registrados_logueados,
		registrados_no_logged: 		@registrados_no_logged,
		sin_registrar: 				@sin_registrar,
		usuarios_all: 				@usuarios_all,
		mensajes: 					@mensajes
	}
])
