angular.module('WissenSystem')

.controller('CategoriasDirCtrl', ['$scope', 'Restangular', 'toastr', '$uibModal', 'App', '$filter',  ($scope, Restangular, toastr, $modal, App, $filter)->



	$scope.creando = false




	$scope.traer_categorias = ()->
		Restangular.all('categorias/categorias-usuario').getList().then((r)->

			for categ in r
				categ.idiomasEdit = [$scope.eventoactual.idioma_principal_id]

			$scope.categoriasking = r

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
			r.editando    = true
			r.idiomasEdit = [$scope.eventoactual.idioma_principal_id]
			$scope.categoriasking.push r
			$scope.creando = false
		, (r2)->
			toastr.warning 'No se creó la categoria', 'Problema'
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
			elem_id = if elem.rowid then elem.rowid else elem.id
			dato = {}

			if elem.rowid
				dato.rowid = '!'+elem_id
			else
				dato.id = '!'+elem_id

			$scope.categoriasking = $filter('filter')($scope.categoriasking, dato)

		)


	$scope.finalizar_edicion = (categoriaking)->
		$scope.guardando(categoriaking)
		categoriaking.editando = false

	$scope.guardando = (categoriaking)->
		Restangular.all('categorias/guardar').customPUT(categoriaking).then((r)->
			toastr.success 'Categoria guardada.'
		, (r2)->
			toastr.warning 'No se pudo guardar la categoria', 'Problema'
			console.log 'No se pudo guardar la categoria ', r2
		)


])



.controller('RemoveCategoriaCtrl', ['$scope', '$uibModalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento
	console.log 'elemento', elemento

	$scope.ok = ()->
		ele_id  = if elemento.rowid then elemento.rowid else elemento.id
		prome   = {};

		if elemento.rowid
			prome = Restangular.all('categorias/destroy').customPUT({rowid: ele_id})
		else
			prome = Restangular.all('categorias/destroy').customDELETE(ele_id)

		prome.then((r)->
			toastr.success 'Categoria eliminada con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			$modalInstance.dismiss('Error')
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




