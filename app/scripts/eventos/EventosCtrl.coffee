angular.module('WissenSystem')

.controller('EventosCtrl', ['$scope', 'Restangular',  ($scope, Restangular)->

	$scope.newEvent = {
		with_pay: false
	}

	
	$scope.creando = false
	$scope.editando = false

	$scope.guardar_evento = ()->

		Restangular.one('eventos/store').customPOST($scope.newEvent).then((r)->
			console.log('Evento guardado', r)
		, (r2)->
			console.log('No se pudo guardar el evento', r2)
		)

	$scope.update_evento = ()->

		Restangular.one('eventos/update').customPUT($scope.currentEvento).then((r)->
			console.log 'Evento editado', r
		(r2)->
			console.log 'El Evento no se pudo editar', r2
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
		Restangular.one('eventos/delete').customDELETE(evento.id).then((r)->
			console.log 'Evento eliminado', r
		(r2)->
			console.log 'El Evento no se pudo eliminar', r2
		)


])