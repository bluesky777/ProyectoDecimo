angular.module('WissenSystem')

.directive('sidenavSelectPcDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}usuarios/sidenavSelectPCDir.tpl.html"
	scope: false
	controller: 'SidenavSelectPCCtrl'
		

])
.controller('SidenavSelectPCCtrl', ['$scope', 'Restangular', 'toastr', 'MySocket', 'SocketData', '$mdSidenav',  ($scope, Restangular, toastr, MySocket, SocketData, $mdSidenav)->
	$scope.selectedUser 		= {}
	
	MySocket.get_clts()
	$scope.SocketData = SocketData

	$scope.ingresar_seleccionado = (computer)->
		MySocket.let_him_enter(SocketData.clt_selected.id, computer.resourceId)
		$scope.cerrar_sidenav()
	
	
		
	$scope.cerrar_sidenav = ()->
		$mdSidenav('sidenavSelectPC').close()
		


])
