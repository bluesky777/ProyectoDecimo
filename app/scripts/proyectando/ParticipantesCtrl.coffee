
angular.module('WissenSystem')

.controller('ParticipantesCtrl', ['$scope', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $rootScope, AuthService, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		MySocket.get_clts()
		$scope.SocketData = SocketData

		$scope.participantesDeCategoria = (categoria_traduc)->
			return $filter('filter')(SocketData.clientes, {'registrado':true, 'categsel':categoria_traduc.categoria_id }, true)
		
		return
	]
)
.controller('GraficoBarrasCtrl', ['$scope', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $rootScope, AuthService, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		MySocket.get_clts()
		$scope.SocketData = SocketData

		$scope.participantes = []


		$scope.$watch('SocketData', ()->

			$scope.participantes = $filter('filter')(SocketData.clientes, (item)->
				return item.categsel > 0;
			)
		, true)

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
				return porcentaje



		return
	]
)
.controller('SCPuntajeParticipCtrl', ['$scope', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $rootScope, AuthService, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		$scope.SocketData = SocketData
		
		return
	]
)