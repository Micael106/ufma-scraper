class UnidadesScraper
	require 'open-uri'
	require 'json'
	require '~/Documentos/ufma-scraper/lib/adapters.rb'
	require 'nokogiri'

	def initialize
		@unidades = []
		@url_ufma = LinkAdapter::Unidade.lista
		@url_portal = LinkAdapter::Unidade.portal
		coleta_metadados
	end

	def coleta_metadados
		lista = Nokogiri::HTML open @url_ufma
		lista.css(SelectorAdapter::Unidade.div_wrapper).each do |u|
			begin 
				@unidade = {}
				@unidade["sigla"] = u.xpath(SelectorAdapter::Unidade.sigla).text.strip
				@unidade["nome"] = u.css(SelectorAdapter::Unidade.nome).text.strip
				@unidade["url_sigaa"] = u.css(SelectorAdapter::Unidade.url_sigaa).first["href"]
				portal = Nokogiri::HTML open(@unidade["url_sigaa"])
				@unidade["apresentacao"] = portal.xpath(SelectorAdapter::Unidade.apresentacao).text.strip
				@unidade["diretor"] = portal.xpath(SelectorAdapter::Unidade.nome_diretor).text.strip
				@unidade["siape_diretor"] = /\b\d+/.match(portal.xpath(SelectorAdapter::Unidade.nome_diretor).first["href"]).to_s.strip
			rescue NoMethodError => e
				puts e
				next
			ensure
				@unidades << @unidade
			end
		end
		File.open('unidades', 'w'){|f| f.puts JSON.pretty_generate(@unidades)}
	end
end

UnidadesScraper.new