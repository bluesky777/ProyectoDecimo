
angular.module('WissenSystem')

.controller('ParticipantesCtrl', ['$scope', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $rootScope, AuthService, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		MySocket.get_clts()
		$scope.SocketData = SocketData

		$scope.participantesDeCategoria = (categoria_traduc)->
			return $filter('filter')(SocketData.clientes, {'registrado':true, 'categsel':categoria_traduc.categoria_id })
		
		return
	]
)
.controller('SCPuntajeParticipCtrl', ['$scope', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $rootScope, AuthService, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		$scope.SocketData = SocketData
		
		return
	]
)