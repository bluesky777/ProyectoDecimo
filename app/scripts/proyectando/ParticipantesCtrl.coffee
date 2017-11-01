angular.module('WissenSystem')


.controller('ParticipantesCtrl', ['$scope', '$rootScope', 'App', 'SocketData', 'SocketClientes', '$filter', 'MySocket', '$timeout' 
	($scope, $rootScope, App, SocketData, SocketClientes, $filter, MySocket, $timeout) ->

		MySocket.get_clts()
		$scope.SocketData 		= SocketData
		$scope.SocketClientes 	= SocketClientes


		$scope.participantesDeCategoria = (categoria_traduc)->
			return $filter('filter')(SocketClientes.clientes, {logged :true, 'categsel':categoria_traduc.categoria_id }, true)
		
		return
	]
)


.controller('PuntajesActualesCtrl', ['$scope', '$rootScope', 'App', 'SocketData', 'SocketClientes', '$filter', 'MySocket', '$timeout' 
	($scope, $rootScope, App, SocketData, SocketClientes, $filter, MySocket, $timeout) ->
		$scope.examenes_cargados = ()->
			if $rootScope.examenes_cargados
				return $rootScope.examenes_cargados
			else
				return []

		return
	]
)


.controller('GraficoBarrasCtrl', ['$scope', '$rootScope', 'App', 'SocketData', 'SocketClientes', '$filter', 'MySocket' 
	($scope, $rootScope, App, SocketData, SocketClientes, $filter, MySocket) ->

		MySocket.get_clts()
		$scope.SocketData = SocketData

		$scope.participantes = []

		###
		$scope.$watch('SocketData', ()->

			$scope.participantes = $filter('filter')(SocketClientes.clientes, (item)->
				return item.categsel > 0;
			)
		, true)
		###

		$scope.participantes_actuales = ()->
			return SocketClientes.participantes

		$scope.participantes_en_categorias = ()->
			return (item)->
				return item.categsel > 0;
			
		
		$scope.calc_indice = (indice)->
			if indice <= 7
				return indice
			else if indice > 7 and indice <= 14
				return indice - 7
			else if indice > 14 and indice <= 21
				return indice - 14
			else if indice > 21 and indice <= 28
				return indice - 21
			else if indice > 28 and indice <= 35
				return indice - 28
			else if indice > 35 and indice <= 42
				return indice - 35
			else
				return 1


		$scope.calc_porcentaje= (respondidas)->
			valor_final = SocketData.config.info_evento.free_till_question
			if valor_final == -1 or valor_final == 0
				return 100
				
			porcentaje = respondidas * 100 / valor_final

			if porcentaje == 0
				return 1
			else
				if porcentaje > 100
					return 100
				else
					return porcentaje




		destroy_set_free_till_question_on = $rootScope.$on 'set_free_till_question', (event, free_till_question)->
			$scope.$apply()

		$scope.$on('$destroy', ()->
			destroy_set_free_till_question_on()
		);


		return
	]
)
.controller('SCPuntajeParticipCtrl', ['$scope', '$rootScope', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $rootScope, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		$scope.SocketData = SocketData
		
		return
	]
)