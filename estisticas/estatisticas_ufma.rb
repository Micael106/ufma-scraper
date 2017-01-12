class EstatisticasUFMA
	require 'csv'
	require 'json'
	require 'open-uri'
	require 'gchart'

	def initialize
		@url = 'https://dados-abertos-ufma.herokuapp.com/api/v01'
	end

	def discentes_por_curso
		dados_cursos = JSON.parse(open(@url + '/cursos').read)['data']
		#dados = JSON.parse open(@url + '/discentes').read
		estatisticas = []
		#g = dados['data'].group_by do |d|
		#	d['curso_id']
		#end
		#File.open('discentes_por_curso.json', 'w'){ |f| f.puts JSON.pretty_generate g }
		discentes_agrupados = JSON.parse File.read('discentes_por_curso.json')
		discentes_agrupados.each do |curso_id, agrupamento|
			estatisticas << [
				dados_cursos.select { |curso| curso["_id"] == curso_id }.first['nome'],
				agrupamento.count ]
		end
		puts estatisticas
		estatisticas.each do |curso|
			File.open('est_discentes_por_curso.csv','a+'){ |f| f.puts(curso.join(',')) }
		end
		cursos = CSV.read('est_discentes_por_curso.csv').to_a
		cursos.sort_by!{ |curso| curso.last.to_i }
		CSV.open('top_10_cursos_mais_discentes.csv','w'){ |f| cursos.each { |curso| f << curso } }
	end

	def docentes_por_subunidade
		dados_docentes = JSON.parse File.read(ENV['HOME'] + '/projects/ufma-scraper/docentes/docentes.json')
		estatisticas = []
		dados_docentes.group_by { |docente| docente['departamento'] }.each do |subunidade, docentes|
			estatisticas << [
				subunidade,
				docentes.count
			]
		end
		estatisticas.sort_by! { |estatistica| estatistica.last }.reverse!
		File.open('top_10_subunidades_mais_docentes.csv', 'w') { |f| estatisticas.each { |est| f.puts est.to_csv } }
		return estatisticas.first(10)
	end

	def professores_

	end
end

EstatisticasUFMA.new.docentes_por_subunidade