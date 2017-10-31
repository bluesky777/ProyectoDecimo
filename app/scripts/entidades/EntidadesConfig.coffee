angular.module('WissenSystem')

.config(['App', '$stateProvider', '$translateProvider', (App, $stateProvider, $translateProvider)->
		
	$stateProvider
		.state('panel.entidades', 
			url: '^/entidades'
			views:
					'contenido_panel':
						templateUrl: "#{App.views}entidades/entidades.tpl.html"
						controller: 'EntidadesCtrl'

				data: 
					pageTitle: 'Entidades'
		)



	$translateProvider.translations('EN',
		ENTIDADES_TITLE: 'Entities'
	)
	.translations('ES',
		ENTIDADES_TITLE: 'Entidades'
	)



])
