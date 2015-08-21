angular.module('WissenSystem')

.controller('CategoriasDirCtrl', ['$scope', 'Restangular',  ($scope, Restangular)->

	$scope.idiomasDiscEdit = [$scope.idiomaPreg]


	$scope.categorias_king = [
		{	
			id: 1
			nombre: 'MtNi'
			nivel_id: 1
			disciplina_id: 1
			evento_id: 1
			categorias_traducidas: [
				{
					id: 1
					nombre: 'Matemáticas Niños'
					abrev: 'MaNi'
					categoria_id: 1
					descripcion: ''
					idioma_id: 1
				},
				{
					id: 2
					nombre: 'Mathematics Children'
					abrev: 'MathCh'
					categoria_id: 1
					descripcion: ''
					idioma_id: 2
				}
			]
		},
		{	
			id: 2
			nombre: 'MtAd'
			nivel_id: 2
			disciplina_id: 1
			evento_id: 1
			categorias_traducidas: [
				{
					id: 3
					nombre: 'Matemáticas Adultos'
					abrev: 'MatAd'
					categoria_id: 2
					descripcion: ''
					idioma_id: 1
				},
				{
					id: 4
					nombre: 'Mathematics Adults'
					abrev: 'MathAd'
					categoria_id: 2
					descripcion: ''
					idioma_id: 2
				}
			]
		}
	]


	$scope.disciplinas_king = [
		{
			id: 1
			nombre: 'Matemáticas'
			disciplinas_traducidas: [
				{
					nombre: 'Matemáticas'
					idioma_id: 1
					idioma: 'Español'
					disciplina_id: 1
					descripcion: 'Matemáticas'
					traducido: false
				},
				{
					nombre: 'Math'
					idioma_id: 2
					idioma: 'English'
					disciplina_id: 1
					descripcion: 'Math'
					traducido: true
				}
			]
		},
		{
			id: 2
			nombre: 'Sociales'
			disciplinas_traducidas: [
				{
					nombre: 'Sociales'
					idioma_id: 1
					idioma: 'Español'
					disciplina_id: 2
					descripcion: 'Sociales'
					traducido: false
				},
				{
					nombre: 'Geografy'
					idioma_id: 2
					idioma: 'English'
					disciplina_id: 2
					descripcion: 'Geografy'
					traducido: true
				}
			]
		}
	]


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



	$scope.editarCategoria = (categoria)->
		categoria.editando = true

	$scope.eliminarCategoria = (categoria)->
		#categoria.editando = true

	$scope.finalizar_edicion = (categoria)->
		categoria.editando = false



])

