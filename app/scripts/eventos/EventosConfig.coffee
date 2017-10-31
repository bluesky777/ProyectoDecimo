angular.module('WissenSystem')

.config(['App', '$stateProvider', '$translateProvider', (App, $stateProvider, $translateProvider)->
		
	$stateProvider
		.state('panel.eventos', 
			url: '^/eventos'
			views:
				'contenido_panel':
					templateUrl: "#{App.views}eventos/eventos.tpl.html"
					controller: 'EventosCtrl'

				data: 
					pageTitle: 'Eventos'
		)


		.state('panel.eventos_user', 
			url: '/eventos_user'
			templateUrl: 'views/eventos/eventos_user.tpl.html'
			controller: 'EventosUserCtrl'
		)


	$translateProvider.translations('EN',
		EVENTS_TITLE: 'Events'
		CREAR_EVENTO: 'Create event'
	)
	.translations('ES',
		EVENTS_TITLE: 'Eventos'
	)



])