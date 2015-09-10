angular.module('WissenSystem')

.controller('ViewGrupoCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', '$modal', '$filter',
	($scope, App, Restangular, $state, $cookies, $rootScope, toastr, $modal, $filter) ->
		"""
		$scope.idiomaactualselec = parseInt($scope.idiomaactualselec)
		$scope.idiomaPreg = $scope.idiomaactualselec
		"""

		$scope.creando = false

		$scope.addNewPregunta = (contenido)->

			$scope.creando = true

			Restangular.one('preguntas_agrupadas/store').customPOST({contenido_id: contenido.id}).then((r)->
				r.editando = true
				$scope.creando = false
				contenido.preguntas_agrupadas.push r
				console.log 'Pregunta añadida: ', contenido

			(r2)->
				console.log 'Rechazada la nueva ', r2
				$scope.creando = false
				toastr.warning 'No se creó pregunta', 'Problema'
			)

		
		$scope.toggleMostrarAyuda = (pregunta)->
			pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda


		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)

		$scope.editarGrupo = (grupoking)->
			grupoking.editando = true


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
				console.log 'Resultado del modal: ', preg_agrup.id, $filter('filter')(contenido.preguntas_agrupadas, {id: '!' + preg_agrup.id})
				contenido.preguntas_agrupadas = $filter('filter')(contenido.preguntas_agrupadas, {id: '!' + preg_agrup.id})
			)


		$scope.previewPreguntaAgrup = (preg_agrup)->

			preg_agrup.showDetail = !preg_agrup.showDetail



	]
)



.controller('RemoveGrupoCtrl', ['$scope', '$modalInstance', 'grupoking', 'Restangular', 'toastr', ($scope, $modalInstance, grupoking, Restangular, toastr)->
	$scope.grupoking = grupoking

	$scope.ok = ()->

		Restangular.all('grupo_preguntas/destroy/'+grupoking.id).remove().then((r)->
			toastr.success 'Pregunta eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la grupoking.', 'Problema'
			console.log 'Error eliminando grupoking: ', r2
		)
		$modalInstance.close(grupoking)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



.controller('RemovePreguntaAgrupCtrl', ['$scope', '$modalInstance', 'preg_agrup', 'Restangular', 'toastr', ($scope, $modalInstance, preg_agrup, Restangular, toastr)->
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





