require 'net/http'
require 'json'
require 'open-uri'

@token = '27a714e1b5de5aae0320' # Token para autorizar a requição POST
=begin
@uri_cursos = URI('https://dados-abertos-ufma.herokuapp.com/api/v01/cursos')
req = Net::HTTP::Post.new(@uri_cursos, 'Content-Type' => 'application/json')
req.body = {cursos: File.read('cursos/cursos.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_cursos.hostname, @uri_cursos.port)
res.use_ssl = true
res.request(req)
puts res

@uri_discentes = URI('https://dados-abertos-ufma.herokuapp.com/api/v01/discentes')
req = Net::HTTP::Post.new(@uri_discentes, 'Content-Type' => 'application/json')
req.body = {discentes: File.read('cursos/alunos_ativos.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_discentes.hostname, @uri_discentes.port)
res.use_ssl = true
res.request(req)
puts res

@uri_docentes = URI('http://dados-abertos-ufma.herokuapp.com/api/v01/docentes')
req = Net::HTTP::Post.new(@uri_docentes, 'Content-Type' => 'application/json')
req.body = {docentes: File.read('docentes.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_docentes.hostname, @uri_docentes.port)
#res.use_ssl = true
res.request(req)
puts res

@uri_turmas = URI('https://dados-abertos-ufma.herokuapp.com/api/v01/turmas')
req = Net::HTTP::Post.new(@uri_turmas, 'Content-Type': 'application/json')
req.body = {turmas: File.read('turmas/turmas.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_turmas.hostname, @uri_turmas.port)
res.use_ssl = true
res.request(req)
puts res
=end
@uri_unidades = URI('https://dados-abertos-ufma.herokuapp.com/api/v01/unidades')
req = Net::HTTP::Post.new(@uri_unidades, 'Content-Type': 'application/json')
req.body = {unidades: File.read('unidades/unidades.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_unidades.hostname, @uri_unidades.port)
res.use_ssl = true
res.request(req)
puts res
