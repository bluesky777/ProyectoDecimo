angular.module('WissenSystem')

.directive('editPregTraducDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/editPregTraducDir.tpl.html"
	scope: true

	controller: 'EditPregTraducDirCtrl'
		

])
