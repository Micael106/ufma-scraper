require 'selenium-webdriver'
require 'sanitize'
require 'open-uri'
require 'json'

class Pesquisa

	def initialize ano
		@ano = ano
		@count = 0
	end
	
	def pesquisar
		@browser = Selenium::WebDriver.for :firefox #(:remote, :url => "http://localhost:9515")
		@browser.get("https://sigaa.ufma.br/sigaa/public/biblioteca/buscaPublicaAcervo.jsf")

		# Procura pelo input 'Ano de publicação de' e 'ate'
		#@browser.find_element(:css, '#formBuscaPublica\:checkAnoPublicacao').click
		@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(3) > input[type="text"]').send_keys(@ano)
		@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(5) > input[type="text"]').send_keys(@ano)

		select_order = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisa > tbody:nth-child(2) > tr:nth-child(7) > td:nth-child(3) > select:nth-child(1)'))
		select_order.select_by(:text, "Mais Emprestados")

		# Seleciona 100 para 'Registro por página'
		select_rp = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(8) > td:nth-child(3) > select'))
		select_rp.select_by(:text, "100")

		# Seleciona BC - Biblioteca Central
		#@browser.find_element(:css, '#formBuscaPublica\:checkBiblioteca').click
		select_bc = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(1) > td:nth-child(3) > select'))
		select_bc.select_by(:text, "BC - BIBLIOTECA CENTRAL")

		#Seleciona input Coleção
		#@browser.find_element(:css, '#formBuscaPublica\:checkColecao').click
		select_col = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(2) > td:nth-child(3) > select'))
		select_col.select_by(:text, "CIRC - Acervo Circulante")
		
		#Seleciona select Tipo de materail
		#@browser.find_element(:css, '#formBuscaPublica\:checkTipoMaterial').click
		select_tipo_material = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody:nth-child(1) > tr:nth-child(3) > td:nth-child(3) > select:nth-child(1)'))
		select_tipo_material.select_by(:text, "Livro")

		# Clica no botão 'Pesquisar' e em 'Detalhes' (lupa)
		@browser.find_element(:css, '#formBuscaPublica\3a botaoPesquisarPublicaMulti').click
		@browser.find_element(:css, '#formBuscaPublica\3a ClinkView').click
	end
	
	# Instancia as variáveis principais e inicia a primeira iteração para a captura e finaliza caso não haja mais livros.
	def scraping
		@path_prox_livro = '#formDetalhesMateriaisPublico\3a navegaProximoEnabled' # Seletor para carregar próxima página
		@id = 1 # Posição da linha da tabela <tr> dos atributos

		loop do
			@livro = []
			captura_atributo
			break unless path_existe? @path_prox_livro
			@browser.find_element(:css, @path_prox_livro).click # Próxima página
		end
	end

	# Inicia a segunda iteração dentro da primeira em scraping capturando todos os atributos da tabela HTML.
	def captura_atributo
		loop do
			@path_th = '#formDetalhesMateriaisPublico > table:nth-child(14) > tbody > tr:nth-child(' + "#{@id}" + ') > th' # Seletor para título do atributo
			@path_td = '#formDetalhesMateriaisPublico > table:nth-child(14) > tbody > tr:nth-child(' + "#{@id}" + ') > td' # Seletor para valor do atributo
			break unless path_existe? @path_th
			@livro << [Sanitize.fragment(@browser.find_element(:css, @path_th).attribute("innerHTML")), Sanitize.fragment(@browser.find_element(:css, @path_td).attribute("innerHTML"))]
			@id += 1
		end
		@id = 1
		formata_dados @livro
	end

	# Verifica se um determinado seletor existe na página
	def path_existe? path
		begin
			@browser.find_element(:css, path)
		rescue Selenium::WebDriver::Error::NoSuchElementError
			false
		else
			true
		end
	end

	def salva_livro book
		File.open("#{@ano}_livros.json", "a+") do |f|
  			f.puts("#{book}")
  			@count += 1
		end
	end

	def formata_dados livro
		livro.each{|tupla| tupla.each{|k,v| k.gsub!(":","") }} # Remove ':' do título dos atriutos.
		livro.each{|tupla| tupla.each{|k,v| k.gsub!(/^\s|\s$/, "") }} # Remove espaço em branco de snecessário das chaves.
		@books = Hash[livro].to_json # Transforma o array 'livro' em hash e transforma-o em json.
		@books.gsub!("\\n", "")
		@books.gsub!("\\t", "")
		@books.gsub!('\"', "")
		puts @books
		@books.gsub!(/(?<=[a-z])(?=[A-Z])/, ",") # Adiciona vírgula entre os valores de atributos multivalorados.
		@books.gsub!("b,T", "bT") # Remove vírgula desnecessária.
		salva_livro @books
	end

end

puts "Sistema de Scraping de dados da Biblioteca SIGAA UFMA"
print "Digite o ano inicial: "
ano = gets.chomp.to_i

#while ano >= (ano-20)
	search = Pesquisa.new ano
	puts "Inicializando..."
	search.pesquisar
	puts "OK. Realizando scraping na página dos resultados do ano #{ano}..."
	search.scraping
	puts "Scraping realizado com sucesso."
	#ano -= 1
#end