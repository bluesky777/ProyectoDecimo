angular.module('WissenSystem')

.directive('addPregunta',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/addPreguntaDir.tpl.html"
	scope: false
	controller: 'AddPreguntaCtrl'
		

])
