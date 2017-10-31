angular.module('WissenSystem')

.controller('CrearServidorCtrl', ['$scope', 'Restangular', 'toastr', '$timeout',  ($scope, Restangular, toastr, $timeout)->

	$scope.mytimeout = {}
	$scope.counter = 5
	$scope.onTimeout = ()->
		$scope.counter = $scope.counter - 1
		if $scope.counter < 1
			$scope.stop()
		else
			$scope.mytimeout = $timeout($scope.onTimeout,1000)

	$scope.mytimeout = $timeout($scope.onTimeout,1000)

	$scope.stop = ()->
		$timeout.cancel($scope.mytimeout)
		$scope.diagnostico = "Ya puedes cerrar esta pestaña"


	$scope.mostrarMensaje = ()->
		toastr.info "Por seguridad, no cierres la pestaña hasta que acabe el tiempo"


	Restangular.one('chat').customGET().then((r)->
		console.log 'Conectando...', r
	, (r2)->
		$timeout.cancel($scope.mytimeout)
		toastr.warning 'Error, tal vez el Chat Server ya está activo'
		console.log 'Error, tal vez el Chat Server ya está activo. ', r2
		$scope.diagnostico = 'Error, tal vez el Chat Server ya está activo'
		$scope.counter = 0
	)




])

