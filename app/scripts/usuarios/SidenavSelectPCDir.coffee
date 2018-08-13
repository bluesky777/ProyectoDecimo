angular.module('WissenSystem')

.directive('sidenavSelectPcDir',['App', (App)->

	restrict: 'E'
	templateUrl: "#{App.views}usuarios/sidenavSelectPCDir.tpl.html"
	scope: false
	controller: 'SidenavSelectPCCtrl'


])
.controller('SidenavSelectPCCtrl', ['$scope', '$rootScope', 'Restangular', 'toastr', 'MySocket', 'SocketData', 'SocketClientes', '$mdSidenav',  ($scope, $rootScope, Restangular, toastr, MySocket, SocketData, SocketClientes, $mdSidenav)->

	$scope.selectedUser 		= {}
	$scope.SocketData 			= SocketData


	MySocket.get_clts()

	$rootScope.$on('take:clientes', ()->
		$timeout(()->
			$scope.$apply()
		, 1000)

	)


	$scope.ingresar_seleccionado = (computer)->
		usu_id = if SocketData.clt_selected.rowid then SocketData.clt_selected.rowid else SocketData.clt_selected.id
		MySocket.let_him_enter(usu_id, computer.resourceId)
		$scope.cerrar_sidenav()

	$scope.all_clientes = ()->
		return SocketClientes.clientes



	$scope.cerrar_sidenav = ()->
		$mdSidenav('sidenavSelectPC').close()



])
