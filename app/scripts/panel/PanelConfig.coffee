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
						#AuthService.verificar()
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
			CATEGS_MENU: 'Categs'
			IDIOMA_MENU: 'Language'
		)
		.translations('ES',
			INICIO_MENU: 'Inicio'
			EVENTS_MENU: 'Eventos'
			CATEGS_MENU: 'Categorías'
			USERS_MENU: 'Usuarios'
			IDIOMA_MENU: 'Idioma'
		)


		return
	]
