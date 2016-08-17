angular.module('WissenSystem')

.config(['$stateProvider', 'App', '$translateProvider', ($stateProvider, App, $translateProvider)->

	$stateProvider

	.state('panel.perfil', { #- Estado admin.
				url: '^/perfil'
				views:
					'contenido_panel':
						templateUrl: "#{App.views}perfil/perfil.tpl.html"
						controller: 'PerfilCtrl'

				data: 
					pageTitle: 'Perfil'
			})


	$translateProvider.translations('EN',
		PASS: 'Contraseña'
	)
	.translations('ES',
		PASS: 'Password'
	)

])