angular.module('WissenSystem')

.controller('ControlCtrl', ['$scope', 'Restangular', 'toastr', '$state', '$window', 'MySocket', 'SocketData', 'SocketClientes', '$rootScope', '$mdSidenav', '$filter', '$uibModal', 'App', '$timeout',  ($scope, Restangular, toastr, $state, $window, MySocket, SocketData, SocketClientes, $rootScope, $mdSidenav, $filter, $modal, App, $timeout)->


	$scope.SocketData 				= SocketData
	$scope.SocketClientes 			= SocketClientes
	$scope.cltdisponible_selected 	= {}
	$scope.categorias_king 			= []
	$scope.categorias_traducidas 	= []
	$scope.cmdCategSelected 		= {}
	$scope.cmdPreguntasTraduc 		= []
	$scope.cmdPreguntaSelected		= {}
	$scope.cmdNoPregSelected		= 0
	$scope.cmdNoPregunta			= 1
	$scope.cmdShowLogoEntidadPartici = false
	$scope.show_result_table 		= true
	$scope.fondo 					= {}


	$rootScope.silenciar_todo 			= if localStorage.getItem('silenciar_todo') then localStorage.getItem('silenciar_todo') else false
	$rootScope.silenciar_todo 			= if $rootScope.silenciar_todo == 'true' then true else false
	$scope.silenciar_todo 				= $rootScope.silenciar_todo

	$rootScope.silenciar_respuestas 	= if localStorage.getItem('silenciar_respuestas') then localStorage.getItem('silenciar_respuestas') else false
	$rootScope.silenciar_respuestas 	= if $rootScope.silenciar_respuestas == 'true' then true else false
	$scope.silenciar_respuestas 		= $rootScope.silenciar_respuestas


	MySocket.on('take:usuarios', (data)->
		console.log 'Llegaron los usuarios'
	)

	$scope.registrados_logueados = ()->
		return SocketClientes.registrados_logueados

	$scope.registrados_no_logged = ()->
		return SocketClientes.registrados_no_logged

	$scope.sin_registrar = ()->
		return SocketClientes.sin_registrar

	$scope.all_clientes = ()->
		return SocketClientes.clientes


	$scope.configurar_imagenes = ()->

		Restangular.one('imagenes/usuarios').customGET().then((r)->
			$scope.imagenes = r.imagenes
		, (r2)->
			toastr.error 'No se trajeron las imágenes.'
		)


		$scope.misImagenes = ()->

			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/misImagenes.tpl.html'
				controller: 'MisImagenes'
				size: 'lg',
				resolve:
					resolved_user: ()->
						$scope.USER
			})
			modalInstance.result.then( (elem)->
				$scope.imagenes.push elem
			)

	$scope.establecer_fondo = ()->
		MySocket.establecer_fondo($scope.fondo.imagen_seleccionada.nombre)

	$scope.mostrar_solo_fondo = ()->
		MySocket.mostrar_solo_fondo($scope.fondo.imagen_seleccionada.nombre)

	$scope.cambiar_teleprompter = ()->
		MySocket.cambiar_teleprompter($scope.msg_teleprompter)

	$scope.mostrar_result_table = ()->
		$scope.show_result_table = true


	Restangular.all('evaluaciones/categorias-con-preguntas').getList().then((r)->
		$scope.categorias_king 			= r
		SocketClientes.categorias_king 	= r
		$scope.categorias_traducidas 	= $filter('categoriasTraducidas')($scope.categorias_king, $scope.USER.idioma_main_id)

		if $scope.categorias_king.length == 1
			$scope.cmdClickCategSelected($scope.categorias_king[0])
	, (r2)->
		toastr.warning 'No se trajeron las categorias del evento', 'Problema'
	)


	$scope.CerrarServidor = ()->
		#res = confirm "¿Seguro que desea cerrar servidor?"
		#if res
		Restangular.one('chat/cerrar-servidor').customPUT().then((r)->
			toastr.success 'Cerrado', r
		, (r2)->
			toastr.warning 'No se cerró servidor'
			console.log 'No se cerró servidor ', r2
		)

	$scope.openMenu = ($mdOpenMenu, ev)->
		$mdOpenMenu(ev);

	$scope.openMenuCateg = ($mdOpenMenu, ev)->
		$mdOpenMenu(ev);

	$scope.showSidenavEditUsu = (cliente)->
		console.log cliente
		$scope.clt_to_edit = cliente
		$mdSidenav('sidenavEditusu').toggle()
			.then( ()->
				console.log("toggle is done");
			)

	$scope.showSidenavSelectUsu = (cliente)->
		$scope.cltdisponible_selected = cliente
		MySocket.get_usuarios()
		$scope.clt_to_edit = cliente.user_data
		$mdSidenav('sidenavSelectusu').toggle()
			.then( ()->
				#console.log("toggle  is done");
			)

	$scope.Conectar = ()->
		MySocket.conectar()


	$scope.qrScanear = ()->
		url = $state.href('qrscanner')
		$window.open(url,'_blank')
		return true

	$scope.crearservidor = ()->
		url = $state.href('panel.crearservidor')
		$window.open(url,'_blank')
		return true

	$scope.enviarMensajeTo = ()->
		sent = false
		if $scope.newMensaje != ''
			for cliente in SocketClientes.registrados_logueados
				if cliente.seleccionado
					MySocket.send_email_to $scope.newMensaje, cliente
					sent = true

			for cliente in SocketClientes.registrados_no_logged
				if cliente.seleccionado
					MySocket.send_email_to $scope.newMensaje, cliente
					sent = true

			for cliente in SocketClientes.sin_registrar
				if cliente.seleccionado
					MySocket.send_email_to $scope.newMensaje, cliente
					sent = true
			if sent
				$scope.newMensaje = ''


	$scope.deseleccionarTodo = ()->
		for cliente in SocketClientes.clientes
			if cliente.seleccionado
				cliente.seleccionado = false

	$scope.seleccionarTodo = ()->
		for cliente in SocketClientes.clientes
			if !cliente.seleccionado
				cliente.seleccionado = true

	$scope.actualizarClts = ()->
		MySocket.get_clts()

	$scope.guardarNombrePunto = (cliente)->
		nombre = $filter('clearhtml')(cliente.nombre_punto)
		MySocket.guardar_nombre_punto(cliente.resourceId, nombre)



	###
		GARGAR RESULTADOS
	###

	$scope.cargar_resultados = ()->
		MySocket.get_clts()

		ids = []

		for partic in SocketClientes.clientes
			if partic.examen_actual_id
				ids.push partic.examen_actual_id


		Restangular.one('puestos/examenes-ejecutandose').customPUT({ids: ids}).then((r)->
			$scope.examenes_cargados = r
		, (r2)->
			toastr.warning 'No se trajeron los exámenes', 'Problema'
			console.log 'No se trajeron los exámenes ', r2
		)


	$scope.sc_mostrar_resultados_actuales = ()->
		MySocket.sc_mostrar_resultados_actuales($scope.examenes_cargados)




	$scope.clickedClt = (event, cliente)->
		if $scope.deseleccionar
			cliente.seleccionado = false
		else
			cliente.seleccionado = !cliente.seleccionado

	$scope.sobreClt = (event, cliente)->
		if event.buttons == 1
			if $scope.deseleccionar
				cliente.seleccionado = false
			else
				cliente.seleccionado = true


	$scope.cerrar_sesion_a = (cliente)->
		res = confirm "¿Cerrar sesión a " + cliente.user_data.nombres + "?"
		if res
			MySocket.cerrar_sesion_a(cliente.resourceId)


	$scope.registrar_a = (cliente)->
		toastr.info "Ahora es un equipo oficial", cliente.nombre_punto
		MySocket.registrar_a(cliente.resourceId)


	$scope.desregistrar_a = (cliente)->
		toastr.info "Deja de ser oficial", cliente.nombre_punto
		MySocket.desregistrar_a(cliente.resourceId)


	$scope.categoriaSelect = (cliente)->
		#console.log cliente
		if cliente
			categorias = $filter('categSelectedDeUsuario')(cliente.user_data.inscripciones, $scope.categorias_king, $scope.USER.idioma_main_id, cliente.categsel)
			if categorias.length > 0
				return categorias[0]
			else
				return {}
		else
			return {}

	### Borrar este pedazo
	$scope.opcion_seleccionada = -1

	$scope.selec_opc_in_question = (opcion)->
		$scope.opcion_seleccionada = opcion
		MySocket.selec_opc_in_question(opcion)


	$scope.sc_reveal_answer = ()->
		if $scope.opcion_seleccionada < 0
			alert('Primero debes elegir opción.')
			return

		MySocket.sc_reveal_answer()

		if !$rootScope.silenciar_todo
			for opcion, indice in $scope.cmdPreguntaSelected.opciones
				if indice == $scope.opcion_seleccionada
					if opcion.is_correct
						audio = new Audio('/sounds/Revelada_correcta.wav');
						audio.play();
					else
						audio = new Audio('/sounds/Revalada_incorrecta.wav');
						audio.play();
	###

	$scope.cambiarCategSel = (cliente, categoria)->
		found = false
		for inscripcion in cliente.user_data.inscripciones
			if categoria.categoria_id == inscripcion.categoria_id
				found = true
		if found
			MySocket.change_a_categ_selected(cliente.resourceId, categoria.categoria_id)


	$scope.empezarExamen = (cliente)->
		MySocket.empezar_examen()
		toastr.info "Examen empezado"
		SocketData.config.info_evento.preg_actual 	= 1

		###
		pregunta = $scope.cmdPreguntasTraduc[0]
		if pregunta
			MySocket.sc_show_question(SocketData.config.info_evento.preg_actual, pregunta)
		else
			toastr.warning 'No hay categoría seleccionada'
		###


	$scope.empezarExamenCliente = (cliente)->
		MySocket.empezar_examen_cliente(cliente.resourceId)

	$scope.empezarExamenCltsSeleccionados = ()->
		for cliente in SocketClientes.clientes
			if cliente.seleccionado
				MySocket.empezar_examen_cliente(cliente.resourceId) # El modelo no cambia hasta salir de esta función


	$scope.showParticipantes = ()->
		MySocket.sc_show_participantes()

	$scope.showBarras = ()->
		MySocket.sc_show_barras()

	$scope.showQuestion = ()->
		MySocket.sc_show_question($scope.cmdNoPregSelected, $scope.cmdPreguntaSelected)

	$scope.showPuntajeParticip = ()->
		MySocket.sc_show_puntaje_particip($scope.cmdCategSelected)

	$scope.cmdClickCategSelected = (categoria)->
		for categ in $scope.categorias_king
			categ.seleccionada = false

		categoria.seleccionada = true

		$scope.cmdCategSelected = categoria
		$scope.cmdPreguntasTraduc = []

		for evaluac in categoria.evaluaciones
			if evaluac.actual
				for preguntasking in evaluac.preguntas_evaluacion
					for preguntatraduc in preguntasking.preguntas_traducidas
						if preguntatraduc.idioma_id == $scope.USER.idioma_main_id
							preguntatraduc.tipo_pregunta 	= preguntasking.tipo_pregunta
							preguntatraduc.nombre_categ 	= categoria.nombre
							preguntatraduc.descrip_categ 	= evaluac.descripcion
							preguntatraduc.cantidad_pregs 	= evaluac.preguntas_evaluacion.length

							$scope.cmdPreguntasTraduc.push preguntatraduc




	$scope.cmdClickPreguntaSelected = (pregunta, indice)->
		for pregu in $scope.cmdPreguntasTraduc
			pregu.seleccionada = false

		pregunta.seleccionada = true
		$scope.cmdNoPregSelected 		= indice + 1
		$scope.cmdPreguntaSelected 		= pregunta

	$scope.toggleShowLogoEntidadParticipantes = ()->
		MySocket.sc_show_logo_entidad_partici(!$scope.cmdShowLogoEntidadPartici) # El modelo no cambia hasta salir de esta función

	$scope.$watch('silenciar_respuestas', (newVal, oldVal)->
		$rootScope.silenciar_respuestas 	= newVal
		localStorage.silenciar_respuestas 	= newVal
	)

	$scope.$watch('silenciar_todo', (newVal, oldVal)->
		$rootScope.silenciar_todo 		= newVal
		localStorage.silenciar_todo 	= newVal
	)


	$scope.nextQuestion = ()->
		MySocket.sc_next_question() # El modelo no cambia hasta salir de esta función

		SocketData.config.info_evento.preg_actual 	= SocketData.config.info_evento.preg_actual + 1
		pregunta = $scope.cmdPreguntasTraduc[ SocketData.config.info_evento.preg_actual - 1 ]

		### No lo quieren por seguridad
		if pregunta
			MySocket.sc_show_question(SocketData.config.info_evento.preg_actual, pregunta)
		else
			toastr.warning 'No hay categoría seleccionada'
		###



	$scope.nextQuestionCliente = (cliente)->
		MySocket.sc_next_question_cliente(cliente) # El modelo no cambia hasta salir de esta función

	$scope.nextQuestionCltsSeleccionados = ()->
		for cliente in SocketClientes.clientes
			if cliente.seleccionado
				MySocket.sc_next_question_cliente(cliente) # El modelo no cambia hasta salir de esta función


	$scope.gotoNoQuestionClt = ()->
		cant = 0
		for cliente in SocketClientes.clientes
			if cliente.seleccionado # Debo quitar el comentario!!!!!
				cant = cant + 1
				MySocket.sc_goto_question_no_clt(cliente, $scope.cmdNoPregunta) # El modelo no cambia hasta salir de esta función
		if cant == 0
			toastr.warning 'Primero debes seleccionar al menos un participante'


	$scope.liberar_hasta_pregunta = ()->
		MySocket.liberar_hasta_pregunta(SocketData.config.info_evento.free_till_question)



	$rootScope.$on('take:clientes', ()->
		$timeout(()->
			$scope.$apply()
		, 1000)

	)



	MySocket.get_clts()










])

