angular.module('WissenSystem')


.controller('MisImagenes', ['$scope', '$uibModalInstance', 'Upload', '$timeout', '$filter', 'App', 'Restangular', 'Perfil', '$uibModal', '$mdDialog', 'resolved_user', 'toastr', 'AuthService', ($scope, $modalInstance, $upload, $timeout, $filter, App, Restangular, Perfil, $modal, $mdDialog, resolved_user, toastr, AuthService)->
	
	$scope.USER = resolved_user
	$scope.subir_intacta = {intacta: true}
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
	$scope.subirImagenes = 'nada'
	$scope.vm			= {}

	
	fixDato = ()->
		$scope.dato = 
			imgUsuario:
				id:		$scope.USER.imagen_id
				nombre:	$scope.USER.imagen_nombre 

	fixDato()
	$scope.imagesPath = App.images
	$scope.perfilPath = App.images + 'perfil/'
	$scope.imgFiles = []
	$scope.errorMsg = ''
	$scope.fileReaderSupported = window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
	$scope.dato.usuarioElegido = []


	Restangular.one('imagenes/usuarios').customGET().then((r)->
		$scope.imagenes = r.imagenes
		$scope.usuarios = r.usuarios
		$scope.dato.usuarioElegido = r[0]
		$scope.dato.imgParaUsuario = if r.imagenes.length > 0 then r.imagenes[0]
	, (r2)->
		toastr.error 'No se trajeron las imágenes y usuarios.'
	)



	$scope.uploadFoto = ()->
		file = $scope.vm.picture
		
		if (file) 

			file = file.replace(/^data\:image\/\w+\;base64\,/, '')

			Restangular.one('imagenes/store').customPOST({foto: file}).then( (r)->
				toastr.success 'Foto subida correctamente.'
				r.nombre = 'perfil/' + r.nombre
				$modalInstance.close(r)
			, (r2)->
				toastr.error 'No se pudo subir foto', 'Error'
			)



	$scope.elegirImagen = (imagen)->
		$modalInstance.close(imagen)




	$scope.upload =  (files)->
		$scope.imgFiles = files
		$scope.errorMsg = ''

		if files and files.length

			for i in [0...files.length]
				file = files[i]
				generateThumbAndUpload file


	generateThumbAndUpload = (file)->
		$scope.errorMsg = null
		uploadUsing$upload(file)
		$scope.generateThumb(file)

	$scope.generateThumb = (file)->
		if file != null
			if $scope.fileReaderSupported and file.type.indexOf('image') > -1
				$timeout ()->
					fileReader = new FileReader()
					fileReader.readAsDataURL(file)
					fileReader.onload = (e)->
						$timeout(()->
							file.dataUrl = e.target.result
						)
	
	uploadUsing$upload = (file)->

		intactaUrl = if $scope.subir_intacta.intacta then '-intacta' else ''

		if file.size > 10000000
			$scope.errorMsg = 'Archivo excede los 10MB permitidos.'
			return

		$upload.upload({
			url: App.Server + 'api/imagenes/store' + intactaUrl,
			#fields: {'username': $scope.username},
			file: file
		}).progress( (evt)->
			progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
			file.porcentaje = progressPercentage
			#console.log('progress: ' + progressPercentage + '% ' + evt.config.file.name, evt.config)
		).success( (data, status, headers, config)->
			$scope.imagenes.push data
		).error((r2)->
			console.log 'Falla uploading: ', r2
		).xhr((xhr)->
			#xhr.upload.addEventListener()
			#/* return $http promise then(). Note that this promise does NOT have progress/abort/xhr functions */
		)#.then((), error, progress)


	$scope.pedirCambioUsuario = (imgUsu)->
		Restangular.one('imagenes/cambiar-imagen-perfil/' + $scope.USER.id).customPUT({imagen_id: imgUsu.id}).then((r)->
			Perfil.setImagen(r.imagen_id, imgUsu.nombre)
			$scope.$emit 'cambianImgs', {image: r}
			toastr.success 'Imagen principal cambiada'
		, (r2)->
			toastr.error 'No se pudo cambiar imagen', 'Problema'
		)


	$scope.cambiarLogo = (imgLogo)->
		Restangular.one('imagenes/cambiar-logo').customPUT({logo_id: imgLogo.id}).then((r)->
			toastr.success 'Logo del colegio cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar el logo', 'Problema'
		)



	$scope.asignToUser = (ev, file)->
		modalInstance2 = $modal.open({
			controller: 'AsignToUserCtrl',
			templateUrl: App.views + 'fileManager/asignToUser.tpl.html',
			resolve: {
				usuarios: ()->
					$scope.usuarios
				perfilPath: ()->
					$scope.perfilPath
			}

		})
		modalInstance2.result.then( (usuar)->
			$scope.cambiarFotoUnUsuario(usuar, file)
		)
		


	$scope.rotarImagen = (imagen)->
		Restangular.one('imagenes/rotarimagen/'+imagen.id).customPUT().then((r)->
			imagen.nombre = ''
			toastr.success 'Imagen rotada'
			imagen.nombre = r + '?' + new Date().getTime()
		, (r2)->
			toastr.error 'Imagen no rotada'
		)



	$scope.borrarImagen = (imagen)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'fileManager/removeImage.tpl.html'
			controller: 'RemoveImageCtrl'
			size: 'sm',
			resolve: 
				imagen: ()->
					imagen

		})
		modalInstance.result.then( (imag)->
			$scope.imagenes = $filter('filter')($scope.imagenes, {id: '!'+imag.id})
		)


	$scope.onCopyError = ()->
		toastr.warning "No se pudo copiar"

	$scope.onCopySuccess = ()->
		toastr.success "Copiado"



	$scope.usuarioSelect = (item, model)->
		$scope.dato.selectUsuarioModel = item

	

	$scope.cambiarFotoUnUsuario = (usuarioElegido, imgUsuario)->
		aEnviar = {
			imgUsuario: imgUsuario.id
		}
		Restangular.one('imagenes/cambiar-img-usuario/'+usuarioElegido.id).customPUT(aEnviar).then((r)->
			toastr.success 'Imagen asignada con éxito'
			usuarioElegido.imagen_id = imgUsuario.id
			usuarioElegido.imagen_nombre = imgUsuario.nombre
		, (r2)->
			toastr.error 'Error al asignar foto al usuario', 'Problema'
		)



	$scope.ok = ()->
		$modalInstance.close('Cerrando...')
	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



