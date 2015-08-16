angular.module('WissenSystem')

.config(['$stateProvider', 'App', '$translateProvider', ($stateProvider, App, $translateProvider)->

	$stateProvider

	.state('panel.preguntas', { #- Estado admin.
				url: '^/preguntas'
				views:
					'contenido_panel':
						templateUrl: "#{App.views}preguntas/preguntas.tpl.html"
						controller: 'PreguntasCtrl'

				data: 
					pageTitle: 'Preguntas'
			})


	$translateProvider.translations('EN',
		BUSCAR_PLACEHOLDER: 'Find'
		TIP_BTN_NUEVA_PREGUNTA: 'Create a new question'
		BTN_NUEVA_PREGUNTA: 'New question'
	)
	.translations('ES',
		BUSCAR_PLACEHOLDER: 'Buscar'
		TIP_BTN_NUEVA_PREGUNTA: 'Crear una nueva pregunta'
		BTN_NUEVA_PREGUNTA: 'Nueva pregunta'
	)

])