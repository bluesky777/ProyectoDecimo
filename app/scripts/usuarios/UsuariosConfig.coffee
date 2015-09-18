angular.module('WissenSystem')

.config(['$stateProvider', 'App', 'PERMISSIONS', ($stateProvider, App, PERMISSIONS)->

	$stateProvider

	.state('panel.usuarios', { #- Estado admin.
				url: '^/usuarios'
				views:
					'contenido_panel':
						templateUrl: "#{App.views}usuarios/usuarios.tpl.html"
						controller: 'UsuariosCtrl'

				data: 
					pageTitle: 'Usuarios'
					needed_permissions: [PERMISSIONS.can_edit_usuarios]
			})


])