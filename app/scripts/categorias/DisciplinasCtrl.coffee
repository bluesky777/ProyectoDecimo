angular.module('WissenSystem')

.controller('DisciplinasCtrl', ['$scope', 'Restangular',  ($scope, Restangular)->


	$scope.idiomasDiscEdit = [$scope.idiomaPreg]



	$scope.disciplinas_king = [
		{
			id: 1
			nombre: 'Matemáticas'
			disciplinas_traducidas: [
				{
					nombre: 'Matemáticas'
					idioma_id: 1
					idioma: 'Español'
					disciplina_id: 1
					descripcion: 'Matemáticas'
					traducido: false
				},
				{
					nombre: 'Math'
					idioma_id: 2
					idioma: 'English'
					disciplina_id: 1
					descripcion: 'Math'
					traducido: true
				}
			]
		},
		{
			id: 2
			nombre: 'Sociales'
			disciplinas_traducidas: [
				{
					nombre: 'Sociales'
					idioma_id: 1
					idioma: 'Español'
					disciplina_id: 2
					descripcion: 'Sociales'
					traducido: false
				},
				{
					nombre: 'Geografy'
					idioma_id: 2
					idioma: 'English'
					disciplina_id: 2
					descripcion: 'Geografy'
					traducido: true
				}
			]
		}
	]


	$scope.editarDisciplina = (disciplina)->
		disciplina.editando = true

	$scope.eliminarDisciplina = (disciplina)->
		#disciplina.editando = true

	$scope.finalizar_edicion = (disciplina)->
		disciplina.editando = false


])

