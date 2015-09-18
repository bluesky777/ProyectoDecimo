angular.module('WissenSystem')

.directive('iniciarDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/iniciarDir.tpl.html"
	scope: 
		eventoactual: "="
		user: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'IniciarCtrl'
		

])
