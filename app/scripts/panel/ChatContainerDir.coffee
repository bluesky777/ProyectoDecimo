angular.module('WissenSystem')

.directive('chatContainerDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}panel/chatContainerDir.tpl.html"
	scope: false
	controller: 'ChatContainerCtrl'
])

.controller('ChatContainerCtrl', ['$scope', 'App', 'MySocket', 'SocketClientes', '$rootScope', ($scope, App, MySocket, SocketClientes, $rootScope)->

	$scope.imagesPath 		= App.images
	$scope.SocketClientes 	= SocketClientes
	
	$scope.enviarMensaje = ()->

		if $scope.newMensaje != ""

			MySocket.send_email $scope.newMensaje
			$scope.newMensaje = ""

	$rootScope.$on('llegaCorrespondencia', ()->
		$scope.$apply()
	)


])