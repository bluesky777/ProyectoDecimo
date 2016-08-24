angular.module('WissenSystem')

.controller('ControlCtrl', ['$scope', 'Restangular', 'toastr', '$state', '$window', 'MySocket', 'SocketData', '$rootScope', '$mdSidenav', '$filter',  ($scope, Restangular, toastr, $state, $window, MySocket, SocketData, $rootScope, $mdSidenav, $filter)->


	$scope.SocketData 				= SocketData
	$scope.cltdisponible_selected 	= {}
	$scope.categorias_king 			= []
	$scope.categorias_traducidas 	= []
	$scope.cmdCategSelected 		= {}
	$scope.cmdPreguntasTraduc 		= []
	$scope.cmdPreguntaSelected		= {}
	$scope.cmdNoPregSelected		= 0
	$scope.cmdShowLogoEntidadPartici = false
	$scope.cmdPreguntaActual 		= 0
	$scope.show_result_table 		= true


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
				console.log("toggle  is done");
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
		$scope.cmdPreguntaActual = 1
		MySocket.empezar_examen()
		toastr.info "Examen empezado"

		pregunta = $scope.cmdPreguntasTraduc[$scope.cmdPreguntaActual]
		if pregunta
			MySocket.sc_show_question($scope.cmdPreguntaActual, pregunta)
		else
			toastr.warning 'No hay categoría seleccionada'


	$scope.empezarExamenCliente = (cliente)->
		MySocket.empezar_examen_cliente(cliente.resourceId)

	$scope.showParticipantes = ()->
		MySocket.sc_show_participantes($scope.categorias_traducidas)

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

		pregunta = $scope.cmdPreguntasTraduc[$scope.cmdPreguntaActual]
		if pregunta
			$scope.cmdPreguntaActual 	= $scope.cmdPreguntaActual + 1
			MySocket.sc_show_question($scope.cmdPreguntaActual, pregunta)
		else
			toastr.warning 'No hay categoría seleccionada'

		

	$scope.nextQuestionCliente = (cliente)->
		MySocket.sc_next_question_cliente(cliente) # El modelo no cambia hasta salir de esta función


	MySocket.get_clts()






])

