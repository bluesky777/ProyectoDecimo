angular.module('WissenSystem')

.filter('porIdioma', [ ->
	(input, idioma) ->

		if input
			
			resultado = []

			idioma = parseFloat(idioma)

			for elemento in input

				idioma_id = parseFloat(elemento.idioma_id)
				
				if idioma == idioma_id
					resultado.push elemento

			return resultado
		else
			return false
])



.filter('idiomas_del_sistema', [ ->
	(input, no_usuados) ->

		# Si no_usuados es false, mostramos solo los usados por el sistema

		if input
			
			resultado = []

			for elemento in input
				if no_usuados
					if !elemento.used_by_system
						resultado.push elemento

				else
					if elemento.used_by_system
						resultado.push elemento

			return resultado
		else
			return false
])


.filter('porIdiomasEdit', [ ->
	(input, idiomas) ->

		if input
			if input.length > 0
				if input[0].uncodigo_id
					console.log input, idiomas
		
		resultado = []
		
		if idiomas and input

			for idioma in idiomas

				idioma = parseFloat(idioma)
		
				for elemento in input

					idioma_id = parseFloat(elemento.idioma_id)
					
					if idioma == idioma_id
						resultado.push elemento

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






