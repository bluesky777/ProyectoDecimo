'use strict'

angular.module("WissenSystem")

.controller('FileManagerCtrl', ['$scope', 'Upload', '$timeout', '$filter', 'App', 'Restangular', 'Perfil', '$uibModal', '$mdDialog', 'resolved_user', 'toastr', 'AuthService', ($scope, $upload, $timeout, $filter, App, Restangular, Perfil, $modal, $mdDialog, resolved_user, toastr, AuthService)->

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
				$scope.imagenes.push r
			, (r2)->
				toastr.error 'No se pudo subir foto', 'Error'
			)



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
		img_id = if imgUsu.rowid then imgUsu.rowid else imgUsu.id
		usu_id = if $scope.USER.rowid then $scope.USER.rowid else $scope.USER.id
		promesa = if $scope.USER.rowid then Restangular.one('imagenes/cambiar-imagen-perfil').customPUT({usu_id: usu_id, imagen_id: imgUsu.rowid}) else Restangular.one('imagenes/cambiar-imagen-perfil/' + usu_id).customPUT({imagen_id: imgUsu.id})

		promesa.then((r)->
			Perfil.setImagen(r.imagen_id, imgUsu.nombre)
			$scope.$emit 'cambianImgs', {image: r}
			toastr.success 'Imagen principal cambiada'
		, (r2)->
			toastr.error 'No se pudo cambiar imagen', 'Problema'
		)


	$scope.cambiarLogo = (imgLogo)->
		img_id = if imgLogo.rowid then imgLogo.rowid else imgLogo.id
		Restangular.one('imagenes/cambiar-logo').customPUT({logo_id: img_id}).then((r)->
			toastr.success 'Logo del colegio cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar el logo', 'Problema'
		)



	$scope.asignToUser = (ev, file)->

		modalInstance = $modal.open({
			controller: 'AsignToUserCtrl',
			templateUrl: App.views + 'fileManager/asignToUser.tpl.html',
			resolve: {
				usuarios: ()->
					$scope.usuarios
				perfilPath: ()->
					$scope.perfilPath
			}
		})
		modalInstance.result.then( (usuar)->
			$scope.cambiarFotoUnUsuario(usuar, file)
		)



	$scope.imagenSelect = (item, model)->
		#console.log 'imagenSelect: ', item, model

	$scope.fotoSelect = (item, model)->
		#console.log 'imagenSelect: ', item, model


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
			$scope.imagenes = $filter('filter')($scope.imagenes, {rowid: '!'+imag.rowid})
		)


	$scope.onCopyError = ()->
		toastr.warning "No se pudo copiar"

	$scope.onCopySuccess = ()->
		toastr.success "Copiado"



	$scope.usuarioSelect = (item, model)->
		$scope.dato.selectUsuarioModel = item



	$scope.cambiarFotoUnUsuario = (usuarioElegido, imgUsuario)->
		img_id = if imgUsuario.rowid then imgUsuario.rowid else imgUsuario.id
		usu_id = if usuarioElegido.rowid then usuarioElegido.rowid else usuarioElegido.id

		aEnviar = {
			imgUsuario: img_id,
			usu_id: 		usu_id
		}

		ruta = if $scope.USER.rowid then 'imagenes/cambiar-img-usuario' else ('imagenes/cambiar-img-usuario/'+usu_id)

		Restangular.one(ruta).customPUT(aEnviar).then((r)->
			toastr.success 'Imagen asignada con éxito'
			usuarioElegido.imagen_id = img_id
			usuarioElegido.imagen_nombre = imgUsuario.nombre
		, (r2)->
			toastr.error 'Error al asignar foto al usuario', 'Problema'
		)




	return
])



