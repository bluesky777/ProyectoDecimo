angular.module('WissenSystem')

.directive('viewGrupo',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}grupopreg/viewGrupoDir.tpl.html"
	scope: false
	controller: 'ViewGrupoCtrl'
		

])

.directive('viewGrupoEval',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}grupopreg/viewGrupoEvalDir.tpl.html"
	scope: 
		idiomapreg: "="
		grupoking: "="
		indice: "="
		eventoactual: '='
		idiomaactualselec: "="
		evaluaciones: "="
		preguntasevaluacion2: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'ViewGrupoEvalCtrl'
		

])
