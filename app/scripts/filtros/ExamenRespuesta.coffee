angular.module('WissenSystem')

.filter('cantPregsEvaluacion', ['$filter', 'Perfil', ($filter, Perfil)->
	(input) ->

		if input
			
			indice = 0

			for pregunta in input

				if pregunta.tipo_pregunta
					indice++

				else
					pregs_cont = $filter('porIdioma')(pregunta.contenidos_traducidos, Perfil.idioma())

					if pregs_cont.length > 0
						indice = indice + pregs_cont[0].preguntas_agrupadas.length


			return indice
		else
			return false
])


.filter('noPregActual', ['$filter', 'Perfil', ($filter, Perfil)->
	(input) ->

		if input
			
			indice = 0 # Empezamos desde la primera pregunta

			for pregunta in input

				indice++
				
				if pregunta.tipo_pregunta

					pregs_trad = $filter('porIdioma')(pregunta.preguntas_traducidas, Perfil.idioma())

					respondida = false

					for preg_trad in pregs_trad

						for opcion in preg_trad.opciones

							if opcion.respondida

								respondida = true


					if not respondida
						return indice

				else
					pregs_cont = $filter('porIdioma')(pregunta.contenidos_traducidos, Perfil.idioma())


					for preg_cont in pregs_cont

						indice++

						for preg_trad in preg_cont.preguntas_agrupadas

							respondida = false

							for opcion in preg_trad.opciones

								if opcion.respondida

									respondida = true


							if not respondida
								return indice
				

			return indice
		else
			return false
])




.filter('preguntaActual', ['$filter', 'Perfil', ($filter, Perfil)->
	(input, indice_actual) ->
		filtered = [];
		angular.forEach(input, (item)->
			filtered.push(item);
		)

		filtered = $filter('orderBy')(filtered, 'orden')

		if filtered

			if indice_actual
				return [filtered[indice_actual-1]]


			
			for pregunta in filtered

				if pregunta.tipo_pregunta

					pregs_trad = $filter('porIdioma')(pregunta.preguntas_traducidas, Perfil.idioma())

					respondida = false

					for preg_trad in pregs_trad

						for opcion in preg_trad.opciones

							if opcion.respondida

								respondida = true


					if not respondida
						return [pregunta] # Debe ser un array, no objeto

				else
					pregs_cont = $filter('porIdioma')(pregunta.contenidos_traducidos, Perfil.idioma())


					for preg_cont in pregs_cont

						for preg_trad in preg_cont.preguntas_agrupadas

							respondida = false

							for opcion in preg_trad.opciones

								if opcion.respondida

									respondida = true


							if not respondida
								return [pregunta] # Debe ser un array, no objeto
				


			res = filtered[0]
			if res
				res.terminado = true
				res = [res]
			
			return res
		else
			return false
])



