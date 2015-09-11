angular.module('WissenSystem')

.filter('categsInscritas', ['$filter', ($filter)->
	(currentUsers, categorias_king) ->

		if currentUsers and categorias_king
			
			resultado = []

			if currentUsers.length == 0 or currentUsers.length == undefined
				return false


			else if currentUsers.length == 1
				
				usuario = currentUsers[0]

				for categoriaking in categorias_king

					categoriaking.algunos = false # No aplica si solo hay uno

					res = $filter('filter')(usuario.inscripciones, { categoria_id: categoriaking.id })

					if res.length > 0 
						categoriaking.incripcion_id 	= res.id
						categoriaking.selected 			= true
					else 
						categoriaking.incripcion_id 	= undefined
						categoriaking.selected 			= false

					resultado.push categoriaking


			else if currentUsers.length > 1


				for categoriaking in categorias_king

					categoriaking.incripcion_id = undefined # por ser varios, no habrá un código de inscripción
					cant = 0

					for usuario in currentUsers

						res = $filter('filter')(usuario.inscripciones, { categoria_id: categoriaking.id })

						if res.length > 0 
							cant++

					if cant == 0
						categoriaking.selected = false
						categoriaking.algunos = false

					else if cant == currentUsers.length
						categoriaking.selected = true
						categoriaking.algunos = false

					else
						categoriaking.selected = false
						categoriaking.algunos = true


					resultado.push categoriaking



				console.log 'resultado', resultado
			return resultado

		else
			return false
])


