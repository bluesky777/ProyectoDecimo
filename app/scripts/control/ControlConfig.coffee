angular.module('WissenSystem')

.config(['App', '$stateProvider', '$translateProvider', (App, $stateProvider, $translateProvider)->

	$stateProvider
		.state('panel.control',
			url: '^/control'
			views:
				'contenido_panel':
					templateUrl: "#{App.views}control/control.tpl.html"
					controller: 'ControlCtrl'

				data:
					pageTitle: 'Control'
		)
		.state('panel.crearservidor',
			url: '^/crearservidor'
			views:
				'contenido_panel':
					templateUrl: "#{App.views}control/crear_servidor.tpl.html"
					controller: 'CrearServidorCtrl'

				data:
					pageTitle: 'Creando Chat Server'
		)



	$translateProvider.translations('EN',
		CLIENTES_CONECTADOS_TL: 'Conected clients'
		CONEXIÓN_TL: 'Connection'
		ABRIR_SERVIDOR_TL: 'Open server'
		CERRAR_SERVIDOR_TL: 'Close server'
		CONECTAR_TL: 'Connect'
		QR_SCANNER_TL: 'QR Scanner'
		DESELECCIONAR_TL: 'Diselect'
		DESELECCIONAR_TODO_TL: 'Diselect all'
		SELECCIONAR_TODO_TL: 'Select all'
		EMPEZAR_EXAMEN_TL: 'Start test  '
		SIGUIENTE_PREGUNTA_TL: 'Next question  '
		ACTUALIZAR_TL: 'Refresh'
		REGISTRADOS_CONECTADOS_TL: 'Conected Registereds'
		CERRAR_SESION_TL: 'Logout'
		EDITAR_TL: 'Edit'
		DISPONIBLES_TL: 'Availables'
		SIN_REGISTRAR_TL: 'Unregistereds'
		NOMBRE_DE_PUNTO_TL: 'Point name'
		SELECCIONAR_UN_USUARIO_TL: 'Diselect an user'
		GUARDAR_NOMBRE_PUNTO_TL: 'Save point name'
		MENSAJE_TL: 'Message'
		ENVIA_UN_MENSAJE_TL: 'Send a message'
		ENVIA_TL: 'Send'
		COMANDOS_TL: 'Commands'
		PREG_TL: 'Current question'
		MOSTRAR_PREGUNTA_TL: 'Show question'
		MOSTRAR_PUNTAJE_TL: 'Show score'
		MOSTRAR_LOGO_ENTIDADES_TL: 'Show entities ad'
		MOSTRAR_PARTICIPANTES_TL: 'Show players'
		MOSTRAR_BARRAS_TL: 'Show bar chart'
		CONFIGURAR_FONDO_TL: 'Config background image'
		ESTABLECER_FONDO_TL: 'Set background image'
		MOSTRAR_SOLO_FONDO_TL: 'Show background only'
		CAMBIAR_TELEPROMPTER_TL: 'Change teleprompter'
		ENVIAR_CLIENTES_SELECCIONADOS_A_UNA_PREGUNTA_TL: 'Send seleccted clients to a question'
		LIBERAR_HASTA_PREGUNTA_TL: 'Free till question'
		IR_TL: 'Go'
		TABLA_DE_RESULTADOS_TL: 'Result table'
		CHAT_PUBLICO_TL: 'Public chat'
	)
	.translations('ES',
		CLIENTES_CONECTADOS_TL: 'Clientes conectados'
		CONEXIÓN_TL: 'Conexión'
		ABRIR_SERVIDOR_TL: 'Abrir servidor'
		CERRAR_SERVIDOR_TL: 'Cerrar servidor'
		CONECTAR_TL: 'Conectar'
		QR_SCANNER_TL: 'Escaner QR'
		DESELECCIONAR_TL: 'Deseleccionar'
		DESELECCIONAR_TODO_TL: 'Deseleccionar todo'
		SELECCIONAR_TODO_TL: 'Seleccionar todo'
		EMPEZAR_EXAMEN_TL: 'Empezar examen  '
		SIGUIENTE_PREGUNTA_TL: 'Siguiente pregunta  '
		ACTUALIZAR_TL: 'Actualizar'
		REGISTRADOS_CONECTADOS_TL: 'Registrados conectados'
		CERRAR_SESION_TL: 'Cerrar sesion'
		EDITAR_TL: 'Editar'
		DISPONIBLES_TL: 'Disponibles'
		SIN_REGISTRAR_TL: 'Sin registrar'
		NOMBRE_DE_PUNTO_TL: 'Nombre de punto'
		SELECCIONAR_UN_USUARIO_TL: 'Seleccionar un usuario'
		GUARDAR_NOMBRE_PUNTO_TL: 'Guardar nombre punto'
		MENSAJE_TL: 'Mensaje'
		ENVIA_UN_MENSAJE_TL: 'Envía un mensaje'
		ENVIA_TL: 'Envía'
		COMANDOS_TL: 'Comandos'
		PREG_TL: 'Pregunta actual'
		MOSTRAR_PREGUNTA_TL: 'Mostrar pregunta'
		MOSTRAR_PUNTAJE_TL: 'Mostrar puntaje'
		MOSTRAR_LOGO_ENTIDADES_TL: 'Mostrar logo entidades'
		MOSTRAR_PARTICIPANTES_TL: 'Mostrar participantes'
		MOSTRAR_BARRAS_TL: 'Mostrar barras'
		CONFIGURAR_FONDO_TL: 'Configurar fondo'
		ESTABLECER_FONDO_TL: 'Establecer fondo'
		MOSTRAR_SOLO_FONDO_TL: 'Mostrar solo fondo'
		CAMBIAR_TELEPROMPTER_TL: 'Cambiar teleprompter'
		ENVIAR_CLIENTES_SELECCIONADOS_A_UNA_PREGUNTA_TL: 'Enviar clientes seleccionados a una pregunta'
		LIBERAR_HASTA_PREGUNTA_TL: 'Liberar hasta pregunta'
		IR_TL: 'Ir'
		TABLA_DE_RESULTADOS_TL: 'Tabla de resultados'
		CHAT_PUBLICO_TL: 'Chat público'
	)



])
