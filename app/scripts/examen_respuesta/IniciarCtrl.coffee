angular.module('WissenSystem')

.controller('IniciarCtrl', ['$scope', 'Restangular', 'toastr', '$filter', 'AuthService', '$state', '$uibModal', 'App', 'SocketData', 'MySocket', 'Perfil', '$rootScope', ($scope, Restangular, toastr, $filter, AuthService, $state, $modal, App, SocketData, MySocket, Perfil, $rootScope)->

	
	$scope.$state 				= $state
	$scope.categorias_king 		= []
	$scope.examenes_puntajes 	= []
	$scope.hasRoleOrPerm 		= AuthService.hasRoleOrPerm



	$scope.traer_categorias_evento = ()->
		Restangular.all('categorias/categorias-evento').getList().then((r)->
			$scope.categorias_king = r

		, (r2)->
			toastr.warning 'No se trajeron las categorias del evento', 'Problema'
			console.log 'No se trajo categorias ', r2
		)
		Restangular.all('informes/mis-examenes').getList().then((r)->
			$scope.examenes_puntajes = r
			#console.log 'Categorias traídas: ', r
		, (r2)->
			toastr.warning 'No se trajeron los resultados', 'Problema'
			console.log 'No se trajo resultados ', r2
		)
	

	if AuthService.hasRoleOrPerm ['admin', 'profesor', 'tecnico']
		$scope.$parent.traerEventos()
	else
		$scope.traer_categorias_evento()


	# Esta función es llamada por el participante cuando él presiona una categoría en la que está inscrito
	$scope.iniciarExamen = (categoria)->
		if $scope.evento_actual.gran_final
			SocketData.cambiar_mi_categsel(categoria.categoria_id, categoria.nombre, categoria.abrev)
			MySocket.change_my_categ_selected(categoria.categoria_id, categoria.nombre, categoria.abrev)
		else
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
		

	$scope.categoriaSelect = ()->
		return SocketData.cliente(Perfil.getResourceId())
		

	$scope.iniciarProyeccion = ()->
		$state.go 'proyectando'


	destroyEmpezar_examen = $rootScope.$on 'empezar_examen', (event)->
		cliente 		= SocketData.cliente(Perfil.getResourceId())
		inscripcion 	= {categoria_id: cliente.categsel_id }

		for inscrip in $scope.USER.inscripciones
			if inscrip.categoria_id == cliente.categsel_id
				inscripcion.inscripcion_id = inscrip.id

		Restangular.all('examenes_respuesta/iniciar').customPOST(inscripcion).then((r)->
			$rootScope.examen_actual = r
			$state.transitionTo 'panel.examen_respuesta' # Solo si va a contiunar con un examen: , {examen_respuesta_id: r.examen_id}
		, (r2)->
			toastr.warning 'No se pudo iniciar el examen.', 'Problema'
			console.log 'Error creando el examen: ', r2
		)



	$scope.$on('$destroy', ()->
	  destroyEmpezar_examen() # remove listener.
	);  

	$rootScope.$on('categ_selected_change', ()->
	  $scope.$apply();
	);  



])

