angular.module('WissenSystem')

.config(['App', '$stateProvider', '$translateProvider', (App, $stateProvider, $translateProvider)->
		
	$stateProvider
		.state('panel.evaluaciones', 
			url: '^/evaluaciones'
			views:
					'contenido_panel':
						templateUrl: "#{App.views}evaluaciones/evaluaciones.tpl.html"
						controller: 'EvaluacionesCtrl'

				data: 
					pageTitle: 'Evaluaciones'
		)



	$translateProvider.translations('EN',
		ENTIDADES_TITLE: 'Tests'
	)
	.translations('ES',
		ENTIDADES_TITLE: 'Evaluaciones'
	)



])
