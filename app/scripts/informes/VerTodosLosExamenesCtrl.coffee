'use strict'

angular.module('WissenSystem')

# Este archivo lo estoy compartiendo con el estado ver_todos_los_examenes_por_entidades y ver_todos_los_examenes
.controller('VerTodosLosExamenesCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'examenes',
	($scope, Restangular, toastr, $filter, $uibModal, App, examenes) ->

		$scope.examenes     = examenes
		$scope.sortReverse  = true;
		#$scope.$parent.examenes = examenes


		$scope.eliminarExamen = (examen)->
			modalInstance = $uibModal.open({
				templateUrl: App.views + 'informes/seguroEliminExam.tpl.html'
				controller: 'SeguroEliminExamCtrl'
				resolve:
					examen: ()->
						examen
			})
			modalInstance.result.then( (r)->
				toastr.success 'Examen de ' + examen.nombres + ' ' + examen.apellidos + ' eliminado.'

				examen_id 				= if r.rowid then r.rowid else r.id
				$scope.examenes 	= $filter('filter')($scope.examenes, {examen_id: '!'+ examen_id})

			)



	]
)

.controller('VerTodosLosExamenesPorEntCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$uibModal', 'App', 'entidades',
	($scope, Restangular, toastr, $filter, $uibModal, App, entidades) ->

		$scope.entidades = entidades
		$scope.$parent.entidades = entidades
		$scope.sortReverse  = true;

	]
)


