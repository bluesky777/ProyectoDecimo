angular.module("WissenSystem")

.controller('RemoveImageCtrl', ['$scope', '$uibModalInstance', 'imagen', 'App', 'Restangular', 'AuthService', 'toastr', ($scope, $modalInstance, imagen, App, Restangular, AuthService, toastr)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.imagen = imagen
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.ok = ()->

		img_id = if imagen.rowid then imagen.rowid else imagen.id

		if imagen.rowid

			Restangular.one('imagenes/destroy').customPUT({img_id: img_id}).then((r)->
				toastr.success 'La imagen ha sido removida.'
				$modalInstance.close(imagen)
			, (r2)->
				toastr.error 'No se pudo eliminar la imagen.'
			)

		else
			Restangular.one('imagenes/destroy/'+imagen.id).customDELETE().then((r)->
				toastr.success 'La imagen ha sido removida.'
				$modalInstance.close(imagen)
			, (r2)->
				toastr.error 'No se pudo eliminar la imagen.'
			)



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	return
])
