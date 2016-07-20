angular.module('WissenSystem')

.directive('chatContainerDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}panel/chatContainerDir.tpl.html"
	scope: 
		eventoactual: "="
		user: "="
	controller: 'ChatContainerCtrl'
])

.controller('ChatContainerCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$uibModal', 'App', 'MySocket', '$rootScope', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, MySocket, $rootScope)->

	$scope.imagesPath = App.images
	
	$scope.enviarMensaje = ()->

		if $scope.newMensaje != ""

			MySocket.enviar_correspondencia $scope.newMensaje
			$scope.newMensaje = ""


	$rootScope.$on 'llegaCorrespondencia', (event, datos)->
		$scope.mensajes = datos.mensajes
		



])