
angular.module('WissenSystem')

.controller('SCQuestionCtrl', ['$scope', '$http', 'Restangular', '$state', 'MySocket', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', 'SocketData', '$filter', '$uibModal',
	($scope, $http, Restangular, $state, MySocket, $rootScope, AuthService, Perfil, App, resolved_user, toastr, SocketData, $filter, $modal) ->

		$scope.MySocket = MySocket
		$scope.SocketData = SocketData

		return
	]
)