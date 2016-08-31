angular.module('WissenSystem')

.controller('EditPreguntaCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr) ->

		$scope.idiomaPreg = [$scope.$parent.preguntaEdit.idioma_id]

		$scope.editorOptions = 
			inlineMode: true
			placeholder: ''



		$scope.mostrarConfiguracion = true
		$scope.mostrarConfig = ()->
			$scope.mostrarConfiguracion = !$scope.mostrarConfiguracion
			

		$scope.cerrarEdicion = ()->
			$scope.$parent.editando = false


		$scope.finalizarEdicion = ()->

			Restangular.one('preguntas/update').customPUT($scope.preguntaEdit).then((r)->
				$scope.$parent.editando = false
				toastr.success 'Cambios guardados con éxito'
			, (r2)->
				console.log('No se pudo guardar los cambios', r2)
				toastr.warning 'Cambios NO guardados', 'Problema'
			)


		$scope.aplicarCambios = ()->
			Restangular.one('preguntas/update').customPUT($scope.preguntaEdit).then((r)->
				toastr.success 'Cambios guardados con éxito'
			, (r2)->
				console.log('No se pudo guardar los cambios', r2)
				toastr.warning 'Cambios NO guardados', 'Problema'

			)


		$scope.cambiaTipoPregunta = ()->
			console.log 'Cambia el tipo: ', $scope.preguntaEdit.tipo_pregunta
			$scope.$broadcast 'cambiaTipoPregunta'
			
		
		Restangular.all('preguntas/traducidas').getList({ pregunta_id: $scope.preguntaEdit.pg_id }).then((r)->
			for trad in r
				if r.pg_traduc_id = $scope.preguntaEdit.pg_traduc_id
					r.opciones 		= $scope.preguntaEdit.opciones
					r.enunciado 	= $scope.preguntaEdit.enunciado

			$scope.preguntaEdit.preguntas_traducidas = r

		, (r2)->
			console.log('No se trajeron las traducciones de la pregunta', r2)
			toastr.warning 'No se trajeron las traducciones de la pregunta', 'Problema'

		)
		

		return
	]
)





