angular.module('WissenSystem')

.directive('editContenido',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}grupopreg/editContenidoDir.tpl.html"
	scope: 
		grupoking: "="
		indice: "="
		eventoactual: '='
		idiomaactualselec: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'EditContenidoCtrl'
		

])
