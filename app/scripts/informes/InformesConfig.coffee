'use strict'

angular.module('WissenSystem')
	.config ['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', '$translateProvider', ($state, App, USER_ROLES, PERMISSIONS, $translateProvider) ->

		$state
			.state('panel.informes', { #- Estado admin.
				url: '^/informes/'
				views:
					'contenido_panel':
						templateUrl: "#{App.views}informes/informes.tpl.html"
						controller: 'InformesCtrl'
				resolve: {
					datos: ['$q', 'Restangular', '$stateParams', ($q, Restangular, $stateParams)->
						d = $q.defer();

						Restangular.one('informes-infor/datos').customPUT().then((r)->
							d.resolve r
						, (r2)->
							d.reject r2
						)

						return d.promise
					]
				}
				data:
					pageTitle: 'Informes'
			})


		.state 'panel.informes.ver_todos_los_examenes',
			url: 'ver_todos_los_examenes?gran_final&evento_id'
			params: {
				gran_final: null
				evento_id: null
			}
			views:
				'report_content':
					templateUrl: "#{App.views}informes/verTodosLosExamenes.tpl.html"
					controller: 'VerTodosLosExamenesCtrl'

			data:
				pageTitle: 'Todos los Examenes - Wissen'
			resolve:
				examenes: ['Restangular', '$stateParams', (Restangular, $stateParams)->
					gran_final = if $stateParams.gran_final==true or $stateParams.gran_final=='true' then 1 else 0
					Restangular.all('informes/todos-los-examenes').getList({gran_final: gran_final, evento_id: $stateParams.evento_id });
				],



		.state 'panel.informes.ver_todos_los_examenes_por_entidades',
			url: 'ver_todos_los_examenes_por_entidades?gran_final&evento_id'
			params: {
				gran_final: null
				evento_id: null
			}
			views:
				'report_content':
					templateUrl: "#{App.views}informes/verTodosLosExamenesPorEnt.tpl.html"
					controller: 'VerTodosLosExamenesPorEntCtrl'
			data:
				pageTitle: 'Todos los exámenes por entidades - Wissen'
			resolve:
				entidades: ['Restangular', '$stateParams', (Restangular, $stateParams)->
					gran_final = if $stateParams.gran_final==true or $stateParams.gran_final=='true' then 1 else 0
					parametros = {gran_final: gran_final, evento_id: $stateParams.evento_id }

					if localStorage.requested_entidades
						requested_entidades = JSON.parse(localStorage.requested_entidades)

						if requested_entidades.length > 0
							parametros.requested_entidades = requested_entidades

					return Restangular.one('puestos/todos-examenes-ent').customPUT(parametros);
				],




		.state 'panel.informes.ver_examenes_por_entidades_categorias',
			url: 'ver_examenes_por_entidades_categorias?gran_final&evento_id'
			params: {
				gran_final: null
				evento_id: null
			}
			views:
				'report_content':
					templateUrl: "#{App.views}informes/verExamenesPorEntCateg.tpl.html"
					controller: 'VerExamenesPorEntidadesCtrl'
			resolve:
				entidades: ['Restangular', '$stateParams', (Restangular, $stateParams)->
					gran_final = if $stateParams.gran_final==true or $stateParams.gran_final=='true' then 1 else 0
					parametros = {gran_final: gran_final, evento_id: $stateParams.evento_id }

					if localStorage.requested_entidades
						requested_entidades = JSON.parse(localStorage.requested_entidades)

						if requested_entidades.length > 0
							parametros.requested_entidades = requested_entidades

					if localStorage.requested_categorias
						requested_categorias = JSON.parse(localStorage.requested_categorias)

						if requested_categorias.length > 0
							parametros.requested_categorias = requested_categorias

					Restangular.one('puestos/examenes-ent-categ').customPUT(parametros);
				],
			data:
				pageTitle: 'Exámenes por entidades - Wissen'





		.state 'panel.informes.ver_examenes_por_categorias',
			url: 'ver_examenes_por_categorias?gran_final&evento_id'
			params: {
				gran_final: null
				evento_id: null
			}
			views:
				'report_content':
					templateUrl: "#{App.views}informes/verExamenesPorCategorias.tpl.html"
					controller: 'VerExamenesPorCategoriasCtrl'
			resolve:
				categorias: ['Restangular', '$stateParams', (Restangular, $stateParams)->
					gran_final = if $stateParams.gran_final==true or $stateParams.gran_final=='true' then 1 else 0
					parametros = {gran_final: gran_final, evento_id: $stateParams.evento_id }

					if localStorage.requested_entidades
						requested_entidades = JSON.parse(localStorage.requested_entidades)

						if requested_entidades.length > 0
							parametros.requested_entidades = requested_entidades

					if localStorage.requested_categorias
						requested_categorias = JSON.parse(localStorage.requested_categorias)

						if requested_categorias.length > 0
							parametros.requested_categorias = requested_categorias

					Restangular.one('puestos/examenes-categorias').customPUT(parametros);
				],
			data:
				pageTitle: 'Exámenes por categorías - Wissen'



		$translateProvider.translations('EN',
			INICIO_MENU: 'Home'
		)
		.translations('ES',
			INICIO_MENU: 'Inicio'

		)
		.translations('PT',
			INICIO_MENU: 'Inicio'

		)
		.translations('FR',
			INICIO_MENU: 'Inicio'

		)




		return
	]
