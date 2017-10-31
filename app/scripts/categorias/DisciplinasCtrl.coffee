angular.module('WissenSystem')

.controller('DisciplinasCtrl', ['$scope', 'Restangular', 'toastr', '$uibModal', 'App', '$filter',  ($scope, Restangular, toastr, $modal, App, $filter)->


	$scope.creando = false


	

	$scope.traer_disciplinas = ()->
		Restangular.all('disciplinas/disciplinas-usuario').getList().then((r)->
			$scope.disciplinasking = r
			#console.log 'Disciplinas traídas: ', r
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
			r.editando = true
			$scope.disciplinasking.push r
			$scope.creando = false
			console.log 'Disciplina creada', r
		, (r2)->
			toastr.warning 'No se creó la disciplina', 'Problema'
			console.log 'No se creó disciplina ', r2
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
			$scope.disciplinasking = $filter('filter')($scope.disciplinasking, {id: '!'+elem.id})
			console.log 'Resultado del modal: ', elem
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

		Restangular.all('disciplinas/destroy').customDELETE(elemento.id).then((r)->
			toastr.success 'Disciplina eliminada con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
			$modalInstance.dismiss('Error')
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





