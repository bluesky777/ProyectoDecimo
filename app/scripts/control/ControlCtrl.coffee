angular.module('WissenSystem')

.controller('ControlCtrl', ['$scope', 'Restangular', 'toastr', '$state', '$window', 'MySocket', 'SocketData', '$rootScope', '$mdSidenav', '$filter', '$uibModal', 'App',  ($scope, Restangular, toastr, $state, $window, MySocket, SocketData, $rootScope, $mdSidenav, $filter, $modal, App)->


	$scope.SocketData 				= SocketData
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
		$scope.categorias_king = r
		$scope.categorias_traducidas = $filter('categoriasTraducidas')($scope.categorias_king, $scope.USER.idioma_main_id)
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
		$scope.clt_to_edit = cliente.usuario
		$mdSidenav('sidenavEditusu').toggle()
			.then( ()->
				console.log("toggle is done");
			)

	$scope.showSidenavSelectUsu = (cliente)->
		$scope.cltdisponible_selected = cliente
		MySocket.get_usuarios()
		$scope.clt_to_edit = cliente.usuario
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

	$scope.enviarMensaje = ()->
		if $scope.newMensaje != ''
			for cliente in SocketData.clientes
				if cliente.seleccionado
					MySocket.send_email_to $scope.newMensaje, cliente
			$scope.newMensaje = ''


	$scope.deseleccionarTodo = ()->
		for cliente in SocketData.clientes
			if cliente.seleccionado
				cliente.seleccionado = false

	$scope.seleccionarTodo = ()->
		for cliente in SocketData.clientes
			if !cliente.seleccionado
				cliente.seleccionado = true

	$scope.actualizarClts = ()->
		MySocket.get_clts()

	$scope.guardarNombrePunto = (cliente)->
		nombre = $filter('clearhtml')(cliente.nombre_punto)
		MySocket.guardar_nombre_punto(cliente.resourceId, nombre)



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


	$scope.cerrarSesion = (cliente)->
		res = confirm "¿Cerrar sesión a " + cliente.usuario.nombres + "?"
		if res 
			MySocket.cerrar_sesion(cliente.resourceId)


	$scope.categoriaSelect = (cliente)->
		categorias = $filter('categSelectedDeUsuario')(cliente.usuario, $scope.categorias_king, $scope.USER.idioma_main_id, cliente.categsel)
		if categorias.length > 0
			return categorias[0]
		else
			return {}

	$scope.cambiarCategSel = (cliente, categoria)->
		MySocket.change_a_categ_selected(cliente.resourceId, categoria.categoria_id)


	$scope.empezarExamen = (cliente)->
		MySocket.empezar_examen()
		toastr.info "Examen empezado"
		SocketData.config.info_evento.preg_actual 	= 1

		pregunta = $scope.cmdPreguntasTraduc[SocketData.config.info_evento.preg_actual]
		if pregunta
			MySocket.sc_show_question(SocketData.config.info_evento.preg_actual, pregunta)
		else
			toastr.warning 'No hay categoría seleccionada'


	$scope.empezarExamenCliente = (cliente)->
		MySocket.empezar_examen_cliente(cliente.resourceId)

	$scope.empezarExamenCltsSeleccionados = ()->
		for cliente in SocketData.clientes
			if cliente.seleccionado
				MySocket.empezar_examen_cliente(cliente.resourceId) # El modelo no cambia hasta salir de esta función
				

	$scope.showParticipantes = ()->
		MySocket.sc_show_participantes($scope.categorias_traducidas)
	
	$scope.showBarras = ()->
		MySocket.sc_show_barras()

	$scope.showQuestion = ()->
		MySocket.sc_show_question($scope.cmdNoPregSelected, $scope.cmdPreguntaSelected)

	$scope.showPuntajeParticip = ()->
		MySocket.sc_show_puntaje_particip($scope.cmdCategSelected)

	$scope.cmdClickCategSelected = (categoria)->
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
							preguntatraduc.catidad_pregs 	= evaluac.preguntas_evaluacion.length

							$scope.cmdPreguntasTraduc.push preguntatraduc




	$scope.cmdClickPreguntaSelected = (pregunta, indice)->
		$scope.cmdNoPregSelected 		= indice + 1
		$scope.cmdPreguntaSelected 		= pregunta

	$scope.toggleShowLogoEntidadParticipantes = ()->
		MySocket.sc_show_logo_entidad_partici(!$scope.cmdShowLogoEntidadPartici) # El modelo no cambia hasta salir de esta función

	$scope.nextQuestion = ()->
		MySocket.sc_next_question() # El modelo no cambia hasta salir de esta función

		SocketData.config.info_evento.preg_actual 	= SocketData.config.info_evento.preg_actual + 1
		pregunta = $scope.cmdPreguntasTraduc[SocketData.config.info_evento.preg_actual]

		if pregunta
			MySocket.sc_show_question(SocketData.config.info_evento.preg_actual, pregunta)
		else
			toastr.warning 'No hay categoría seleccionada'

		

	$scope.nextQuestionCliente = (cliente)->
		MySocket.sc_next_question_cliente(cliente) # El modelo no cambia hasta salir de esta función

	$scope.nextQuestionCltsSeleccionados = ()->
		for cliente in SocketData.clientes
			if cliente.seleccionado
				MySocket.sc_next_question_cliente(cliente) # El modelo no cambia hasta salir de esta función


	$scope.gotoNoQuestionClt = ()->
		cant = 0
		for cliente in SocketData.clientes
			if cliente.seleccionado # Debo quitar el comentario!!!!!
				cant = cant + 1
				MySocket.sc_goto_question_no_clt(cliente, $scope.cmdNoPregunta) # El modelo no cambia hasta salir de esta función
		if cant == 0
			toastr.warning 'Primero debes seleccionar al menos un participante'


	$scope.liberar_hasta_pregunta = ()->
		MySocket.liberar_hasta_pregunta(SocketData.config.info_evento.free_till_question)


	MySocket.get_clts()






])

