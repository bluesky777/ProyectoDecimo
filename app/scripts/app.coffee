'use strict'

angular.module('WissenSystem', [
  'ngAnimate'
  'ngCookies'
  'ngResource'
  'ngRoute'
  'ngSanitize'
  'ngTouch'
  'ui.router'
  'ui.bootstrap'
  'ui.select'
  'ui.sortable'
  'pascalprecht.translate'
  'angular-loading-bar'
  'restangular'
  'toastr'
  'http-auth-interceptor'
  'ui.grid'
  'ui.grid.edit'
  'ui.grid.resizeColumns'
  'ui.grid.exporter'
  'ui.grid.selection'
  'angularFileUpload'
  'FBAngular'
  'ngMaterial'
  'froala'
  'ngCordova'
])
#- Valores que usaremos para nuestro proyecto
.constant('App', (()->

  #dominio = 'http://lalvirtual.com/wissen/' 
  dominio = 'http://localhost/' # Pruebas en mi localhost
  #dominio = 'http://olimpiadaslibertad.com/'
  
  console.log 'Entra al dominio: ', location.hostname
  
  if(location.hostname.match('lalvirtual'))
    dominio = 'http://lalvirtual.com/wissen/'
    
  if(location.hostname.match('olimpiadaslibertad'))
    dominio = 'http://olimpiadaslibertad.com/'
  
  server = dominio + 'wissenLaravel/public/'
  #server = ''
  frontapp = dominio + 'ProyectoDecimo/'




  return {
    Server: server
    views: 'views/'
    #views: server + 'views/dist/views/' # Para el server Laravel
    images: server + 'images/'
    perfilPath: server + 'images/perfil/'
    imgSystemPath: server + 'images/eventos/'
  }
)())


.constant('AUTH_EVENTS', {
  loginSuccess: 'auth-login-success',
  loginFailed: 'auth-login-failed',
  logoutSuccess: 'auth-logout-success',
  sessionTimeout: 'auth-session-timeout',
  notAuthenticated: 'auth-not-authenticated',
  notAuthorized: 'auth-not-authorized'
})
.constant('USER_ROLES', {
  all:            '*',
  admin:          'admin',
  participante:   'participante',
  tecnico:        'tecnico'
  profesor:       'profesor'
  guest:          'guest'
})
.constant('PERMISSIONS', {
  can_work_like_admin:            'can_work_like_admin'
  can_work_like_teacher:          'can_work_like_teacher'
  can_work_like_participante:     'can_work_like_participante'
  can_work_like_tecnico:          'can_work_like_tecnico'
  can_work_like_guest:            'can_work_like_guest'
  can_accept_images:              'can_accept_images'
  can_edit_participantes:         'can_edit_participantes'
  can_edit_usuarios:              'can_edit_usuarios'
})

