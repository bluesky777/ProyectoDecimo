angular.module('WissenSystem')


# Configuración principal de nuestra aplicación.
.config(['$cookiesProvider', '$stateProvider', '$urlRouterProvider', '$httpProvider', '$locationProvider', 'App', 'PERMISSIONS', 'RestangularProvider', '$intervalProvider', '$rootScopeProvider', 'USER_ROLES', 'toastrConfig', 'uiSelectConfig', '$provide', ($cookies, $state, $urlRouter, $httpProvider, $locationProvider, App, PERMISSIONS, Restangular, $intervalProvider, $rootScopeProvider, USER_ROLES, toastrConfig, uiSelectConfig, $provide)->

	Restangular.setBaseUrl App.Server + 'api/' # Url a la que se harán todas las llamadas.

	angular.extend(toastrConfig, {
		maxOpened: 3
	});

	$httpProvider.defaults.useXDomain = true;
	#$httpProvider.defaults.withCredentials = true;
	delete $httpProvider.defaults.headers.common["X-Requested-With"];
	$httpProvider.defaults.headers.common["Accept"] = "application/json";
	$httpProvider.defaults.headers.common["Content-Type"] = "application/json";



	uiSelectConfig.theme = 'select2'
	uiSelectConfig.resetSearchInput = true


	#- Definimos los estados
	$urlRouter.otherwise('/login')

	$state
	.state('main', { #- Estado raiz que no necesita autenticación.
		url: '/'
		views:
			'principal':
				templateUrl: App.views+'main/main.tpl.html'
				controller: 'MainCtrl'
		data:
			pageTitle: 'En Construcción'
	})

	.state('landing', { #- Estado raiz que no necesita autenticación.
		url: '/landing'
		views:
			'principal':
				templateUrl: App.views+'main/landing.tpl.html'
				controller: 'LandingCtrl' # El controlador está en 'main.coffee'
		data:
			pageTitle: 'Liceo Adventista Libertad'
	})

	.state('login', {
		url: '/login'
		views:
			'principal':
				templateUrl: "#{App.views}login/login.tpl.html"
				controller: 'LoginCtrl'
		data:
			pageTitle: 'Ingresar a Wissen'

	})
	.state('logout', {
		url: '/logout'
		views:
			'principal':
				templateUrl: "#{App.views}login/logout.tpl.html"
				controller: 'LogoutCtrl'
		data:
			icon_fa: 'fa fa-user'

	})


	#$locationProvider.html5Mode true

	$rootScopeProvider.bigLoader = true

	$provide.decorator('taOptions', ['taRegisterTool', '$delegate', (taRegisterTool, taOptions)->
		taOptions.forceTextAngularSanitize = false
		taOptions.toolbar = [
			['h1','h2','h3', 'p', 'pre'],
			['bold','italics', 'underline', 'ul', 'ol', 'undo', 'redo'],
			['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'],
			['insertImage', 'insertLink', 'insertVideo', 'html', 'charcount']
		]

		taRegisterTool('superscript', {
			iconclass: "fa fa-superscript",
			action: ()->
				return this.$editor().wrapSelection("superscript", null);

			activeState: ()->
				return this.$editor().queryCommandState('superscript');
		})
		taRegisterTool('subscript', {
			iconclass: "fa fa-subscript",
			action: ()->
				return this.$editor().wrapSelection("subscript", null);

			activeState: ()->
				return this.$editor().queryCommandState('subscript');
		})
		taRegisterTool('insertSlash',{
			iconclass : 'fa fa-slash',
			tooltiptext : "Insertar fracción",
			action: ($deferred,restoreSelection)->
				this.$editor().wrapSelection('insertHTML','&frasl;',true);

		});

		# add the button to the default toolbar definition
		taOptions.toolbar[2].push('superscript');
		taOptions.toolbar[2].push('subscript');
		taOptions.toolbar[2].push('insertSlash');

		return taOptions
	])






	# Agrego la función findByValues a loDash.
	_.mixin
		'findByValues': (collection, property, values)->
			filtrado = _.filter collection, (item)->
				_.contains values, item[property]
			if filtrado.length == 0 then return false else filtrado[0]

	@
])

# Filtro para frases en Camellcase
.filter('capitalize', ()->
	(input, all)->
		return if !!input then input.replace(/([^\W_]+[^\s-]*) */g, (txt)-> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()) else ''
)




