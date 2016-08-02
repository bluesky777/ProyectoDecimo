angular.module('WissenSystem')

.controller('ControlCtrl', ['$scope', 'Restangular', 'toastr', '$state', '$window', 'MySocket', 'SocketData', '$rootScope', '$mdSidenav', '$filter',  ($scope, Restangular, toastr, $state, $window, MySocket, SocketData, $rootScope, $mdSidenav, $filter)->


	$scope.SocketData = SocketData
	$scope.cltdisponible_selected = {}
	$scope.categorias_king = []


	Restangular.all('categorias/categorias-evento').getList().then((r)->
		$scope.categorias_king = r
	, (r2)->
		toastr.warning 'No se trajeron las categorias del evento', 'Problema'
	)

	$scope.CerrarServidor = ()->
		#res = confirm "¿Seguro que desea cerrar servidor?"
		#if res 
		Restangular.one('chat/cerrar-servidor').customPUT().then((r)->
			toastr.success 'Cerrado', r
		, (r2)->
			toastr.warning 'No se cerró servidor'
			console.log 'No se cerró servidor ', r2
		)
	
	$scope.openMenu = ($mdOpenMenu, ev)->
		$mdOpenMenu(ev);

	$scope.openMenuCateg = ($mdOpenMenu, ev)->
		$mdOpenMenu(ev);

	$scope.showSidenavEditUsu = (cliente)->
		$scope.clt_to_edit = cliente.usuario
		$mdSidenav('sidenavEditusu').toggle()
			.then( ()->
				console.log("toggle  is done");
			)

	$scope.showSidenavSelectUsu = (cliente)->
		$scope.cltdisponible_selected = cliente
		MySocket.get_usuarios()
		$scope.clt_to_edit = cliente.usuario
		$mdSidenav('sidenavSelectusu').toggle()
			.then( ()->
				#console.log("toggle  is done");
			)

	$scope.Conectar = ()->
		MySocket.conectar()

		
	$scope.qrScanear = ()->
		url = $state.href('qrscanner')
		$window.open(url,'_blank')
		return true

	$scope.crearservidor = ()->
		url = $state.href('panel.crearservidor')
		$window.open(url,'_blank')
		return true

	$scope.enviarMensaje = ()->
		if $scope.newMensaje != ''
			for cliente in SocketData.clientes
				if cliente.seleccionado
					MySocket.send_email_to $scope.newMensaje, cliente
			$scope.newMensaje = ''


	$scope.deseleccionarTodo = ()->
		for cliente in SocketData.clientes
			if cliente.seleccionado
				cliente.seleccionado = false

	$scope.seleccionarTodo = ()->
		for cliente in SocketData.clientes
			if !cliente.seleccionado
				cliente.seleccionado = true

	$scope.actualizarClts = ()->
		MySocket.get_clts()

	$scope.guardarNombrePunto = (cliente)->
		nombre = $filter('clearhtml')(cliente.nombre_punto)
		MySocket.guardar_nombre_punto(cliente.resourceId, nombre)



	$scope.clickedClt = (event, cliente)->
		if $scope.deseleccionar
			cliente.seleccionado = false
		else
			cliente.seleccionado = !cliente.seleccionado

	$scope.sobreClt = (event, cliente)->
		if event.buttons == 1
			if $scope.deseleccionar
				cliente.seleccionado = false
			else
				cliente.seleccionado = true


	$scope.cerrarSesion = (cliente)->
		res = confirm "¿Cerrar sesión a " + cliente.usuario.nombres + "?"
		if res 
			MySocket.cerrar_sesion(cliente.resourceId)

	MySocket.get_clts()






])

