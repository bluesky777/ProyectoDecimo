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
		CATEGORIAS_TITLE: 'Categs'
		NIVELES_TITLE: 'Levels'
		DISCIPLINA_TITLE: 'Disciplines'
	)
	.translations('ES',
		CATEGORIAS_TITLE: 'Categorias'
		NIVELES_TITLE: 'Niveles'
		DISCIPLINA_TITLE: 'Disciplinas'
	)



])