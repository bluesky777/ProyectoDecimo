angular.module('WissenSystem')

.filter('clearhtml', ()->
	(text)->
		return if text then String(text).replace(/<[^>]+>/gm, '') else ''

)