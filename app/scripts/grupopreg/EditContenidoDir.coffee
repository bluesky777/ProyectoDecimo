angular.module('WissenSystem')

.directive('editContenido',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}grupopreg/editContenidoDir.tpl.html"
	scope: false

	controller: 'EditContenidoCtrl'
		

])
