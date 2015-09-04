angular.module('WissenSystem')

.directive('editPregTraducDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/editPregTraducDir.tpl.html"
	scope: 
		preguntatraduc: "="
		preguntaking: "="
		eventoactual: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'EditPregTraducDirCtrl'
		

])
