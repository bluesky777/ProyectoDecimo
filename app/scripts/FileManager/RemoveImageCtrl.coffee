angular.module("WissenSystem")

.controller('RemoveImageCtrl', ['$scope', '$uibModalInstance', 'imagen', 'App', 'Restangular', 'AuthService', 'toastr', ($scope, $modalInstance, imagen, App, Restangular, AuthService, toastr)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.imagen = imagen
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.ok = ()->

		Restangular.one('imagenes/destroy/'+imagen.id).customDELETE().then((r)->
			toastr.success 'La imagen ha sido removida.'
		, (r2)->
			toastr.error 'No se pudo eliminar la imagen.'
		)
		$modalInstance.close(imagen)



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	return
])