
angular.module('WissenSystem')

.controller('ParticipantesCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'SocketData', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket' 
	($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, SocketData, toastr, $translate, $filter, $modal, MySocket) ->

		MySocket.get_clts()
		$scope.SocketData = SocketData
		
		return
	]
)