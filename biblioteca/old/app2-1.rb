require 'selenium-webdriver'
require 'open-uri'

class Pesquisa

	def initialize (de, ate)
		@de = de
		@ate = ate
	end
	
	def pesquisar
		@browser = Selenium::WebDriver.for :firefox
		@browser.get("https://sigaa.ufma.br/sigaa/public/biblioteca/buscaPublicaAcervo.jsf")

		# Procura pelo input 'Ano de publicação de'
		@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(3) > input[type="text"]').send_keys(@de)

		# Procura pelo input 'Ano de publicação até'
		@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(5) > input[type="text"]').send_keys(@ate)

		# Seleciona 100 para 'Registro por página'
		select_rp = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(8) > td:nth-child(3) > select'))
		select_rp.select_by(:text, "100")

		# Seleciona BC - Biblioteca Central
		select_bc = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(1) > td:nth-child(3) > select'))
		select_bc.select_by(:text, "BC - BIBLIOTECA CENTRAL")

		#Seleciona input Coleção
		select_col = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(2) > td:nth-child(3) > select'))
		select_col.select_by(:text, "PER - Periódicos")
		
		# Clica no botão 'Pesquisar' e em 'Detalhes' (lupa)
		@browser.find_element(:css, '#formBuscaPublica\3a botaoPesquisarPublicaMulti').click
		@browser.find_element(:css, '#formBuscaPublica\3a ClinkView').click
	end
	
	def scraping
		@qtd = 0
		@table = Array.new
		@table[@qtd] = @browser.find_element(:css, '#formDetalhesMateriaisPublico > table:nth-child(14) > tbody').text
		while (find)
			@browser.find_element(:css, '#formDetalhesMateriaisPublico\3a navegaProximoEnabled').click
			@qtd += 1
			@table[@qtd] = @browser.find_element(:css, '#formDetalhesMateriaisPublico > table:nth-child(14) > tbody').text
			puts "#{@table[@qtd]}"
		end
		
		File.open("periodicos.txt", "w+") do |f|
  			f.puts(@table)
		end
	end

	#Verifica se o botão navegaProximoEnable ainda está presente
	def find
		begin
			@browser.find_element(:css, '#formDetalhesMateriaisPublico\3a navegaProximoEnabled')
		rescue(Selenium::WebDriver::Error::NoSuchElementError)
			return false
		else
			return true
		end
	end
		
end

print "Digite o ano inicial: "
year_start = gets.to_i

print "Digite o ano final: "
year_end = gets.to_i

search = Pesquisa.new(year_start, year_end)
puts "Aguarde, estamos iniciando sua solicitação no navegador Firefox..."
search.pesquisar
puts "Feito. Realizando scraping na página dos resultados entre #{year_start} e #{year_end}..."
search.scraping
puts "Scraping realizado com sucesso."
