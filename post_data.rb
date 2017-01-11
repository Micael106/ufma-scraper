require 'net/http'
require 'json'
require 'open-uri'

@token = 'c5e6c651eb24a6ad591d' #'fbde858473fe5956cf6b' Token para autorizar a requição POST
=begin
@uri_cursos = URI('https://dados-abertos-ufma.herokuapp.com/api/v1/cursos') #URI('https://dados-abertos-ufma.herokuapp.com/api/v1/cursos')
@uri_discentes = URI('https://dados-abertos-ufma.herokuapp.com/api/v1/discentes')

req = Net::HTTP::Post.new(@uri_cursos, 'Content-Type' => 'application/json')
req.body = {cursos: File.read('cursos/cursos.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_cursos.hostname, @uri_cursos.port)
res.use_ssl = true
res.request(req)
puts res

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
=end
@uri_turmas = URI('https://dados-abertos-ufma.herokuapp.com/api/v01/turmas')
req = Net::HTTP::Post.new(@uri_turmas, 'Content-Type': 'application/json')
req.body = {turmas: File.read('turmas/turmas.json'), token: @token}.to_json
res = Net::HTTP.new(@uri_turmas.hostname, @uri_turmas.port)
res.use_ssl = true
res.request(req)
puts res