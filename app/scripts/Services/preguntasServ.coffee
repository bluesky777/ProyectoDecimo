angular.module('WissenSystem')

.factory('preguntasServ', ['Restangular', 'App', '$q', '$cookies', '$rootScope', 'AUTH_EVENTS', '$http', (Restangular, App, $q, $cookies, $rootScope, AUTH_EVENTS, $http) ->

	preguntas_king = []
	is_online = false


	indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
	wissenDB = []



	setUser: (usuario) ->
		user = usuario

	getPreguntas: ()->

		d = $q.defer()


		if is_online == false
			
			wissenDB = indexedDB.open("wissenDB", 2)
			

			wissenDB.onupgradeneeded = ()->
				
				active = wissenDB.result;
				store = active.createObjectStore("preguntas_king", {keyPath: "id", autoIncrement: true});



				store.put(
					{
						descripcion: 'Una pregunta para traducir'
						tipo_pregunta: 'Test' # Test, Multiple, Texto, Lista
						duracion: 20
						categoria_id: 1
						added_by: 1
						preguntas_traducidas: [
							{
								id: 1
								enunciado: '<p>¿Cuánto es <b>dos</b> más dos?</p>'
								ayuda: 'Este es un texto de ayuda'
								pregunta_id: 4
								idioma_id: 1
								idioma: 'Español'
								puntos: 5
								added_by: 1
								opciones: [
									{
										id: 1
										definicion: 'Primera opción, y necesito meter mucho texto para ver que tal se verá al ingresar más cosas.'
										is_correct: false
									},
									{
										id: 2
										definicion: 'Segunda opción'
										is_correct: true
									},
									{
										id: 3
										definicion: 'Tercera opción'
										is_correct: false
									}
								]
							}, 
							{
								id: 2
								enunciado: 'How much is 2+2?'
								ayuda: ''
								pregunta_id: 4
								idioma_id: 2
								idioma: 'English'
								puntos: 5
								added_by: 1
								opciones: [
									{
										id: 4
										definicion: 'Fist option'
										is_correct: false
									},
									{
										id: 5
										definicion: 'Second option'
										is_correct: true
									},
									{
										id: 6
										definicion: 'Third option'
										is_correct: false
									}
								]
							}
						]
					},
					{
						descripcion: 'Otra pregunta'
						tipo_pregunta: 'Test' # Test, Multiple, Texto, Lista
						duracion: 20
						categoria_id: 1
						added_by: 1
						preguntas_traducidas: [
							{
								id: 1
								enunciado: '<p>¿Quién es más rápido?</p>'
								ayuda: 'Debes pensar en tu familia'
								pregunta_id: 5
								idioma_id: 1
								idioma: 'Español'
								puntos: 5
								added_by: 1
								opciones: [
									{
										id: 7
										definicion: 'Mi mamá.'
										is_correct: false
									},
									{
										id:8
										definicion: 'Mi papá'
										is_correct: true
									},
									{
										id: 9
										definicion: 'Mi hermano'
										is_correct: false
									},
									{
										id: 10
										definicion: 'Yo'
										is_correct: false
									}
								]
							}, 
							{
								id: 2
								enunciado: 'Who is the faster one in the family?'
								ayuda: 'You have to think in your family'
								pregunta_id: 5
								idioma_id: 2
								idioma: 'English'
								puntos: 5
								added_by: 1
								opciones: [
									{
										id: 11
										definicion: 'My mother'
										is_correct: false
									},
									{
										id: 12
										definicion: 'My father'
										is_correct: true
									},
									{
										id: 13
										definicion: 'My brother'
										is_correct: false
									},
									{
										id: 14
										definicion: 'Me'
										is_correct: false
									}
								]
							}
						]
					}
				)

			wissenDB.onsuccess = ()->
				active = wissenDB.result

				transaction = active.transaction(["preguntas_king"], "readwrite");

				objectStore = transaction.objectStore("preguntas_king")
				wissenDB = objectStore.get(1)
				#wissenDB = objectStore.getAll() # Solo sirve en firefox
				wissenDB.onerror = (event)->
					console.log 'Error'
				wissenDB.onsuccess = (event)->
					console.log 'Powerrr', wissenDB.result

					d.resolve([wissenDB.result])


			#indexedDB.deleteDatabase('DB NAME')

		else

			Restangular.all('preguntas_king', {dato:'ujno', mas: 'otro'}).getList().then((r)->
				console.log 'Este es el pedido de preguntas', r
				d.resolve r
			(r2)->
				console.log 'Falló pedido de preguntas', r2
				d.reject r2
			)

			preguntas_king = [
				{
					id: 5
					descripcion: 'Otra pregunta'
					tipo_pregunta: 'Test' # Test, Multiple, Texto, Lista
					duracion: 20
					categoria_id: 1
					added_by: 1
					preguntas_traducidas: [
						{
							id: 1
							enunciado: '<p>¿Quién es más rápido?</p>'
							ayuda: 'Debes pensar en tu familia'
							pregunta_id: 5
							idioma_id: 1
							idioma: 'Español'
							puntos: 5
							added_by: 1
							opciones: [
								{
									id: 7
									definicion: 'Mi mamá.'
									is_correct: false
								},
								{
									id:8
									definicion: 'Mi papá'
									is_correct: true
								},
								{
									id: 9
									definicion: 'Mi hermano'
									is_correct: false
								},
								{
									id: 10
									definicion: 'Yo'
									is_correct: false
								}
							]
						}, 
						{
							id: 2
							enunciado: 'Who is the faster one in the family?'
							ayuda: 'You have to think in your family'
							pregunta_id: 5
							idioma_id: 2
							idioma: 'English'
							puntos: 5
							added_by: 1
							opciones: [
								{
									id: 11
									definicion: 'My mother'
									is_correct: false
								},
								{
									id: 12
									definicion: 'My father'
									is_correct: true
								},
								{
									id: 13
									definicion: 'My brother'
									is_correct: false
								},
								{
									id: 14
									definicion: 'Me'
									is_correct: false
								}
							]
						}
					]
				}
			]

			d.resolve(preguntas_king)

		return d.promise






	savePregunta: (new_pregunta_king)->

		d = $q.defer()

		
		wissenDB = indexedDB.open("wissenDB", 2)
		
		wissenDB.onsuccess = ()->

			active = wissenDB.result;

			transaction = active.transaction(["preguntas_king"], "readwrite")

			objectStore = transaction.objectStore("preguntas_king")

			console.log 'objectStore', objectStore

			objectStore.put(new_pregunta_king)

			
			


		return d.promise





])



