angular.module('WissenSystem')

.filter('categsInscritas', ['$filter', ($filter)->
	(currentUsers, categorias_king, idioma_id) ->

		idioma_id = parseInt(idioma_id)

		if currentUsers and categorias_king
			
			resultado = []
			
			if currentUsers[0] == undefined or currentUsers.length == 0 or currentUsers.length == undefined
				return []

			# CUANDO SOLO SE MANDA UN USUARIO
			else if currentUsers.length == 1
				
				usuario = currentUsers[0]
				#categorias_king_copy = []
				#angular.copy categorias_king, categorias_king_copy

				for categoriaking in categorias_king

					categ_traducidas = $filter('porIdioma')(categoriaking.categorias_traducidas, idioma_id)
					categ_traducida = {}

					if categ_traducidas.length > 0
						categ_traducida = categ_traducidas[0]

					categ_traducida.algunos 	= false # No aplica si solo hay uno
					categ_traducida.nivel_id 	= categoriaking.nivel_id


					for inscripcion in usuario.inscripciones 
						if inscripcion.categoria_id == categoriaking.id

							categ_traducida.allowed_to_answer 	= inscripcion.allowed_to_answer
							categ_traducida.examenes 			= inscripcion.examenes
							categ_traducida.inscripcion_id 		= inscripcion.id
							categ_traducida.categ_traducida_id 	= categ_traducida.id
							categ_traducida.selected 			= true
							
					if !categ_traducida.selected
						categ_traducida.inscripcion_id 		= undefined
						categ_traducida.selected 			= false


					resultado.push categ_traducida


			# CUANDO SE MANDAN VARIOS USUARIOS
			else if currentUsers.length > 1


				for categoriaking in categorias_king

					categ_traducida = $filter('porIdioma')(categoriaking.categorias_traducidas, idioma_id)
					
					if categ_traducida.length > 0
						categ_traducida = categ_traducida[0]

					categ_traducida.nivel_id = categoriaking.nivel_id
					categ_traducida.incripcion_id = undefined # por ser varios, no habrá un código de inscripción
					
					cant = 0

					for usuario in currentUsers

						res = $filter('filter')(usuario.inscripciones, { categoria_id: categoriaking.id })

						if res.length > 0 
							cant++

					if cant == 0
						categ_traducida.selected = false
						categ_traducida.algunos = false

					else if cant == currentUsers.length
						categ_traducida.selected = true
						categ_traducida.algunos = false

					else
						categ_traducida.selected = false
						categ_traducida.algunos = true


					resultado.push categ_traducida


			return resultado

		else
			return []
])



.filter('categsInscritasDeUsuario', ['$filter', ($filter)->
	(inscripciones, categorias_king, idioma_id, cmdCategSelected) ->

		if inscripciones and categorias_king
			
			resultado = []


			for categoriaking in categorias_king
				
				categ_traducida = $filter('porIdioma')(categoriaking.categorias_traducidas, parseFloat(idioma_id))
				if categ_traducida.length > 0
					categ_traducida = categ_traducida[0]
							
				for inscripcion in inscripciones 
					if inscripcion.categoria_id == categoriaking.id

							categ_traducida.nivel_id = categoriaking.nivel_id
							categ_traducida.allowed_to_answer 	= inscripcion.allowed_to_answer
							categ_traducida.examenes 			= inscripcion.examenes
							categ_traducida.inscripcion_id 		= inscripcion.id
							categ_traducida.categ_traducida_id 	= categ_traducida.id

							resultado.push categ_traducida


			if cmdCategSelected
				for categ in resultado
					if categ.categoria_id == cmdCategSelected
						categ.selected = true
					else
						categ.selected = false
			else
				for categ in resultado
					categ.selected = false

			return resultado

		else
			return []
])


.filter('listaCategsDelUsuarioSegunNivel', ['$filter', ($filter)->
	(categorias_inscripcion, nivel_usuario_id) ->

		if categorias_inscripcion and nivel_usuario_id
			
			resultado 			= []
			nivel_usuario_id 	= parseInt(nivel_usuario_id)


			for categoria in categorias_inscripcion

				if categoria.nivel_id == nivel_usuario_id or nivel_usuario_id == null or nivel_usuario_id == 0 or nivel_usuario_id == -1
					resultado.push categoria


			
			return resultado

		else
			return categorias_inscripcion
])



.filter('categSelectedDeUsuario', ['$filter', ($filter)->
	(usuario, categorias_king, idioma_id, categsel) ->

		if usuario and categorias_king
			
			resultado = []


			for categoriaking in categorias_king

				if categoriaking.id == parseInt(categsel)

					categ_traducida = $filter('porIdioma')(categoriaking.categorias_traducidas, parseFloat(idioma_id))
					
					if categ_traducida.length > 0
						categ_traducida = categ_traducida[0]
						
						res = $filter('filter')(usuario.inscripciones, { categoria_id: categoriaking.id })
						if res
							if res.length > 0 
								res = res[0]
								categ_traducida.allowed_to_answer = res.allowed_to_answer
								categ_traducida.examenes = res.examenes
								categ_traducida.inscripcion_id = res.id

								resultado.push categ_traducida


			
			return resultado

		else
			return []
])


