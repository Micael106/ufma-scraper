require 'selenium-webdriver'

browser = Selenium::WebDriver.for(:firefox)
browser.get("https://sigaa.ufma.br/sigaa/public/biblioteca/buscaPublicaAcervo.jsf")

# Procura pelo input 'Ano de publicação de'
browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(3) > input[type="text"]').send_keys(1900)

# Procura pelo input 'Ano de publicação até'
browser.find_element(:css, '#tableDadosPesquisa > tbody > tr:nth-child(6) > td:nth-child(5) > input[type="text"]').send_keys(1970)

# Seleciona 100 para 'Registro por página'

# Seleciona input Biblioteca
#browser.find_element(:css, '//[@id="formBuscaPublica:checkBiblioteca"]').click

# Seleciona BC - Biblioteca Central
select_bc = Selenium::WebDriver::Support::Select.new(browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(1) > td:nth-child(3) > select'))
select_bc.select_by(:text, "BC - BIBLIOTECA CENTRAL")

#Seleciona input Coleção
select_per = Selenium::WebDriver::Support::Select.new(browser.find_element(:css, '#tableDadosPesquisaInterna > tbody > tr:nth-child(2) > td:nth-child(3) > select'))
select_per.select_by(:text, "PER - Periódicos")

# Clica no botão 'Pesquisar'
pesquisar = browser.find_element(:css, '#formBuscaPublica\3a botaoPesquisarPublicaMulti')
pesquisar.click

puts "Okay"