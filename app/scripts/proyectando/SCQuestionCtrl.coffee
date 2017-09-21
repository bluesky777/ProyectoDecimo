
angular.module('WissenSystem')

.controller('SCQuestionCtrl', ['$scope', '$http', 'Restangular', '$state', 'MySocket', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', 'SocketData', '$filter', '$uibModal',
	($scope, $http, Restangular, $state, MySocket, $rootScope, AuthService, Perfil, App, resolved_user, toastr, SocketData, $filter, $modal) ->

		$scope.MySocket = MySocket
		$scope.SocketData = SocketData

		
		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)


		$scope.opcion_elegida 	= -1

		MySocket.on('selec_opc_in_question', (data)->
			$scope.opcion_elegida = data.opcion
			for opcion, indice in SocketData.config.pregunta.opciones
				opcion.revelada_acertada 		= false
				opcion.revelada_no_acertada 	= false

				if data.opcion == indice
					opcion.elegida = true
				else
					opcion.elegida = false
		);

		MySocket.on('sc_reveal_answer', (data)->
			for opcion, indice in SocketData.config.pregunta.opciones
				if opcion.is_correct
					if indice == $scope.opcion_elegida
						opcion.revelada_acertada 		= true
						opcion.revelada_no_acertada 	= false
					else
						opcion.revelada_acertada 		= false
						opcion.revelada_no_acertada 	= true
		);


		return
	]
)