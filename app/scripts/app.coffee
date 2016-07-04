'use strict'

angular.module('WissenSystem', [
  'ngAnimate'
  'ngCookies'
  'ngResource'
  'ngRoute'
  'ngSanitize'
  'ui.router'
  'ui.bootstrap'
  'ui.select'
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
  'ngFileUpload'
  'FBAngular'
  'ngMaterial'
  'froala'
  'angular-svg-round-progress'
  'qrScanner'
  'ja.qr'
  'ngWebSocket'
])

#- Valores que usaremos para nuestro proyecto
.constant('App', (()->

  dominio = ''
  ip = ''

  if (typeof(Storage) != "undefined")

    if localStorage.getItem("dominio") == null
      console.log 'No hay dominio almacenado'
      ip = '192.168.1.31'
      localStorage.setItem('dominio', ip)
      #dominio = 'http://lalvirtual.com/wissen/' 
      dominio = 'http://' + '192.168.1.31' + '/' # Pruebas en mi localhost
      #dominio = 'http://olimpiadaslibertad.com/'
      #dominio = 'http://192.168.1.100/'
    else
      dominio = 'http://' + localStorage.getItem('dominio') + '/'
  else
    dominio = 'http://192.168.1.31/'
    alert 'El navegador no soporta LocalStorage'

  

  
  
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
    dominio: dominio
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

