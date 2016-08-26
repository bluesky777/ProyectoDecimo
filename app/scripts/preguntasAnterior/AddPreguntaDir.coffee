angular.module('WissenSystem')

.directive('addPregunta',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/addPreguntaDir.tpl.html"
	scope: 
		preguntasking: "="
		categoria: "="
		examen: "="
		tipo: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'AddPreguntaCtrl'
		

])
