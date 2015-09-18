angular.module('WissenSystem')

.controller('IniciarCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$modal', 'App', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App)->

	

	$scope.categorias_king = []
	$scope.traer_categorias_evento = ()->
		Restangular.all('categorias/categorias-evento').getList().then((r)->
			$scope.categorias_king = r
			#console.log 'Categorias traídas: ', r
		, (r2)->
			toastr.warning 'No se trajeron las categorias del evento', 'Problema'
			console.log 'No se trajo categorias ', r2
		)
	

	if AuthService.hasRoleOrPerm ['admin', 'profesor', 'tecnico']
		$scope.$parent.traerEventos()
	else
		$scope.traer_categorias_evento()



	$scope.iniciarExamen = (categoria)->
		modalInstance = $modal.open({
			templateUrl: App.views + 'examen_respuesta/seguroIniciarCtrl.tpl.html'
			controller: 'SeguroIniciarCtrl'
			resolve: 
				inscripcion: ()->
					categoria
				entidades: ()->
					$scope.$parent.entidades
		})
		modalInstance.result.then( (examen)->
			console.log 'Resultado del modal: ', examen
		)
		



])

