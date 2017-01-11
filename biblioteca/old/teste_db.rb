require 'pg'

begin
	conexao = PG::Connection.open(:dbname => 'biblioteca', :user => 'postgres', :password => '123')

	livro = %q({"Registro no Sistema":"4172","Número de Chamada":"C737E","Título":"La e'volucion intelectual y moral del nino ","Assunto":"Psicologia infantil","Autor":"COMPAYRE, Gabriel","Local da Publicação":"MADRIDDANIEL JORRO","Editora":"MADRIDDANIEL JORRO","Ano Publicação":"1920"})

	conexao.exec "INSERT INTO Teste(nomes) VALUES ($$#{livro}$$)"
rescue PG::Error => e
	puts e.message
ensure
	conexao.close if conexao
end