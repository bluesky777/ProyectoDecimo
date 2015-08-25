angular.module('WissenSystem')

.controller('EventosCtrl', ['$scope', 'Restangular',  ($scope, Restangular)->

	$scope.newEvent = {
		with_pay: false
	}

	
	$scope.creando = false
	$scope.editando = false

	$scope.guardando_nuevo = false
	$scope.guardando_edit = false


	$scope.guardar_evento = ()->

		$scope.guardando_nuevo = true

		Restangular.one('eventos/store').customPOST($scope.newEvent).then((r)->
			console.log('Evento guardado', r)
			$scope.creando = false
			$scope.guardando_nuevo = false
			$scope.eventos.push r
		, (r2)->
			console.log('No se pudo guardar el evento', r2)
			$scope.guardando_nuevo = false
		)


	$scope.update_evento = ()->

		$scope.guardando_edit = true

		Restangular.one('eventos/update').customPUT($scope.currentEvent).then((r)->
			console.log 'Evento editado', r
			$scope.guardando_edit = false
		(r2)->
			console.log 'El Evento no se pudo editar', r2
			$scope.guardando_edit = false
		)

	$scope.crear_evento = ()->
		$scope.creando = true

	$scope.cancelar_newevento = ()->
		$scope.creando = false
			
	$scope.cancelar_currentEvento = ()->
		$scope.editando = false
			

	$scope.editarEvento = (evento)->
		$scope.editando = true
		$scope.currentEvent = evento
	

	$scope.eliminarEvento = (evento)->
		Restangular.one('eventos/destroy').customDELETE(evento.id).then((r)->
			console.log 'Evento eliminado', r
		(r2)->
			console.log 'El Evento no se pudo eliminar', r2
		)


])