angular.module('WissenSystem')

.config(['App', '$stateProvider', '$translateProvider', (App, $stateProvider, $translateProvider)->
		
	$stateProvider
		.state('qrscanner', 
			url: '/qrscanner'
			views:
					'principal':
						templateUrl: "#{App.views}qrcode/qrScanner.tpl.html"
						controller: 'QrScannerCtrl'

				data: 
					pageTitle: 'QR Scanner'
		)






])