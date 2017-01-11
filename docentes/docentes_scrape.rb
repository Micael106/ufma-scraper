class DocentesScrape
	require '~/Documentos/Scraping/lib/adapters'
	require 'nokogiri'
	require 'net/http'
	require 'i18n'
	require 'json'
	require 'csv'

	def initialize
		@docente = []
		@producao_intelectual = []
		@siapes = CSV.read('codigos_siape.csv').flatten
		@docentes = @siapes.map{ |siape| {siape: siape, url_portal: LinkAdapter::Docente::portal(siape), url_pi: LinkAdapter::Docente::producao_intelectual(siape)} }
		@docentes.each do |docente|
			@portal_docente = Nokogiri::HTML(Net::HTTP.get(URI(docente[:url_portal])))
			#@pi_docente = Nokogiri::HTML(Net::HTTP.get(URI(docente[:url_pi])))
			topicos(docente[:url_portal], doente[:siape])
			#producao_intelectual(docente[:siape])
		end
		salva_infile()
	end

	def topicos url_portal, siape
		@docente << {
			'siape': siape
			'nome': @portal_docente.xpath(SelectorAdapter::Docente::nome).text.strip,
			'descricao': @portal_docente.xpath(SelectorAdapter::Docente::descricao).text.strip,
			'formacao_academica': @portal_docente.xpath(SelectorAdapter::Docente::formacao_academica).text.strip,
			'areas_de_interesse': @portal_docente.xpath(SelectorAdapter::Docente::areas_de_interesse).text.strip,
			'departamento': @portal_docente.xpath(SelectorAdapter::Docente::departamento).text.strip,
			'url_lattes': @portal_docente.css(SelectorAdapter::Docente::url_lattes).text.strip,
			'url_sigaa': url_portal
		}
		
	end

	def producao_intelectual siape
		producao = []
		@pi_docente.css(SelectorAdapter::Docente::producao_intelectual).each do |pi|
			producao << pi.text.strip.split(',').each{ |attr| attr.strip! }
		end
		@producao_intelectual << {
			'producao_intelectual': producao,
			'siape_docente': siape,
			'nome_docente': @portal_docente.xpath(SelectorAdapter::Docente::nome).text.strip
		}
	end

	def salva_infile
		File.open('docentes.json', 'a+'){ |f| f.puts JSON.pretty_generate(@docente) }
	end
end

DocentesScrape.new