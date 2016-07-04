angular.module('WissenSystem')

.controller('CrearServidorCtrl', ['$scope', 'Restangular', 'toastr', '$timeout',  ($scope, Restangular, toastr, $timeout)->

	$scope.counter = 5
	$scope.onTimeout = ()->
		$scope.counter = $scope.counter - 1
		mytimeout = $timeout($scope.onTimeout,1000)

	mytimeout = $timeout($scope.onTimeout,1000)

	$scope.stop = ()->
		$timeout.cancel(mytimeout)
		$scope.counter = "Ya puedes cerrar esta pestaña"


	$scope.mostrarMensaje = ()->
		toastr.info "Por seguridad, no cierres pestaña hasta que acabe el tiempo"

	Restangular.one('chat').customGET().then((r)->
		console.log 'Conectando...', r
	, (r2)->
		$timeout.cancel(mytimeout)
		toastr.warning 'Error, tal vez el Chat Server ya está activo'
		console.log 'Error, tal vez el Chat Server ya está activo. ', r2
		$scope.counter = 'Error, tal vez el Chat Server ya está activo'
	)




])

