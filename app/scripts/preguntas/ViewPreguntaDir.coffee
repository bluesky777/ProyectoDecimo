angular.module('WissenSystem')

.directive('viewPregunta',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/viewPreguntaDir.tpl.html"
	scope: 
		idiomapreg: "="
		preguntaking: "="
		indice: "="
		eventoactual: '='
		eventoactualselec: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'ViewPreguntaCtrl'
		

])
