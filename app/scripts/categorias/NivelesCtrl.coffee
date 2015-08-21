angular.module('WissenSystem')

.controller('NivelesCtrl', ['$scope', 'Restangular',  ($scope, Restangular)->

	$scope.idiomasDiscEdit = [$scope.idiomaPreg]


	$scope.niveles_king = [
		{
			id: 1
			nombre: 'Niños'
			niveles_traducidos: [
				{
					nombre: 'Niños'
					idioma_id: 1
					idioma: 'Español'
					nivel_id: 1
					descripcion: 'Para menores'
					traducido: false
				},
				{
					nombre: 'Children'
					idioma_id: 2
					idioma: 'English'
					nivel_id: 1
					descripcion: 'For children'
					traducido: true
				}
			]
		},
		{
			id: 2
			nombre: 'Adultos'
			niveles_traducidos: [
				{
					nombre: 'Adultos'
					idioma_id: 1
					idioma: 'Español'
					nivel_id: 2
					descripcion: 'Para hombres mayores'
					traducido: false
				},
				{
					nombre: 'Adults'
					idioma_id: 2
					idioma: 'English'
					nivel_id: 2
					descripcion: 'For greater men'
					traducido: true
				}
			]
		}
	]


	$scope.editarNivel = (nivel)->
		nivel.editando = true

	$scope.eliminarNivel = (nivel)->
		#nivel.editando = true

	$scope.finalizar_edicion = (nivel)->
		nivel.editando = false



])

