require 'pg'

def conn id
	begin
		conn = PG::Connection.open(dbname: 'biblioteca', user: 'postgres', password: 'OlaMundodePijama2121')
		query = conn.exec "SELECT livro->>'Registro no Sistema' as rg FROM livros WHERE id"
		query.each do |row|
			puts row['rg']
		end
	rescue PG::Error => e
		e.message
	ensure
		conn.close if conn
	end
end

count = 1
while count <= 2
	conn count
	count += 1
end