# Este é um script para scraping de dados
# do sistema de busca de livros da biblioteca da UFMA
# operada pelo SIGAA publico.
#
# Autor:: Micael Lopes

require 'selenium-webdriver'
require 'sanitize'
require 'open-uri'
require 'json'
require 'pg'

class Pesquisa

	def initialize ano_inicial
		@ano_inicial = ano_inicial
		@count = 0
		#chromedriver_path = File.join(File.absolute_path('C:\Users\Micael Lopes\Documents\Scraping', File.dirname(__FILE__)),"browsers","chromedriver.exe")
		#Selenium::WebDriver::Chrome.driver_path = chromedriver_path
	end
	
	# Inicializa o scraping com através da simulação de um usuário no
	# Selenium Webdriver no navegador Firefox e clicando no botão 
	# "Pesquisar".
	def pesquisar
		@browser = Selenium::WebDriver.for :firefox
		@browser.get("https://sigaa.ufma.br/sigaa/public/biblioteca/buscaPublicaAcervo.jsf")

		# Procura pelo input 'Ano de publicação de' e 'ate'
		#@browser.find_element(:css, '#formBuscaPublica\:checkAnoPublicacao').click
		@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(3) > input[type="text"]').send_keys(@ano_inicial)
		@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(5) > input[type="text"]').send_keys(String(Time.now.year))

		select_order = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisa > tbody:nth-child(2) > tr:nth-child(7) > td:nth-child(3) > select:nth-child(1)'))
		select_order.select_by(:text, "Mais Emprestados")

		# Seleciona 100 para 'Registro por página'
		#select_rp = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(8) > td:nth-child(3) > select'))
		#select_rp.select_by(:text, "100")

		# Seleciona BC - Biblioteca Central
		#@browser.find_element(:css, '#formBuscaPublica\:checkBiblioteca').click
		select_bc = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(1) > td:nth-child(3) > select'))
		select_bc.select_by(:text, "BC - BIBLIOTECA CENTRAL")

		#Seleciona input Coleção
		#@browser.find_element(:css, '#formBuscaPublica\:checkColecao').click
		select_col = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(2) > td:nth-child(3) > select'))
		select_col.select_by(:text, "PER - Periódicos")
		
		#Seleciona select Tipo de material
		#@browser.find_element(:css, '#formBuscaPublica\:checkTipoMaterial').click
		select_tipo_material = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody:nth-child(1) > tr:nth-child(3) > td:nth-child(3) > select:nth-child(1)'))
		select_tipo_material.select_by(:text, "Periódico")

		# Clica no botão 'Pesquisar' e em 'Detalhes' (lupa)
		@browser.find_element(:css, '#formBuscaPublica\3a botaoPesquisarPublicaMulti').click
		@browser.find_element(:css, '#formBuscaPublica\3a ClinkView').click
	end
	
	# Instancia as variáveis principais e inicia a primeira iteração para a captura; finaliza caso não haja mais livros.
	def scraping
		@path_prox_livro = '#formDetalhesMateriaisPublico\3a navegaProximoEnabled' # Seletor para carregar próxima página
		@id = 1 # Posição da linha da tabela <tr> dos atributos

		loop do
			@livro = []
			captura_atributo
			break unless path_existe? @path_prox_livro
			@browser.find_element(:css, @path_prox_livro).click # Próxima página
		end
		@browser.quit
	end

	# Inicia a segunda iteração dentro da primeira capturando todos os atributos da tabela HTML.
	def captura_atributo
		loop do
			@path_th = '#formDetalhesMateriaisPublico > table:nth-child(14) > tbody > tr:nth-child(' + "#{@id}" + ') > th' # Seletor para título do atributo
			@path_td = '#formDetalhesMateriaisPublico > table:nth-child(14) > tbody > tr:nth-child(' + "#{@id}" + ') > td' # Seletor para valor do atributo
			
			break unless( path_existe?(@path_th) && num_chamada_existe?(@path_th, @path_td) ) # Pára quando não encontrar mais chaves de atributos na coluna da tabela
			
			@livro << [Sanitize.fragment(@browser.find_element(:css, @path_th).attribute("innerHTML").strip!),
					   Sanitize.fragment(@browser.find_element(:css, @path_td).attribute("innerHTML").strip!)]
			@id += 1
		end
		@id = 1
		formata_dados @livro
	end

	# Verifica se um determinado seletor existe na página.
	def path_existe? path
		begin
			@browser.find_element(:css, path)
		rescue Selenium::WebDriver::Error::NoSuchElementError
			false
		else
			true
		end
	end

	# Verifica se o atributo 'Número de chamada' está vazio
	def num_chamada_existe? (path_th, path_td)
		if Sanitize.fragment( @browser.find_element(:css, path_th).attribute("innerHTML") ).include?("Número de Chamada")
			puts @browser.find_element(:css, path_th).attribute("innerHTML").include? "Número de Chamada"
			@browser.find_element(:css, path_td).attribute("innerHTML").strip.empty? ? false : true
		else
			true
		end
	end

	# Armazena o livro capturado já estruturado em um arquivo de texto JSON.
	def store_file book
		File.open("#{@ano_inicial}_#{Time.now.year}_livros.json", "a+") do |f|
  			f.puts "#{book}" + ","
  			@count += 1
		end
	end

	# Faz a conexão com o banco de dados (PGSQL) e armazena o dado como não relacional (JSONB)
	def store_database book
		begin
			conexao = PG::Connection.open(:dbname => 'biblioteca', :user => 'postgres', :password => '6102')
			conexao.exec "INSERT INTO Livros(livro) VALUES($$#{book}$$)"
		rescue PG::Error => e
			puts e.message
			#conexao.exec "DELETE FROM Livros WHERE id = #{posicao}"
		ensure
			conexao.close if conexao
		end
	end

	# Faz a formatação dos dados capturados.
	def formata_dados livro
		livro.each do |k,v|
			k.gsub!(':','')		# Remove ':' do título dos atributos. tupla.each{|k| k
			k.gsub!(/^\s|\s$/, '')	# Remove espaço em branco de desnecessário das chaves.
			v.gsub!(/^\s|\s$/, '')  # Remove espaço em branco de desnecessário das atributos.
			v.gsub!('.', '') if k == "Ano Publicação"	# Remove "." desnecessário do campo "Ano Publicação".
			v.strip! # Remove whitespaces desnecessários.
		end

		@book = Hash[livro]
		@book.each do |k,v|
			v.gsub!("\n", "")
			v.gsub!("\t", "")
			v.gsub!("\"", "")
			v.gsub!(/(?<=[a-z])(?=[A-Z])/, ",") # Adiciona vírgula entre os valores de atributos multivalorados.
			v.gsub!("b,T", "bT") # Remove vírgula desnecessária em "SubTítulo" gerada anteriormente.
			@book[k] = v.split(/\b,\b/) if (k == "Autores Secundários" || k == "Assunto") # Gera um array de valores.
		end

		@book_json = @book.to_json
		store_database @book_json
		#store_file @book_json
	end
end

puts "Sistema de Scraping de dados da Biblioteca SIGAA UFMA"
print "Digite o ano inicial: "
ano_inicial = gets.chomp.to_i

File.open("#{ano_inicial}_#{Time.now.year}_livros.json", "a+") do |f|
	f.puts '['
end

search = Pesquisa.new ano_inicial
puts "Inicializando..."
search.pesquisar
puts "OK. Realizando scraping na página dos resultados a partir de #{ano_inicial} até #{Time.now.year}..."
search.scraping
puts "Scraping realizado com sucesso."

File.open("#{ano_inicial}_#{Time.now.year}_livros.json", "a+") do |f|
	f.puts ']'
end