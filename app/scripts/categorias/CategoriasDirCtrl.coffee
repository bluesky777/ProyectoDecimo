angular.module('WissenSystem')

.controller('CategoriasDirCtrl', ['$scope', 'Restangular', 'toastr', '$modal', 'App', '$filter',  ($scope, Restangular, toastr, $modal, App, $filter)->



	$scope.creando = false


	$scope.categorias_king = []

	$scope.traer_categorias = ()->
		Restangular.all('categorias/categorias-usuario').getList().then((r)->
			$scope.categorias_king = r
			#console.log 'Categorias traídas: ', r
		, (r2)->
			toastr.warning 'No se trajeron las categorias', 'Problema'
			console.log 'No se trajo categorias ', r2
		)
	$scope.traer_categorias()

	$scope.$on 'cambio_evento_user', ()->
		$scope.traer_categorias()



	$scope.crear_categoria = ()->
		$scope.creando = true

		Restangular.one('categorias/store').customPOST().then((r)->
			r.editando = true
			$scope.categorias_king.push r
			$scope.creando = false
			console.log 'Categorias creada', r
		, (r2)->
			toastr.warning 'No se creó la categoria', 'Problema'
			console.log 'No se creó categoria ', r2
			$scope.creando = false
		)


	$scope.cerrar_edicion = (categoriaking)->
		categoriaking.editando = false
			

	$scope.editarCategoria = (categoriaking)->
		categoriaking.editando = true


	$scope.eliminarCategoria = (categoriaking)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'categorias/removeCategoria.tpl.html'
			controller: 'RemoveCategoriaCtrl'
			resolve: 
				elemento: ()->
					categoriaking
		})
		modalInstance.result.then( (elem)->
			$scope.categorias_king = $filter('filter')($scope.categorias_king, {id: '!'+elem.id})
			console.log 'Resultado del modal: ', elem
		)


	$scope.finalizar_edicion = (categoriaking)->
		$scope.guardando(categoriaking)
		categoriaking.editando = false

	$scope.guardando = (categoriaking)->
		Restangular.all('categorias/guardar').customPUT(categoriaking).then((r)->
			toastr.success 'Categoria guardada.'
			console.log 'Categoria guardada: ', r
		, (r2)->
			toastr.warning 'No se pudo guardar la categoria', 'Problema'
			console.log 'No se pudo guardar la categoria ', r2
		)


])



.controller('RemoveCategoriaCtrl', ['$scope', '$modalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento
	console.log 'elemento', elemento

	$scope.ok = ()->

		Restangular.all('categorias/destroy').customDELETE(elemento.id).then((r)->
			toastr.success 'Categoria eliminada con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
			$modalInstance.dismiss('Error')
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




