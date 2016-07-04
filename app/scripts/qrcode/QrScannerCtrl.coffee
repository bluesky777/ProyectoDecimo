angular.module('WissenSystem')

.controller('QrScannerCtrl', ['$scope', 'Restangular', 'toastr',  ($scope, Restangular, toastr)->

	$scope.onSuccess = (data)->
		console.log data
		Restangular.one('qr').customPOST({code: data}).then((r)->
			if r.accepted
				toastr.success 'Código acceptado!' + r.comando + r.parametro
			else
				toastr.warning 'Código NO aceptado'
		, (r2)->
			toastr.warning 'No se pudo reconocer el código qr'
			console.log 'No se pudo reconocer el código qr ', r2
		)

	$scope.onError = (error)->
		$scope.errorqr = error

	$scope.onVideoError = (error)->
		$scope.errorqr = error


])

