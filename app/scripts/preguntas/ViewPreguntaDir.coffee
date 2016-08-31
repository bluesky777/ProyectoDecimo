angular.module('WissenSystem')

.directive('viewPregunta',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/viewPreguntaDir.tpl.html"
	scope: false
	controller: 'ViewPreguntaCtrl'
		

])

.directive('viewPreguntaEval',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}preguntas/viewPreguntaEvalDir.tpl.html"
	scope: 
		preguntaking: "="

	controller: 'ViewPreguntaEvalCtrl'
		

])
