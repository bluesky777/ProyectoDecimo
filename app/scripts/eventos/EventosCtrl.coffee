angular.module('WissenSystem')

.controller('EventosCtrl', ['$scope', 'Restangular', '$modal', '$filter', 'App', 'toastr',  ($scope, Restangular, $modal, $filter, App, toastr)->

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
			$scope.eventos.push r
			$scope.guardando_nuevo = false
			toastr.success 'Evento guardado con éxito.', 'Creado'
		, (r2)->
			console.log('No se pudo guardar el evento', r2)
			toastr.warning 'No se pudo crear evento.', 'Problema'
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
	
	

	$scope.quitandoIdiomas = (item, model)->
		Restangular.one('idiomas/destroy').customDELETE(item.id).then((r)->
			toastr.success 'Idioma quitado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar idioma.', 'Problema'
			console.log 'Error eliminando idioma: ', r2
		)
	

	$scope.idiomasSelect = (item, model)->
		
		datos = 
			evento_id: $scope.currentEvent.id
			idioma_id: item.id

		Restangular.one('idiomas/store').customPOST(datos).then((r)->
			toastr.success 'Idioma agregado con éxito.', 'Añadido'
		, (r2)->
			toastr.warning 'No se pudo agregar idioma.', 'Problema'
			console.log 'Error agregando idioma: ', r2
		)
	

	$scope.eliminarEvento = (evento)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'eventos/removeEvento.tpl.html'
			controller: 'RemoveEventoCtrl'
			resolve: 
				elemento: ()->
					evento
		})
		modalInstance.result.then( (elem)->
			$scope.eventos = $filter('filter')($scope.eventos, {id: '!'+elem.id})
			console.log 'Resultado del modal: ', elem
		)


	# Actualizo los eventos con la función del controlador ApplicationController
	$scope.traerEventos()

])

.controller('RemoveEventoCtrl', ['$scope', '$modalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento

	$scope.ok = ()->

		Restangular.all('eventos/destroy').customDELETE(elemento.id).then((r)->
			toastr.success 'Evento eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
		)
		$modalInstance.close(elemento)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


