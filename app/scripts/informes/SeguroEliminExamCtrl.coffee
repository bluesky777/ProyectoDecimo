angular.module('WissenSystem')

.controller('SeguroEliminExamCtrl', ['$scope', '$uibModalInstance', 'examen', 'Restangular', 'toastr', '$state', ($scope, $modalInstance, examen, Restangular, toastr, $state)->

	$scope.examen = examen

	$scope.ok = ()->

		$scope.asignando = true

		
		Restangular.all('examenes_respuesta/destroy/'+examen.examen_id).customDELETE().then((r)->
			$modalInstance.close(r)
		, (r2)->
			toastr.warning 'No se pudo eliminar examen.', 'Problema'
			console.log 'Error eliminando el examen: ', r2
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

