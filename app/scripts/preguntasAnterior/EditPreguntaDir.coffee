angular.module('WissenSystem')

.directive('editPregunta',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/editPreguntaDir.tpl.html"
	scope: 
		preguntaking: "="
		eventoactual: "="
		eventoactualselec: "@"

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'EditPreguntaCtrl'
		

])
