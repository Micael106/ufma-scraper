class TurmasScrape
	require 'open-uri'
	require 'csv'
	require 'json'

	def initialize
		c = 0
		@turmas = []
		@url_portal = 'https://script.google.com/macros/s/AKfycbxjYbgBYlXU6-wGKXTcb58p52VKEoFqYsIeZ7rp4YhM5GhIafcU/exec?siape='
		@siapes = CSV.read('codigos_siape.csv').flatten
		@siapes.each do |siape|
			turma = JSON.parse(open(@url_portal + siape).read)
			turma.map { |turma| turma.merge!(siape_docente: siape) }
			@turmas << turma.flatten
			c += 1
			puts "#{(c/Float(@siapes.count)).round(2)*100}% "
		end
		File.open('turmas.json', 'a+') { |f| f.puts JSON.pretty_generate(@turmas.flatten) }
	end


end

TurmasScrape.new