angular.module('WissenSystem')

.filter('nombreEntidad', ['$filter', ($filter)->
	(entidad_id, entidades, alias) ->

		if entidad_id and entidades
			
			entidad_id = parseFloat(entidad_id)

			entidad = $filter('filter')(entidades, {id: entidad_id})
			
			if entidad.length > 0
				if alias
					return entidad[0].alias
				else
					return entidad[0].nombre
			else
				return entidad_id

		else

			return entidad_id
])



.filter('nivelesTraducidos', ['$filter', ($filter)->
	(nivelesking, idioma_id) ->

		if nivelesking and idioma_id

			idioma_id = parseFloat(idioma_id)

			resultado = []

			for nivelking in nivelesking

				niv_traducido = $filter('porIdioma')(nivelking.niveles_traducidos, idioma_id)
				if niv_traducido.length > 0
					niv_traducido[0].nivel_king_id = nivelking.id
					resultado.push niv_traducido[0]

			return resultado

		else

			return nivelesking
])


.filter('categoriasTraducidas', ['$filter', ($filter)->
	(categoriasking, idioma_id, nivel_id) ->

		if categoriasking and idioma_id

			idioma_id = parseFloat(idioma_id)

			resultado = []

			for categ_king in categoriasking

				if nivel_id
					
					nivel_id = parseFloat(nivel_id)

					if categ_king.nivel_id == nivel_id

						categ_traducido = $filter('porIdioma')(categ_king.categorias_traducidas, idioma_id)
						if categ_traducido.length > 0
							categ_traducido[0].categoria_king_id = categ_king.id
							resultado.push categ_traducido[0]

				else
					if categ_king
						categ_traducido = $filter('porIdioma')(categ_king.categorias_traducidas, idioma_id)
						if categ_traducido.length > 0
							#categ_traducido[0].categoria_king_id = categ_king.id
							resultado.push categ_traducido[0]


			return resultado

		else

			return categoriasking
])



.filter('nombreCategoria', ['$filter', ($filter)->
	(categoria_id, categoriasking, idioma_id, abrev) ->


		categoria_id = parseFloat(categoria_id)
		idioma_id = parseFloat(idioma_id)

		categ_king = $filter('filter')(categoriasking, {id: categoria_id})

		if categ_king.length > 0
			categ_king = categ_king[0]
		else
			return ''

		categ_traducido = $filter('porIdioma')(categ_king.categorias_traducidas, idioma_id)
		if categ_traducido.length > 0
			categ_traducido = categ_traducido[0]
		else
			return ''

		# Si quiere la abreviatura
		if abrev
			return categ_traducido.abrev
		else
			return categ_traducido.nombre
])


