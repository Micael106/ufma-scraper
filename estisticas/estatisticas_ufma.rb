class EstatisticasUFMA
	require 'json'
	require 'open-uri'

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
				dados_cursos.select{ |curso| curso["_id"] == curso_id }.first['nome'],
				agrupamento.count ]
		end
		puts estatisticas
		estatisticas.each do |curso|
			File.open('est_discentes_por_curso.csv','a+'){ |f| f.puts(curso.join(',')) }
		end
	end
end

EstatisticasUFMA.new.discentes_por_curso