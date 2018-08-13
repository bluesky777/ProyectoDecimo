angular.module('WissenSystem')

.controller('SeguroEliminExamCtrl', ['$scope', '$uibModalInstance', 'examen', 'Restangular', 'toastr', '$state', ($scope, $modalInstance, examen, Restangular, toastr, $state)->

	$scope.examen = examen

	$scope.ok = ()->

		$scope.asignando = true

		if $scope.examen.rowid
			Restangular.all('examenes_respuesta/destroy').customPUT({examen_id: examen.examen_id}).then((r)->
				$modalInstance.close(r)
			, (r2)->
				toastr.warning 'No se pudo eliminar examen.', 'Problema'
			)
		else
			Restangular.all('examenes_respuesta/destroy/'+examen.examen_id).customDELETE().then((r)->
				$modalInstance.close(r)
			, (r2)->
				toastr.warning 'No se pudo eliminar examen.', 'Problema'
			)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

