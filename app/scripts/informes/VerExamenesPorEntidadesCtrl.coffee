'use strict'

angular.module('WissenSystem')


.controller('VerExamenesPorEntidadesCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'entidades',  
	($scope, Restangular, toastr, $filter, $uibModal, App, entidades) ->

		hay = localStorage.texto_informativo_informe
		if hay
			$scope.texto_informativo = hay
		else
			 $scope.texto_informativo = "<center>Los finalistas deben presentarse en <b>LA GRAN FINAL</b> el día jueves <b>28 de septiembre</b> a las <u>7:00am</u> en el Coliseo Municipal con <b>los pabellones</b>(escudos, heraldos) de su colegio y una <u>representación de compañeros</u> que lo apoyen en las pruebas. ¡Mucho éxito, gracias por participar! </center>"

		$scope.entidades = []

		$scope.cambia_texto_informativo = ()->
			localStorage.texto_informativo_informe = $scope.texto_informativo


		for entidad in entidades
			
			finalistas = []

			for categoria in entidad.categorias

				categoria.examenes = $filter('orderObjectBy')(categoria.examenes, 'promedio', true)
				el_mejor 	= {}
				angular.copy(categoria.examenes[0], el_mejor)
				el_mejor.nombre_categ 	= categoria.nombre_categ
				el_mejor.abrev_categ 	= categoria.abrev_categ

				if not el_mejor.resultados
					el_mejor.resultados = { promedio: 0 }

				finalistas.push(el_mejor)

			entidad.finalistas = finalistas

		$scope.entidades = entidades



	]
)




.controller('VerExamenesPorCategoriasCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'categorias',  
	($scope, Restangular, toastr, $filter, $uibModal, App, categorias) ->

		hay = localStorage.txt_informativo_por_categorias
		if hay
			$scope.texto_informativo = hay
		else
			 $scope.texto_informativo = "<center><b>La Unión Colombiana del Norte</b> les agradece grandemente por participar de estas olimpiadas. <b>SIGAMOS MEJORANDO</b>, todo esto es en pro de la educación Adventista. Oremos para que el próximo año sea aún mejor. ¡Dios los bendiga! </center>"

		$scope.cambia_texto_informativo = ()->
			localStorage.txt_informativo_por_categorias = $scope.texto_informativo


		finalistas = []

		for categoria in categorias

			categoria.examenes = $filter('orderObjectBy')(categoria.examenes, 'promedio', true)
			el_mejor 	= {}
			angular.copy(categoria.examenes[0], el_mejor)
			el_mejor.nombre_categ 	= categoria.nombre_categ
			el_mejor.abrev_categ 	= categoria.abrev_categ

			if not el_mejor.resultados
				el_mejor.resultados = { promedio: 0 }

			finalistas.push(el_mejor)


		$scope.finalistas = finalistas
		$scope.categorias = categorias




	]
)


