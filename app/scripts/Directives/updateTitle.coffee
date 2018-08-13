angular.module('WissenSystem')

.directive('updateTitle', ['$rootScope', '$timeout', '$transitions',
	($rootScope, $timeout, $transitions)->
			link: (scope, element)->

				$transitions.onSuccess({}, (transition)->

					title = 'Wissen'
					if transition.to().data and transition.to().data.pageTitle
						title = transition.to().data.pageTitle

					if transition.to().Params
						if transition.to().Params.username
							title = transition.to().Params.username + ' - Wissen'

					$timeout(()->
						element.text(title)
					, 0, false)
				);


])
