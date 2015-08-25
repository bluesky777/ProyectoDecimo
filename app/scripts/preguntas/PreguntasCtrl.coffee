'use strict'

angular.module('WissenSystem')

.controller('PreguntasCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', 'preguntasServ', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, preguntasServ) ->


		$scope.idiomaPreg = 1
		$scope.showDetail = false
		$scope.categoria = 1

		$scope.preguntas_king = []

		$scope.getPreguntasKing = ()->
			preguntasServ.getPreguntas().then((r)->
				$scope.preguntas_king = r
			, (r2)->
				console.log 'Pailas la promesa de las preguntas ', r2
			)
			

		$scope.getPreguntasKing()




		$scope.$on 'finalizaEdicionPreg', (elem)->
			console.log 'elem', elem


		$scope.idiomas = [
			{	
				id: 1
				nombre: 'Español'
				abrev: 'ES'
				original: 'Español'
				is_main: true
			},
			{	
				id: 2
				nombre: 'Inglés'
				abrev: 'EN'
				original: 'English'
				is_main: false
			}
		]

		$scope.categorias = [
			{	
				id: 1
				nombre: 'MtA'
				nivel_id: 1
				disciplina_id: 1
				evento_id: 1
				categorias_traducidas: [
					{
						id: 1
						nombre: 'Matemáticas A'
						abrev: 'MatA'
						categoria_id: 1
						descripcion: ''
						idioma_id: 1
					},
					{
						id: 2
						nombre: 'Mathematics A'
						abrev: 'MathA'
						categoria_id: 1
						descripcion: ''
						idioma_id: 2
					}
				]
			},
			{	
				id: 2
				nombre: 'MtB'
				nivel_id: 2
				disciplina_id: 1
				evento_id: 1
				categorias_traducidas: [
					{
						id: 3
						nombre: 'Matemáticas B'
						abrev: 'MatB'
						categoria_id: 2
						descripcion: ''
						idioma_id: 1
					},
					{
						id: 4
						nombre: 'Mathematics B'
						abrev: 'MathB'
						categoria_id: 2
						descripcion: ''
						idioma_id: 2
					}
				]
			}
		]
	]
)



.filter('pregsByCats', [ ->
	(input, categoria) ->
		
		resultado = []

		for preg in input
	
			if preg.categoria_id == parseFloat(categoria)
				resultado.push preg

		return resultado
])




.filter('catsByIdioma', [ ->
	(input, idioma) ->
		
		resultado = []

		for cat in input
	
			if cat.idioma_id == parseFloat(idioma)
				resultado.push cat

		return resultado
])






