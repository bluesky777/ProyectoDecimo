angular.module('WissenSystem')

.config(['App', '$stateProvider', '$translateProvider', (App, $stateProvider, $translateProvider)->
		
	$stateProvider
		.state('panel.categorias', 
			url: '^/categorias'
			views:
					'contenido_panel':
						templateUrl: "#{App.views}categorias/categorias.tpl.html"
						controller: 'CategoriasCtrl'

				data: 
					pageTitle: 'Categorias'
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