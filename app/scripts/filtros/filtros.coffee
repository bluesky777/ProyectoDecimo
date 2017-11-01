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



.filter('decimales', [ ->
	(input, cant) ->
		input = parseFloat(input)

		if (input % 1) == 0
			input = input.toFixed(0)
		else 
			input = input.toFixed(cant)

		return input.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
])

.filter('decimales_if', [ ->
	(input, cant) ->
		input = parseFloat(input)

		if (input % 1) == 0
			input = input.toFixed(0)
		else 
			input = input.toFixed(cant)

		numero = input.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		numero = parseFloat(numero)
		return numero
])

.filter('exaTime', [ ->
	(millseconds) ->
		seconds = Math.floor(millseconds / 1000);
		h = 3600;
		m = 60;
		hours = Math.floor(seconds/h);
		minutes = Math.floor( (seconds % h)/m );
		scnds = Math.floor( (seconds % m) );
		timeString = '';
		scnds = if (scnds < 10) then "0"+scnds;
		hours = if(hours < 10) then "0"+hours;
		minutes = if(minutes < 10) then "0"+minutes;
		timeString = hours + ":" + minutes + ":" + scnds;
		return timeString;
])


.filter('secondsToDateTime', [ ->
	(input, horas) ->
		if not input
			return ''
			
		z = (n)->
			if n < 10
				return '0' + n
			else
				return '' + n
		seconds = input % 60;

		if horas
			minutes = Math.floor(input % 3600 / 60);
			hours = Math.floor(input / 3600);
			return (z(hours) + ':' + z(minutes) + ':' + z(seconds));
		else
			minutes = Math.floor(input % 60 / 60);
			return (z(minutes) + ':' + z(seconds));

])

.filter('orderObjectBy', [ ->
	(items, tipo, reverse) ->

		filtered = [];
		angular.forEach(items, (item)->
			filtered.push(item);
		)

		sortTiempo = (a, b)->
			if a.res_tiempo > b.res_tiempo
				return if reverse then 1 else -1
			else if a.res_tiempo == b.res_tiempo
				return 0
			else
				return if reverse then -1 else 1

		filtered.sort( (a, b)->
			switch tipo 
				when 'promedio'
					if a.res_by_promedio
						if a.res_promedio > b.res_promedio
							return if reverse then -1 else 1
						else if a.res_promedio == b.res_promedio
							return sortTiempo(a, b)
						else
							return if reverse then 1 else -1
					else
						if a.res_puntos > b.res_puntos
							return if reverse then -1 else 1
						else if a.res_puntos == b.res_puntos
							return sortTiempo(a, b)
						else
							return if reverse then 1 else -1
						
				when 'cantidad_pregs'
					if a.res_cant_pregs > b.res_cant_pregs
						return if reverse then -1 else 1
					else if a.res_cant_pregs == b.res_cant_pregs
						return sortTiempo(a, b)
					else
						return if reverse then 1 else -1

				when 'nombres', 'examen_id', 'categorias', 'examen_at'
					if a[tipo] > b[tipo]
						return if reverse then -1 else 1
					else if a[tipo] == b[tipo]
						return sortTiempo(a, b)
					else
						return if reverse then 1 else -1

				when 'tiempo'
					return sortTiempo(a, b)

		);

		return filtered;
])


.filter('orderParticipantes', [ ->
	(items, puestos_ordenados) ->

		if puestos_ordenados

			filtered = [];
			angular.forEach(items, (item)->
				filtered.push(item);
			)

			sortTiempo = (a, b)->
				if a.tiempo > b.tiempo
					return 1
				else if a.tiempo == b.tiempo
					return 0
				else
					return -1

			filtered.sort( (a, b)->
				if a.correctas > b.correctas
					return -1
				else if a.correctas == b.correctas
					return sortTiempo(a, b)
				else
					return 1
			)
		
		else
			return items

		return filtered;
])



.filter('orderPuntajesActuales', [ ->
	(items) ->
		if not items
			return

		if items.length == 0
			return

		filtered = [];
		angular.forEach(items, (item)->
			filtered.push(item);
		)

		sortTiempo = (a, b)->
			if a.tiempo > b.tiempo
				return 1
			else if a.tiempo == b.tiempo
				return 0
			else
				return -1
				
		console.log items[0]
		if items[0].res_by_promedio
			filtered.sort( (a, b)->
				if a.res_promedio > b.res_promedio
					return -1
				else if a.res_promedio == b.res_promedio
					return sortTiempo(a, b)
				else
					return 1
			)
		else
			filtered.sort( (a, b)->
				if a.res_puntos > b.res_puntos
					return -1
				else if a.res_puntos == b.res_puntos
					return sortTiempo(a, b)
				else
					return 1
			)

		return filtered;
])


window.removeAccents = (value)->
	return value
		.replace(/á/g, 'a') 
		.replace(/â/g, 'a')
		.replace(/é/g, 'e')
		.replace(/è/g, 'e') 
		.replace(/ê/g, 'e')
		.replace(/í/g, 'i')
		.replace(/ï/g, 'i')
		.replace(/ì/g, 'i')
		.replace(/ó/g, 'o')
		.replace(/ô/g, 'o')
		.replace(/ú/g, 'u')
		.replace(/ü/g, 'u')
		.replace(/ç/g, 'c')
		.replace(/ß/g, 's')
		.replace(/Á/g, 'A')
		.replace(/É/g, 'E')
		.replace(/Í/g, 'I')
		.replace(/Ó/g, 'O')
		.replace(/Ú/g, 'U');





