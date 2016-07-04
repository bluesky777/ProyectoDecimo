'use strict'

angular.module('WissenSystem')
	.config ['$stateProvider', 'App', ($state, App) ->

		$state
			.state 'panel.filemanager',
				url: '/filemanager'
				views: 
					'contenido_panel':
						templateUrl: "#{App.views}fileManager/fileManager.tpl.html"
						controller: 'FileManagerCtrl'
				data: 
					pageTitle: 'Administrador de archivos'



]
