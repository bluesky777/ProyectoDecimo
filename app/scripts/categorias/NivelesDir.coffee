angular.module('WissenSystem')

.directive('nivelesDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}categorias/nivelesDir.tpl.html"
	###
	scope: 
		preguntasking: "="
	###
	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'NivelesCtrl'
		

])
