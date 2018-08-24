angular.module('WissenSystem')

.controller('DisciplinasCtrl', ['$scope', 'Restangular', 'toastr', '$uibModal', 'App', '$filter',  ($scope, Restangular, toastr, $modal, App, $filter)->


	$scope.creando = false




	$scope.traer_disciplinas = ()->
		Restangular.all('disciplinas/disciplinas-usuario').getList().then((r)->

			for disc in r
				disc.idiomasEdit = [$scope.eventoactual.idioma_principal_id]

			$scope.disciplinasking = r

		, (r2)->
			toastr.warning 'No se trajeron las disciplinas', 'Problema'
			console.log 'No se trajo disciplinas ', r2
		)
	$scope.traer_disciplinas()

	$scope.$on 'cambio_evento_user', ()->
		$scope.traer_disciplinas()



	$scope.crear_disciplina = ()->
		$scope.creando = true

		Restangular.one('disciplinas/store').customPOST().then((r)->
			r.editando    = true
			r.idiomasEdit = [$scope.eventoactual.idioma_principal_id]
			$scope.disciplinasking.push r
			$scope.creando = false
		, (r2)->
			toastr.warning 'No se creó la disciplina', 'Problema'
			$scope.creando = false
		)


	$scope.cerrar_edicion = (disciplinaking)->
		disciplinaking.editando = false


	$scope.editarDisciplina = (disciplinaking)->
		disciplinaking.editando = true


	$scope.eliminarDisciplina = (disciplinaking)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'categorias/removeDisciplina.tpl.html'
			controller: 'RemoveDisciplinaCtrl'
			resolve:
				elemento: ()->
					disciplinaking
		})
		modalInstance.result.then( (elem)->
			dato = {}
			if elem.rowid
				dato.rowid = elem.rowid
			else
				dato.id = elem.id

			$scope.disciplinasking = $filter('filter')($scope.disciplinasking, dato, (actual, expected)=> return (actual != expected))

		)


	$scope.finalizar_edicion = (disciplinaking)->
		$scope.guardando(disciplinaking)
		disciplinaking.editando = false

	$scope.guardando = (disciplinaking)->
		Restangular.all('disciplinas/guardar').customPUT(disciplinaking).then((r)->
			toastr.success 'Disciplina guardada.'
			console.log 'Disciplina guardada: ', r
		, (r2)->
			toastr.warning 'No se pudo guardar la disciplina', 'Problema'
			console.log 'No se pudo guardar la disciplina ', r2
		)


])



.controller('RemoveDisciplinaCtrl', ['$scope', '$uibModalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento
	console.log 'elemento', elemento

	$scope.ok = ()->
		ele_id  = if elemento.rowid then elemento.rowid else elemento.id
		prome   = {};

		if elemento.rowid
			prome = Restangular.all('disciplinas/destroy').customPUT({rowid: ele_id})
		else
			prome = Restangular.all('disciplinas/destroy').customDELETE(ele_id)

		prome.then((r)->
			toastr.success 'Disciplina eliminada con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			$modalInstance.dismiss('Error')
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





