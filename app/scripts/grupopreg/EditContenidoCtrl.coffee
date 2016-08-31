angular.module('WissenSystem')

.controller('EditContenidoCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr) ->

		$scope.idiomaPreg = [$scope.contenidoEdit.idioma_id]


		$scope.editorOptions = 
			inlineMode: true
			placeholder: ''


		$scope.cerrarEdicion = ()->
			$scope.$parent.editandoContenido = false
			$scope.contenidoEdit = {}



		$scope.finalizarEdicion = ()->
			Restangular.one('contenido_traduc/update').customPUT($scope.contenidoEdit).then((r)->
				$scope.$parent.editandoContenido = false
				$scope.contenidoEdit = {}
				toastr.success 'Cambios guardados con éxito'
			, (r2)->
				console.log('No se pudo guardar los cambios', r2)
				toastr.warning 'Cambios NO guardados', 'Problema'
			)


		$scope.aplicarCambios = ()->
			Restangular.one('contenido_traduc/update').customPUT($scope.contenidoEdit).then((r)->
				toastr.success 'Cambios guardados'
			, (r2)->
				console.log('No se pudo guardar los cambios', r2)
				toastr.warning 'Cambios NO guardados', 'Problema'
			)

		Restangular.all('grupo_preguntas/traducidos').getList({ grupo_id: $scope.contenidoEdit.pg_id }).then((r)->
			for trad in r
				if r.pg_traduc_id = $scope.contenidoEdit.pg_traduc_id
					r.enunciado 	= $scope.contenidoEdit.enunciado

			$scope.contenidoEdit.contenidos_traducidos = r

		, (r2)->
			console.log('No se trajeron las traducciones de la pregunta', r2)
			toastr.warning 'No se trajeron las traducciones de la pregunta', 'Problema'
		)
		


		return
	]
)





