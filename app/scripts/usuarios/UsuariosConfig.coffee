angular.module('WissenSystem')

.config(['$stateProvider', 'App', 'USER_ROLES', ($stateProvider, App, USER_ROLES)->

	$stateProvider

	.state('panel.usuarios', { #- Estado admin.
		url: '^/usuarios'
		views:
			'contenido_panel':
				templateUrl: "#{App.views}usuarios/usuarios.tpl.html"
				controller: 'UsuariosCtrl'

		data:
			pageTitle: 'Usuarios'
			needed_permissions: [USER_ROLES.tecnico, USER_ROLES.ejecutor]
	})


])
