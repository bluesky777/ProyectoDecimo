angular.module('WissenSystem')

.directive('preguntaGrupo',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}grupopreg/preguntaGrupoDir.tpl.html"
	scope: 
		idiomapreg: "="
		preguntagrupo: "="
		indice: "="
		eventoactual: '='

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'PreguntaGrupoCtrl'
		

])
