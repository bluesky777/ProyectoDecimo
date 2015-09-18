'use strict'

angular.module('WissenSystem')
	.config ['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', '$translateProvider', ($state, App, USER_ROLES, PERMISSIONS, $translateProvider) ->

		$state
			.state('panel', { #- Estado admin.
				url: '/panel'
				views:
					'principal':
						templateUrl: "#{App.views}panel/panel.tpl.html"
						controller: 'PanelCtrl'
				resolve: { 
					resolved_user: ['AuthService', (AuthService)->
						AuthService.verificar()
					]
				}
				data: 
					pageTitle: 'WissenSystem - Bienvenido'
			})


		$translateProvider.preferredLanguage('ES');


		$translateProvider.translations('EN',
			INICIO_MENU: 'Home'
			USERS_MENU: 'Users'
			EVENTS_MENU: 'Events'
			ENTIDADES_MENU: 'Entities'
			CATEGS_MENU: 'Categories'
			PREGUNTAS_MENU: 'Questions'
			EVALUACIONES_MENU: 'Tests'
			IDIOMA_MENU: 'Language'
		)
		.translations('ES',
			INICIO_MENU: 'Inicio'
			EVENTS_MENU: 'Eventos'
			ENTIDADES_MENU: 'Entidades'
			CATEGS_MENU: 'Categorías'
			PREGUNTAS_MENU: 'Preguntas'
			EVALUACIONES_MENU: 'Evaluaciones'
			USERS_MENU: 'Usuarios'
			IDIOMA_MENU: 'Idioma'

			ELIMINATORIAS: 'Eliminatorias'
			GRAN_FINAL: 'Gran final'
			INSCRITO_EN: 'Estás inscrito en:'
			EXAM_HECHOS: 'Exámenes hechos'

		)


		return
	]
