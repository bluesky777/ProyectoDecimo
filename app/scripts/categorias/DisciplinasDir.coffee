angular.module('WissenSystem')

.directive('disciplinasDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}categorias/disciplinasDir.tpl.html"
	###
	scope: 
		preguntasking: "="
	###
	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'DisciplinasCtrl'
		

])
