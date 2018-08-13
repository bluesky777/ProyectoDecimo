angular.module('WissenSystem')

.directive('contenteditable', ['$timeout', '$window', ($timeout, $window)->
	return {
		require: 'ngModel',
		scope:
			guardarNombrePunto: "="
		link: (scope, elm, attrs, ctrl)->
			# view -> model
			
			elm.bind('blur keyup change', (e)->
				$timeout(()->
					if e.keyCode is 13
						e.cancelBubble = true;
						e.returnValue = false;

						element = $window.document.getElementById('msg-especifico')
						
						if(element)
							element.focus()
						
						
						scope.guardarNombrePunto(scope.$parent.cliente)
						e.preventDefault()
					else	
						scope.$apply(()->
							ctrl.$setViewValue(elm.html())
						)
				, 0)
			)
			
			# model -> view
			ctrl.$render = ()->
				elm.html(ctrl.$viewValue)

			# load init value from DOM
			#ctrl.$setViewValue(elm.html());
	}
])