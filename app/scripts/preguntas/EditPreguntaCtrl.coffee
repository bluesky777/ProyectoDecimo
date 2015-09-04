angular.module('WissenSystem')

.controller('EditPreguntaCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr) ->

		$scope.eventoactualselec = parseInt($scope.eventoactualselec)
		
		$scope.idiomaPreg = [$scope.eventoactualselec]


		$scope.editorOptions = 
			inlineMode: true
			placeholder: ''


		$scope.mostrarConfiguracion = false
		$scope.mostrarConfig = ()->
			$scope.mostrarConfiguracion = !$scope.mostrarConfiguracion
			

		$scope.cerrarEdicion = ()->
			$scope.preguntaking.editando = false


		$scope.finalizarEdicion = ()->
			$scope.$emit 'finalizaEdicionPreg'
			

			Restangular.one('preguntas/update/1').customPUT($scope.preguntaking).then((r)->
				console.log('Cambios guardados', r)
				$scope.preguntaking.editando = false
				toastr.success 'Cambios guardados con éxito'
			, (r2)->
				console.log('No se pudo guardar los cambios', r2)
				toastr.warning 'Cambios NO guardados', 'Problema'
			)
			console.log 'Guardando cambios...'


		$scope.aplicarCambios = ()->
			Restangular.one('preguntas/update/1').customPUT($scope.preguntaking).then((r)->
				console.log('Cambios guardados', r)
				toastr.success 'Cambios guardados con éxito'
			, (r2)->
				console.log('No se pudo guardar los cambios', r2)
				toastr.warning 'Cambios NO guardados', 'Problema'

			)
			console.log 'Guardando cambios...'

		

			

		return
	]
)





