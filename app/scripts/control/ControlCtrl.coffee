angular.module('WissenSystem')

.controller('ControlCtrl', ['$scope', 'Restangular', 'toastr', '$state', '$window', 'MySocket',  ($scope, Restangular, toastr, $state, $window, MySocket)->

	$scope.CerrarServidor = ()->
		res = confirm "¿Seguro que desea cerrar servidor?"
		if res 
			Restangular.one('chat/cerrar-servidor').customPUT().then((r)->
				toastr.success 'Cerrado', r
			, (r2)->
				toastr.warning 'No se cerró servidor'
				console.log 'No se cerró servidor ', r2
			)
	
	$scope.openMenu = ($mdOpenMenu, ev)->
		$mdOpenMenu(ev);


	$scope.Conectar = ()->
		MySocket.conectar()

		
	$scope.qrScanear = ()->
		url = $state.href('qrscanner')
		$window.open(url,'_blank')
		return true

	$scope.crearservidor = ()->
		url = $state.href('panel.crearservidor')
		$window.open(url,'_blank')
		return true




])

