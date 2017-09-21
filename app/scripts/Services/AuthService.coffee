angular.module('WissenSystem')

.factory('AuthService', ['Restangular', '$state', '$http', '$cookies', 'Perfil', '$rootScope', 'AUTH_EVENTS', '$q', '$filter', 'toastr', 'MySocket', (Restangular, $state, $http, $cookies, Perfil, $rootScope, AUTH_EVENTS, $q, $filter, toastr, MySocket)->
	authService = {}


	authService.verificando = false
	authService.promesa_de_verificacion = {}


	authService.verificar = ()->

		if authService.verificando

			return authService.promesa_de_verificacion

		else

			d = $q.defer();

			# No necesitaría verificar si ya se ha logueado
			if Perfil.User().id
				d.resolve Perfil.User()
			else
				if $cookies.get('xtoken')
					if $cookies.get('xtoken') != undefined and $cookies.get('xtoken') != 'undefined'  and $cookies.get('xtoken') != '[object Object]'
						authService.login_from_token().then((usuario)->
							Perfil.setUser usuario
							d.resolve usuario
						, (r2)->
							console.log 'No se logueó from token'
							d.reject r2
							#authService.borrarToken()
							#$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
						)
					else
						console.log 'Token mal estructurado: ', $cookies.get('xtoken')
						authService.borrarToken()
						$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
						d.reject 'Token mal estructurado.'
				else
					console.log 'No hay cookie token.'
					d.reject 'No hay cookie token.'
					$state.go 'login'
					$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)

			authService.promesa_de_verificacion = d.promise

			return authService.promesa_de_verificacion


	authService.verificar_acceso = ()->
		if !Perfil.User().id
			$state.go 'login'

		next = $state.current

		if next.data.needed_permissions
			needed_permissions = next.data.needed_permissions 

			if (!authService.isAuthorized(needed_permissions))
				#event.preventDefault()
				console.log 'No tiene permisos, y... '
				
				$rootScope.lastState = next.name
				if (authService.isAuthenticated())
					# user is not allowed
					$rootScope.$broadcast(AUTH_EVENTS.notAuthorized)
					console.log '...está Autenticado.'
				else
					# user is not logged in
					#$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
					console.log '...NO está Autenticado.'
					$state.transitionTo 'login'
		else
			return true



	authService.login_credentials = (credentials)->

		d = $q.defer();

		authService.borrarToken()

		Restangular.one('login/login').customPOST(credentials).then((user)->
			#debugger
			if user.token
				$cookies.put('xtoken', user.token)
				
				$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')

				Perfil.setUser user
				registered = if localStorage.getItem('registered_boolean') == null then false else localStorage.getItem('registered_boolean') 
				registered = if registered=='false' then false else true
				MySocket.emit('loguear', {usuario: user, registered: registered, nombre_punto: localStorage.nombre_punto} )

				#console.log 'Usuario traido: ', user

				
				$rootScope.$broadcast AUTH_EVENTS.loginSuccess
				d.resolve user
			else
				console.log 'No se trajo un token en el login.', user
				$rootScope.$broadcast AUTH_EVENTS.loginFailed
				d.reject 'Error en login'


		, (r2)->
			console.log 'No se pudo loguear. ', r2, $state

			if r2.data
				if r2.data.error
					if r2.data.error == 'Token expirado' or r2.error == 'token_expired'
						toastr.warning 'La sesión ha expirado'
						if $state.current.name != 'login'
							$state.go 'login'
						
					else
						$rootScope.$broadcast AUTH_EVENTS.loginFailed

			d.reject 'Error en login'
		)
		return d.promise


	authService.login_from_token = ()->

		d = $q.defer();

		if !Perfil.User().id #or Perfil.User().id == undefined

			#Perfil.setUser {id: 99999}

			$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')

			login = Restangular.one('login/verificar').post().then((usuario)->
				registered = if localStorage.getItem('registered_boolean') == null then false else localStorage.getItem('registered_boolean') 
				registered = if registered=='false' then false else true
				MySocket.emit('loguear', {usuario: usuario, registered: registered, nombre_punto: localStorage.nombre_punto} )
				$rootScope.$broadcast(AUTH_EVENTS.loginSuccess);
				Perfil.setUser usuario
				d.resolve usuario

			, (r2)->
				console.log 'No se pudo loguear con token. ', r2
				d.reject 'Error en login con token.'
				$rootScope.$broadcast AUTH_EVENTS.loginFailed
			)
		
		else
			d.resolve Perfil.User()

		return d.promise


	authService.logout = (credentials)->
		#Restangular.one('logout').get();
		$rootScope.lastState = null
		$rootScope.lastStateParam = null
		authService.borrarToken()
		Perfil.deleteUser()
		$state.transitionTo 'login'

	authService.borrarToken = ()->
		$cookies.remove('xtoken')
		delete $http.defaults.headers.common['Authorization']

	authService.isAuthenticated = ()->
		return !!Perfil.User().id;

	authService.isAuthorized = (neededPermissions)->

		user = Perfil.User()
		if user.is_superuser
			return true

		if (!angular.isArray(neededPermissions))
			neededPermissions = [neededPermissions]

		if (!angular.isArray(user.perms))
			if neededPermissions.length > 0
				return false; # Hay permisos requeridos pero el usuario no tiene ninguno
			else
				return true; # El usuarios no tiene permisos pero no se requiere ninguno
		
		newArr = []
		_.each(neededPermissions, (elem)->
			if (user.perms.indexOf(elem)) != -1
				newArr.push elem
		)
		return (authService.isAuthenticated() and (newArr.length > 0))


	authService.hasRoleOrPerm = (ReqRoles, RedPermis)->
		if (!angular.isArray(ReqRoles))
			if ReqRoles
				ReqRoles = [ReqRoles]
			else
				return false;

		rolesFound = []
		
		_.each(ReqRoles, (elem)->
			rolesFoundTemp = []
			rolesFoundTemp = $filter('filter')(Perfil.User().roles, {name: elem})

			if rolesFoundTemp
				if rolesFoundTemp.length > 0
					rolesFound.push elem
		)
		return (rolesFound.length > 0)



	return authService;
])

