angular.module('WissenSystem')

.controller('ViewGrupoCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', '$location', '$anchorScroll', 'toastr', '$uibModal', '$filter',
	($scope, App, Restangular, $state, $cookies, $rootScope, $location, $anchorScroll, toastr, $modal, $filter) ->
		
		$scope.creandoGrupoPreg = false

		$scope.addNewPregunta = (pg_pregunta)->

			$scope.creandoGrupoPreg = true

			Restangular.one('preguntas_agrupadas/store').customPOST({contenido_id: pg_pregunta.pg_traduc_id}).then((r)->
				r.editando = true
				$scope.creandoGrupoPreg = false
				pg_pregunta.pregs_agrupadas.push r
			(r2)->
				console.log 'Rechazada la nueva ', r2
				$scope.creandoGrupoPreg = false
				toastr.warning 'No se creó pregunta', 'Problema'
			)

		$scope.asignarAEvaluacion = (grupoking)->
			modalInstance = $modal.open({
				templateUrl: App.views + 'grupopreg/asignarGrupo.tpl.html'
				controller: 'AsignarGrupoCtrl'
				resolve: 
					pregunta: ()->
						grupoking
					evaluaciones: ()->
						$scope.evaluaciones
			})
			modalInstance.result.then( (elem)->
				console.log 'Resultado del modal: ', elem
			)


		
		$scope.toggleMostrarAyuda = (pregunta)->
			pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda


		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)

		$scope.editarGrupo = (grupoking)->
			$scope.$parent.$parent.contenidoEdit 		= grupoking
			$scope.$parent.$parent.editandoContenido 	= true
			$location.hash('content');
			$anchorScroll();


		$scope.eliminarContenido = (grupoking)->

			modalInstance = $modal.open({
				templateUrl: App.views + 'grupopreg/removeGrupo.tpl.html'
				controller: 'RemoveGrupoCtrl'
				resolve: 
					grupoking: ()->
						grupoking
			})
			modalInstance.result.then( (elem)->
				$scope.$emit 'grupoEliminado', elem
				console.log 'Resultado del modal: ', elem
			)


		$scope.editarPreguntaAgrup = (grupoking)->
			grupoking.editando = true



		$scope.eliminarPreguntaAgrup = (preg_agrup, contenido)->

			modalInstance = $modal.open({
				templateUrl: App.views + 'grupopreg/removePreguntaAgrup.tpl.html'
				controller: 'RemovePreguntaAgrupCtrl'
				resolve: 
					preg_agrup: ()->
						preg_agrup
			})
			modalInstance.result.then( (elem)->
				$scope.$emit 'pregAgrupEliminada', elem
				console.log 'Resultado del modal: ', preg_agrup.id, $filter('filter')(contenido.pregs_agrupadas, {id: '!' + preg_agrup.id}, true)
				contenido.pregs_agrupadas = $filter('filter')(contenido.pregs_agrupadas, {id: '!' + preg_agrup.id}, true)
			)


		$scope.previewPreguntaAgrup = (preg_agrup)->

			preg_agrup.showDetail = !preg_agrup.showDetail



	]
)



.controller('RemoveGrupoCtrl', ['$scope', '$uibModalInstance', 'grupoking', 'Restangular', 'toastr', ($scope, $modalInstance, grupoking, Restangular, toastr)->
	$scope.grupoking = grupoking

	$scope.ok = ()->

		Restangular.all('grupo_preguntas/destroy/'+grupoking.pg_id).remove().then((r)->
			toastr.success 'Pregunta eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la grupoking.', 'Problema'
			console.log 'Error eliminando grupoking: ', r2
		)
		$modalInstance.close(grupoking)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



.controller('RemovePreguntaAgrupCtrl', ['$scope', '$uibModalInstance', 'preg_agrup', 'Restangular', 'toastr', ($scope, $modalInstance, preg_agrup, Restangular, toastr)->
	$scope.preg_agrup = preg_agrup

	$scope.ok = ()->

		Restangular.all('preguntas_agrupadas/destroy/'+preg_agrup.id).remove().then((r)->
			toastr.success 'Pregunta eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la preg_agrup.', 'Problema'
			console.log 'Error eliminando preg_agrup: ', r2
		)
		$modalInstance.close(preg_agrup)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('AsignarGrupoCtrl', ['$scope', '$uibModalInstance', 'pregunta', 'evaluaciones', 'Restangular', 'toastr', '$filter', ($scope, $modalInstance, pregunta, evaluaciones, Restangular, toastr, $filter)->
	$scope.pregunta = pregunta
	$scope.evaluaciones = evaluaciones
	$scope.asignando = false
	$scope.selected = false

	$scope.ok = ()->

		$scope.asignando = true

		datos = 
			grupo_pregs_id: pregunta.id
			evaluacion_id: $scope.selected

		Restangular.all('pregunta_evaluacion/asignar-grupo').customPUT(datos).then((r)->
			toastr.success 'Grupo asignado con éxito.'
			$scope.asignando = false

			evalua = $filter('filter')(evaluaciones, {id: $scope.selected})[0]
			evalua.preguntas_evaluacion.push r

			$modalInstance.close(r)
		, (r2)->
			toastr.warning 'No se pudo asignar el grupo.', 'Problema'
			console.log 'Error asignando el grupo: ', r2
			$scope.asignando = false
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])






