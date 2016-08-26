angular.module('WissenSystem')

.controller('EditPregTraducDirCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', '$filter', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, $filter) ->


		txtNewOpcion = 'Agregar nueva opción'
			
		
		$scope.inicializar = ()->

			for opci in $scope.preguntatraduc.opciones
				if opci.nueva
					return

			newOpcion = 
				id: -1
				definicion: txtNewOpcion
				nueva: true
				is_correct: false
			
			$scope.preguntatraduc.opciones.push newOpcion

		$scope.inicializar()

		
		# Configuración para el sortable
		$scope.sortableOptions =
			'ui-floating': true

			update: (e, ui)->
				# console.log e, ui

				sortHash = []

				for opcion, index in $scope.preguntatraduc.opciones
					if opcion.id != -1
						hashEntry = {}
						hashEntry["" + opcion.id] = index
						sortHash.push(hashEntry)
				
				datos = 
					pregunta_traduc_id: $scope.preguntatraduc.id
					sortHash: sortHash
				
				Restangular.one('opciones/update-orden').customPUT(datos).then((r)->
					console.log('Orden guardado')
				, (r2)->
					console.log('No se pudo guardar el orden', r2)
					#ui.item.sortable.cancel() # Cancelamos el intento de ordenar
				)



		
		$scope.addButtonNewOpcion = (preg, opt)->

			opt.creando = true
			
			if opt.nueva

				opt.definicion = 'Opción ' + preg.opciones.length
				opt.preg_traduc_id = preg.id
				opt.orden = preg.opciones.length - 1

				if preg.opciones.length == 1
					opt.is_correct = true
			
				
				Restangular.one('opciones/store').customPOST(opt).then((r)->
					console.log('Opción guardada')
					
					opt.id = r.id
					opt.nueva = false
					opt.creando = false
					

					# Agregamos la nueva opción para que sea el botón NUEVA OPCIÓN
					tempOpcion = 
						id: -1
						definicion: txtNewOpcion
						nueva: true # Inicialmente es true para que sea una especie de botón, NUEVA OPCIÓN
						is_correct: false
					preg.opciones.push tempOpcion

				, (r2)->
					console.log('No se pudo guardar la opción', r2)
					opt.definicion = txtNewOpcion # Volvemos a poner el texto de tipo botón
					opt.creando = false
					toastr.warning('No se pudo crear nueva opción')
				)

				

		
		$scope.setAsCorrect = (preg, opt)->
			if $scope.preguntaking.tipo_pregunta == 'Test'
				angular.forEach preg.opciones, (opcion)->  # Solo puede haber una correcta, así que quitamos las otras.
					opcion.is_correct = 0

				opt.is_correct = 1


			if $scope.preguntaking.tipo_pregunta == 'Multiple'
				opt.is_correct = 1  # Pueden haber muchas correctas, así que simplemente la estrablecemos correcta sin importar si hay alguna otra como correcta.


		$scope.deleteOption = (preg, opt, indice)->
			
			
			Restangular.one('opciones/destroy', opt.id).customDELETE().then((r)->
				console.log('Opción eliminada', r)
				preg.opciones = $filter('filter')(preg.opciones, {id: "!" + opt.id})
			, (r2)->
				console.log('No se pudo eliminar la opción', r2)
				toastr.warning 'No se pudo eliminar la opción'
			)
			

			### Probando el mdToast
			toast = $mdToast.simple()
				.content('Opción eliminada!')
				.action('OK')
				.highlightAction(false)
				.position('top right');
			$mdToast.show(toast)
			###

			
		$scope.$on 'cambiaTipoPregunta', ()->

			if $scope.preguntaking.tipo_pregunta == 'Test'

				for preg_trad in $scope.preguntaking.preguntas_traducidas  
					correctas = 0
					for opcion in preg_trad.opciones  # Solo puede haber una correcta, así que quitamos todas menos una.
						
						if opcion.is_correct
							if correctas > 0
								opcion.is_correct = 0
							else
								correctas = correctas + 1
	]
)




