angular.module('WissenSystem')

.directive('sidenavSelectUsuDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}control/sidenavSelectUsuDir.tpl.html"
	scope: false
	controller: 'SidenavSelectUsuCtrl'
		

])
.controller('SidenavSelectUsuCtrl', ['$scope', 'Restangular', 'toastr', 'MySocket', 'SocketData', '$mdSidenav',  ($scope, Restangular, toastr, MySocket, SocketData, $mdSidenav)->

	$scope.niveles_king = []
	$scope.traer_niveles = ()->
		Restangular.all('niveles/niveles-usuario').getList().then((r)->
			$scope.niveles_king = r
			#console.log 'Niveles traídas: ', r
		, (r2)->
			toastr.warning 'No se trajeron las niveles', 'Problema'
			console.log 'No se trajo niveles ', r2
		)
	$scope.traer_niveles()


	$scope.entidades = []
	$scope.traer_entidades = ()->
		Restangular.all('entidades').getList().then((r)->
			$scope.entidades = r
		, (r2)->
			toastr.warning 'No se trajeron las entidades', 'Problema'
			console.log 'No se trajo entidades ', r2
		)
	$scope.traer_entidades()

		
	$scope.categorias_king1 = []
	$scope.categorias_king2 = []
	$scope.traer_categorias = ()->
		Restangular.all('categorias/categorias-usuario').getList().then((r)->
			$scope.categorias_king1 = r
			angular.copy($scope.categorias_king1, $scope.categorias_king2)
			#console.log 'Categorias traídas: ', r
		, (r2)->
			toastr.warning 'No se trajeron las categorias', 'Problema'
			console.log 'No se trajo categorias ', r2
		)
	$scope.traer_categorias()




	$scope.avatar = {
		masculino: {
			abrev: 'M'
			def: 'Masculino'
			img: $scope.imagesPath + 'perfil/system/avatars/male1.jpg'
		},
		femenino: {
			abrev: 'F'
			def: 'Femenino'
			img: $scope.imagesPath + 'perfil/system/avatars/female1.jpg'
		}
	}

	
	

	$scope.guardando_edicion = false
	$scope.guardar = ()->
		$scope.guardando_edicion = true

		Restangular.one('usuarios/update').customPUT($scope.currentUser).then((r)->
			toastr.success 'Cambios guardados.'
			$scope.guardando_edicion = false
			console.log 'Cambios guardados', r
		, (r2)->
			toastr.warning 'No se guardó cambios del usuario', 'Problema'
			console.log 'No se guardó cambios del usuario ', r2
			$scope.guardando_edicion = false
		)
		
	$scope.cancelar = ()->
		$scope.guardando_edicion = false
		$mdSidenav('sidenavSelectusu').close()
		


])
