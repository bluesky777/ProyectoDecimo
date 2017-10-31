angular.module('WissenSystem')

.controller('PreguntaEnPantallaCtrl', ['$scope', '$http', 'Restangular', '$state', 'MySocket', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', '$filter',
	($scope, $http, Restangular, $state, MySocket, $rootScope, AuthService, Perfil, App, SocketData, $filter) ->

		$scope.MySocket = MySocket
		$scope.SocketData = SocketData

		
		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)


		$scope.opcion_seleccionada = -1
		$scope.selec_opc_in_question = (pregunta, opcion, indice)->
			angular.forEach pregunta.opciones, (opt)->
				opt.elegida = false
			opcion.elegida = true

			$scope.opcion_seleccionada = indice
			MySocket.selec_opc_in_question(indice)

		$scope.sc_reveal_answer = ()->
			if $scope.opcion_seleccionada < 0
				alert('Primero debes elegir opción.')
				return

			MySocket.sc_reveal_answer()

			



		MySocket.on('selec_opc_in_question', (data)->
			$scope.opcion_seleccionada = data.opcion
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
					if indice == $scope.opcion_seleccionada
						opcion.revelada_acertada 		= true
						opcion.revelada_no_acertada 	= false

						if !$rootScope.silenciar_todo && $state.is('panel.control')
							audio = new Audio('/sounds/Revelada_correcta.wav');
							audio.play();								
					else
						opcion.revelada_acertada 		= false
						opcion.revelada_no_acertada 	= true

						if !$rootScope.silenciar_todo && $state.is('panel.control')	
							audio = new Audio('/sounds/Revalada_incorrecta.wav');
							audio.play();	
		);


		return
	]
)