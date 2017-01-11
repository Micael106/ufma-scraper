module SelectorAdapter
	def self.btn_consultar
		'#form\3a consultarCursos'
	end

	def self.linha_par
		'.linhaPar'
	end

	def self.linha_impar
		'.linhaImpar'
	end

	def self.curso_link
		'td:nth-child(5) > a'
	end

	def self.nome_curso
		'#nomes > span.nome_curso > a'
	end

	def self.apresentacao
		'#esquerda > div.texto > p'
	end

	def self.coordenador
		'#esquerda > span:nth-child(3) > strong > a'
	end

	def self.topico
		'.topico'
	end

	def self.matricula_aluno
		'#table_lt > tbody > tr:nth-child(2) > td:nth-child(1)'
	end

	def self.nome_aluno
		'#table_lt > tbody > tr:nth-child(2) > td:nth-child(2)'
	end

	def self.documentos
		'.cor'
	end

	# Docentes
	module Docente
		def self.nome
			'//*[@id="left"]/h3[1]'
		end

		def self.descricao
			'//*[@id="perfil-docente"]/dl[1]/dd/text()'
		end

		def self.formacao_academica
			'//*[@id="perfil-docente"]/dl[2]/dd/text()'
		end

		def self.areas_de_interesse
			'//*[@id="perfil-docente"]/dl[3]/dd/text()'
		end

		def self.url_lattes
			'#endereco-lattes'
		end

		def self.departamento
			'//*[@id="left"]/h3[2]'
		end

		def self.producao_intelectual
			'#producao-docente > ul > li'
		end
	end

end

module LinkAdapter

	# Cursos e Discentes
	def self.pagina_inicial
		'https://sigaa.ufma.br/sigaa/public/curso/lista.jsf?nivel=G&aba=p-graduacao'
	end

	def self.alunos_ativos(curso_id)
		"https://sigaa.ufma.br/sigaa/public/curso/alunos.jsf?id=#{curso_id}"
	end

	def self.monografias(curso_id)
		"https://sigaa.ufma.br/sigaa/public/curso/monografias.jsf?id=#{curso_id}"
	end

	# Docentes
	module Docente
		def self.portal(siape)
			"https://sigaa.ufma.br/sigaa/public/docente/portal.jsf?siape=#{siape}"
		end

		def self.producao_intelectual(siape)
			"https://sigaa.ufma.br/sigaa/public/docente/producao.jsf?siape=#{siape}"
		end
	end
end