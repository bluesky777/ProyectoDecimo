angular.module('WissenSystem')
#- Run ejecuta código depués de haber configurado nuestro módulo con config()
.run ['$rootScope', 'cfpLoadingBar', '$state', '$stateParams', '$translate', '$cookies', 'Restangular', 'Perfil', 'AuthService', 'AUTH_EVENTS', 'toastr', ($rootScope, cfpLoadingBar, $state, $stateParams, $translate, $cookies, Restangular, Perfil, AuthService, AUTH_EVENTS, toastr) ->

	$rootScope.examen_actual = {"id":3,"categoria_id":1,"evento_id":2,"actual":1,"descripcion":"prueba","duracion_preg":2,"duracion_exam":6,"one_by_one":null,"created_by":1,"deleted_by":null,"deleted_at":null,"created_at":"2015-09-15 05:38:30","updated_at":"2015-09-15 13:07:02","preguntas":[{"id":36,"descripcion":null,"tipo_pregunta":"Test","duracion":null,"categoria_id":1,"puntos":null,"aleatorias":0,"added_by":1,"deleted_by":null,"deleted_at":null,"created_at":"2015-09-04 10:37:59","updated_at":"2015-09-04 10:37:59","evaluacion_id":3,"orden":2,"preguntas_traducidas":[{"id":100,"enunciado":"<p>Pregunta <strong>36<\/strong><\/p>","ayuda":"","pregunta_id":36,"idioma_id":2,"traducido":0,"idioma":"Ingl\u00e9s","opciones":[{"id":17,"definicion":"Opci\u00f3n 1","orden":0,"pregunta_traduc_id":100,"is_correct":1},{"id":25,"definicion":"Opci\u00f3n ascs","orden":1,"pregunta_traduc_id":100,"is_correct":0},{"id":34,"definicion":"Opci\u00f3n 3","orden":2,"pregunta_traduc_id":100,"is_correct":0},{"id":35,"definicion":"Opci\u00f3n 4","orden":3,"pregunta_traduc_id":100,"is_correct":0}]},{"id":101,"enunciado":"<p>Pregunta<u> 36<\/u><\/p>","ayuda":"","pregunta_id":36,"idioma_id":3,"traducido":0,"idioma":"Portugu\u00e9s","opciones":[{"id":18,"definicion":"Opci\u00f3n as1","orden":0,"pregunta_traduc_id":101,"is_correct":1},{"id":26,"definicion":"Opci\u00f3n aas2","orden":1,"pregunta_traduc_id":101,"is_correct":0}]},{"id":102,"enunciado":"Pregunta 36","ayuda":"","pregunta_id":36,"idioma_id":4,"traducido":0,"idioma":"Franc\u00e9s","opciones":[{"id":27,"definicion":"Opci\u00f3n 1","orden":0,"pregunta_traduc_id":102,"is_correct":1},{"id":28,"definicion":"Opci\u00f3n 2","orden":1,"pregunta_traduc_id":102,"is_correct":0}]}]},{"id":5,"descripcion":"","categoria_id":1,"is_cuadricula":0,"added_by":1,"deleted_by":null,"deleted_at":null,"created_at":"2015-09-08 09:12:38","updated_at":"2015-09-08 09:12:38","evaluacion_id":3,"orden":1,"contenidos_traducidos":[{"id":4,"definicion":"<p>Contenido 4d<strong>fvfe<\/strong>regr<\/p>","grupo_pregs_id":5,"idioma_id":2,"idioma":"Ingl\u00e9s","preguntas_agrupadas":[{"id":3,"enunciado":"<p>Pregunt<strong>a agrupadadfsd dsfv &nbsp;sdf<\/strong><\/p>","ayuda":null,"duracion":null,"tipo_pregunta":"Multiple","puntos":null,"aleatorias":0,"opciones":[{"id":1,"definicion":"Opci\u00f3n 1 dsfvsdf","orden":0,"preg_agrupada_id":3,"is_correct":1},{"id":2,"definicion":"Opci\u00f3n 2f rrrrr","orden":1,"preg_agrupada_id":3,"is_correct":0}]},{"id":14,"enunciado":"Pregunta agrupada","ayuda":null,"duracion":null,"tipo_pregunta":"Test","puntos":null,"aleatorias":null,"opciones":[]}]},{"id":5,"definicion":"Contenido 5","grupo_pregs_id":5,"idioma_id":3,"idioma":"Portugu\u00e9s","preguntas_agrupadas":[{"id":8,"enunciado":"Pregunta agrupada","ayuda":null,"duracion":null,"tipo_pregunta":"Test","puntos":null,"aleatorias":0,"opciones":[]},{"id":9,"enunciado":"<p>Pregunta agrupada<\/p>","ayuda":null,"duracion":null,"tipo_pregunta":"Test","puntos":null,"aleatorias":null,"opciones":[{"id":3,"definicion":"Opci\u00f3n 1","orden":0,"preg_agrupada_id":9,"is_correct":1},{"id":4,"definicion":"Opci\u00f3n 2","orden":1,"preg_agrupada_id":9,"is_correct":0}]}]},{"id":6,"definicion":"<p>C<u>onten<\/u>ido 6dcaa<\/p>","grupo_pregs_id":5,"idioma_id":4,"idioma":"Franc\u00e9s","preguntas_agrupadas":[]}]},{"id":7,"descripcion":"","categoria_id":1,"is_cuadricula":0,"added_by":1,"deleted_by":null,"deleted_at":null,"created_at":"2015-09-09 18:52:32","updated_at":"2015-09-09 18:52:32","evaluacion_id":3,"orden":4,"contenidos_traducidos":[{"id":10,"definicion":"<p>Conte<strong>nido<\/strong> 7<\/p>","grupo_pregs_id":7,"idioma_id":2,"idioma":"Ingl\u00e9s","preguntas_agrupadas":[{"id":13,"enunciado":"Pregunta agrupada","ayuda":null,"duracion":null,"tipo_pregunta":"Test","puntos":null,"aleatorias":0,"opciones":[]}]},{"id":11,"definicion":"Contenido 7","grupo_pregs_id":7,"idioma_id":3,"idioma":"Portugu\u00e9s","preguntas_agrupadas":[]},{"id":12,"definicion":"Contenido 7","grupo_pregs_id":7,"idioma_id":4,"idioma":"Franc\u00e9s","preguntas_agrupadas":[]}]},{"id":8,"descripcion":"","categoria_id":1,"is_cuadricula":0,"added_by":1,"deleted_by":null,"deleted_at":null,"created_at":"2015-09-09 19:00:52","updated_at":"2015-09-09 19:00:52","evaluacion_id":3,"orden":3,"contenidos_traducidos":[{"id":13,"definicion":"Contenido 8","grupo_pregs_id":8,"idioma_id":2,"idioma":"Ingl\u00e9s","preguntas_agrupadas":[{"id":15,"enunciado":"Pregunta agrupada","ayuda":null,"duracion":null,"tipo_pregunta":"Test","puntos":null,"aleatorias":null,"opciones":[{"id":5,"definicion":"Opci\u00f3n 1","orden":0,"preg_agrupada_id":15,"is_correct":1},{"id":6,"definicion":"Opci\u00f3n 2","orden":1,"preg_agrupada_id":15,"is_correct":0}]}]},{"id":14,"definicion":"Contenido 8","grupo_pregs_id":8,"idioma_id":3,"idioma":"Portugu\u00e9s","preguntas_agrupadas":[]},{"id":15,"definicion":"Contenido 8","grupo_pregs_id":8,"idioma_id":4,"idioma":"Franc\u00e9s","preguntas_agrupadas":[]}]}],"inscripcion_id":9,"examen_id":10}

	#- Asignamos la información de los estados actuales para poder manipularla en las vistas.
	$rootScope.$state = $state
	$rootScope.$stateParams = $stateParams;
	$rootScope.lastState = null; #- Para saber de qué viene cuando se redireccione automáticamente al login.
	$rootScope.lastStateParam = null;


	#- Evento que se ejecuta cuando envío alguna petición al servidor que requiere autenticación y no está autenticado.
	$rootScope.$on 'event:auth-loginRequired', (r)->
		console.log 'Acceso no permitido, vamos a loguear', r
		$state.transitionTo 'login'

	ingresar = ()->
		#- Si lastState es null, quiere decir que hemos entrado directamente a login sin ser redireccionados.
		if $rootScope.lastState == null or $rootScope.lastState == 'login' or $rootScope.lastState == '/' or $rootScope.lastState == 'main'
			$state.go 'panel' #- Por lo tanto nos vamos a panel después de autenticarnos.
		else
			$state.transitionTo $rootScope.lastState, $rootScope.lastStateParam #- Si no es null ni login, Nos vamos al último estado.
		#console.log 'Funcion ingresar. lastState: ', $rootScope.lastState

	#- Evento ejecutado cuando nos logueamos despues del servidor haber pedido autenticación.
	$rootScope.$on 'event:auth-loginConfirmed', ()->
		console.log 'Logueado con éxito!'
		ingresar()


	#- Evento que se ejecuta cuando vamos a cambiar de estado.
	$rootScope.$on '$stateChangeStart', (event, next, toParams, fromState, fromParams)->
		#console.log 'Va a empezar a cambiar un estado: ', next, toParams
		if $rootScope.lastState == null or (next.name != 'logout' and next.name != 'login' and next.name != 'main' )
			$rootScope.lastState = next.name
			$rootScope.lastStateParam = toParams


	#- Evento cuando ya hemos cambiado de estado.
	$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
		#$rootScope.lastState = fromState.name if fromState.name != ''
		#-if $state.current.name == 'login' then cfpLoadingBar.complete() # No me funciona :(
		$rootScope.pageTitle = $state.current.name;


	#- Evento cuando falla la carga del estado, por un resolve rechazado o algo así.
	$rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams)->
		#$rootScope.lastState = fromState.name if fromState.name != ''
		#-if $state.current.name == 'login' then cfpLoadingBar.complete() # No me funciona :(
		console.log $rootScope.lastState, '-Evento fallido: ', event
		toastr.warning 'Lo sentimos, hubo un error o no puedes acceder a esta vista'
		if $rootScope.lastState != 'panel'
			$state.transitionTo 'panel'
		else
			$state.transitionTo 'login'
		


	#- Se ejecuta cuando se trae un nuevo trozo de traducciones
	$rootScope.$on '$translatePartialLoaderStructureChanged', () ->
		$translate.refresh()
		console.log('Translate refrescado supuestamente.')


	$rootScope.$on AUTH_EVENTS.loginSuccess, ()->
		#console.log 'Logueado con éxito!'
		ingresar()

	$rootScope.$on AUTH_EVENTS.loginFailed, (ev)->
		toastr.error 'Datos incorrecto.', 'No se pudo loguear'
		console.log 'Evento loginFailed: ', ev

		

	$rootScope.$on AUTH_EVENTS.notAuthenticated, (ev)->
		toastr.warning 'No está autorizado.', 'Acceso exclusivo'
		console.log 'Evento notAuthenticated: ', ev
		$state.transitionTo 'login'
		


	$rootScope.$on AUTH_EVENTS.notAuthorized, (ev)->
		toastr.warning 'No está autorizado para entrar a esta vista', 'Restringido'
		$state.go 'panel'
		console.log 'Evento notAuthorized: ', ev, $rootScope.lastState

]