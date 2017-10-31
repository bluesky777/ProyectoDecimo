angular.module('WissenSystem')

.directive('gridEvaluaciones',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}evaluaciones/gridEvaluacionesDir.tpl.html"

	scope: 
		currenteval: "="
		evaluaciones: "="
		categoriasking: "="
		idioma: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'GridEvaluacionesCtrl'
		

])
