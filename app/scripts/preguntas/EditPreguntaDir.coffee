angular.module('WissenSystem')

.directive('editPregunta',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/editPreguntaDir.tpl.html"
	scope: false
	controller: 'EditPreguntaCtrl'


])
