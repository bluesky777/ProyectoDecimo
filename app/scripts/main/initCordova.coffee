'use strict';

CordovaInit = ()->

    onDeviceReady = ()->
        receivedEvent('deviceready');


    receivedEvent = (event)->
        #console.log('Start event received, bootstrapping application setup.');
        angular.bootstrap($('html'), ['WissenSystem']);


    this.bindEvents = ()->
        document.addEventListener('deviceready', onDeviceReady, false);


    #If cordova is present, wait for it to initialize, otherwise just try to
    #bootstrap the application.
    if (window.cordova != undefined)
        console.log('Cordova found, wating for device.');
        this.bindEvents();
    else
        #console.log('Cordova not found, booting application');
        receivedEvent('manual')



$(()->
    new CordovaInit()
)