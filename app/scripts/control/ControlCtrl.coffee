angular.module('WissenSystem')

.controller('ControlCtrl', ['$scope', 'Restangular', 'toastr', '$state', '$window',  ($scope, Restangular, toastr, $state, $window)->

	$scope.mensajes = []
	
	$scope.enviarMensaje = ()->

		$scope.conn.send($scope.newMensaje)
		$scope.mensajes.push $scope.newMensaje

		$scope.newMensaje = ""


	$scope.CerrarServidor = ()->

		Restangular.one('chat/cerrar-servidor').customPUT().then((r)->
			toastr.success 'Cerrado', r
		, (r2)->
			toastr.warning 'No se cerró servidor'
			console.log 'No se cerró servidor ', r2
		)
		

	$scope.Conectar = ()->

		$scope.conn = new WebSocket('ws://192.168.1.31:8787');
			
		$scope.conn.onopen = (e)->
			console.log("Connection established!");


		$scope.conn.onmessage = (e)->
			toastr.success 'Recibiendo...'
			console.log(e);
			$scope.mensajes.push e.data

		$scope.conn.onerror = (e)->
			console.log(e);
		
	$scope.qrScanear = ()->
		url = $state.href('qrscanner')
		$window.open(url,'_blank')
		return true

	$scope.crearservidor = ()->
		url = $state.href('panel.crearservidor')
		$window.open(url,'_blank')
		return true




])

