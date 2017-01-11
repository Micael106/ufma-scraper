require 'selenium-webdriver'

print "Digite seu login: "
login = gets
puts "Digite sua senha: "
senha = gets

browser = Selenium::WebDriver.for :firefox
browser.get('https://sigaa.ufma.br/sigaa/verTelaLogin.do')

# fazer login
browser.find_element(:css, '#conteudo > div.logon > form > table > tbody > tr:nth-child(1) > td > input[type="text"]').send_keys(login)
browser.find_element(:css, '#conteudo > div.logon > form > table > tbody > tr:nth-child(2) > td > input[type="password"]').send_keys(senha)
