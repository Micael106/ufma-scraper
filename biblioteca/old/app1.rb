require 'io/console'

livros = []

livros = IO.readlines("resultado_pesquisa_ABNT.txt").each_with_index.map do |line, line_num|
	[line_num, line]
end

dado = 0
bruto = []
while dado < livros.length
	bruto[dado] = livros[dado][1].split(".")
	dado += 1
end

periodico = ["autor", "titulo", "local", "qtd", "ISBN"]
i = 0
separado = []
while i < bruto.length
	separado[i] = Hash[periodico.zip(bruto[i].map { |value| value.split /, / })]
	i += 1
end

puts "#{separado[1]}"