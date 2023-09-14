/* ********************************************************************************************
 * DETECTANDO DUPLICIDADES: TÉCNICAS PARA VISUALIZAR LINHAS QUE POSSUEM REGISTROS DUPLICADOS **
 * ********************************************************************************************/

/* DETECTANDO DUPLICIDADES - UMA MANEIRA É INSPECIONAR UMA AMOSTRA, COM TODAS AS COLUNAS ORDENADAS */
SELECT
	t.nomeDepartamento,
	t.numeroDepartamento,
	t.matriculaGerente,
	t.dataCriacaoDepartamento,
	t.dataInicioGerente
FROM
	tbdepartamento t
ORDER BY
	1,
	2,
	3,
	4,
	5;

/* OUTRA MANEIRA MAIS EFICAZ É SELECIONANDOS AS COLUNAS E DEPOIS CONTAR AS LINHAS */
SELECT
	count(*) AS qtdDuplicados
FROM
	(
		SELECT
			t.nomeDepartamento,
			t.numeroDepartamento,
			t.matriculaGerente,
			t.dataCriacaoDepartamento,
			t.dataInicioGerente,
			count(*) AS contagem
		FROM
			tbdepartamento t
		GROUP BY
			1,
			2,
			3,
			4,
			5
	) AS a
WHERE
	contagem > 1;

/* PARA VERIFICAR MAIS DETALHES, É POSSIVEL AINDA LISTAR O NUMERO DE REGISTROS */
SELECT
	contagem,
	count(*) AS qtdDuplicados
FROM
	(
		SELECT
			t.nomeDepartamento,
			t.numeroDepartamento,
			t.matriculaGerente,
			t.dataCriacaoDepartamento,
			t.dataInicioGerente,
			count(*) AS contagem
		FROM
			tbdepartamento t
		GROUP BY
			1,
			2,
			3,
			4,
			5
	) AS a
WHERE
	contagem > 1
GROUP BY
	1;

/* COMO ALTERNATIVA PARA UMA SUBCONSULTA, É POSSÍVEL UTILIZAR A CLAUSULA HAVING E MANTER TUDO EM UMA UNICA CONSULTA */
SELECT
	t.nomeDepartamento,
	t.numeroDepartamento,
	t.matriculaGerente,
	t.dataCriacaoDepartamento,
	t.dataInicioGerente,
	count(*) AS contagem
FROM
	tbdepartamento t
GROUP BY
	1,
	2,
	3,
	4,
	5
HAVING
	count(*) > 1;

/* PARA VISUALIZAR OS DETALHES COMPLETOS DOS REGISTROS, É POSSÍVEL LISTAR TODOS OS CAMPOS E EM SEGUIDA DETECTAR QUAIS REGISTROS POSSUEM PROBLEMAS */
SELECT
	*
FROM
	(
		SELECT
			t.nomeDepartamento,
			t.numeroDepartamento,
			t.matriculaGerente,
			t.dataCriacaoDepartamento,
			t.dataInicioGerente,
			count(*) AS contagem
		FROM
			tbdepartamento t
		GROUP BY
			1,
			2,
			3,
			4,
			5
	) AS a
WHERE
	contagem = 2;

/* ***********************************************************************************************
 * DESDUPLICAÇÃO COM GROUP BY E DISTINCT - AS VEZES TEMOS DADOS DUPLICADOS E QUE NÃO QUER DIZER  *
 * QUE OS DADOS SÃO RUINS. POR EXEMPLO, IMAGINA QUE QUEREMOS ENVIAR UM E-MAIL PARA UM CLIENTE    *    
 * TEVE VENDAS CONCRETIZADAS. NESSE CASO PODE OCORRER CLIENTES QUE FIZERAM MAIS DE UMA COMPRA,   *
 * POR ISSO SEU REGISTRO APARECE MAIS DE UMA VEZ EM UMA MESMA CONSULTA. PARA ESSE CENÁRIO 		 *
 * VAMOS UTILIZAR A DESDUPLICAÇÃO, E TRAZER APENAS OS REGISTROS UNICOS.							 *
 * ***********************************************************************************************/

/* NESSE CENÁRIO, TEMOS FUNCIONARIOS QUE FAZEM PARTE DE MAIS DE UM PROJETO */
SELECT
	t2.matriculaFuncionario,
	concat(t3.nomeFuncionario, ' ', t3.sobrenomeFuncionar) AS nome
FROM
	tbprojeto t
	INNER JOIN tbfuncionarioprojeto t2 ON t.numeroProjeto = t2.numeroProjeto
	INNER JOIN tbfuncionario t3 ON t2.matriculaFuncionario = t2.matriculaFuncionario
WHERE
	t3.matriculaFuncionario = t2.matriculaFuncionario;

/* NESSE CENÁRIO, QUEREMOS APENAS OS FUNCIONARIOS QUE ESTÃO EM AO MENOS UM PROJETO */
SELECT
	DISTINCT t3.matriculaFuncionario,
	concat(t3.nomeFuncionario, ' ', t3.sobrenomeFuncionar) AS nome
FROM
	tbprojeto t
	INNER JOIN tbfuncionarioprojeto t2 ON t.numeroProjeto = t2.numeroProjeto
	INNER JOIN tbfuncionario t3 ON t2.matriculaFuncionario = t2.matriculaFuncionario
WHERE
	t3.matriculaFuncionario = t2.matriculaFuncionario;

/* OUTRA MANEIRA MENOS CONVENCIONAL É UTILIZAR UM GROUP BY */
SELECT
	t3.matriculaFuncionario,
	concat(t3.nomeFuncionario, ' ', t3.sobrenomeFuncionar) AS nome
FROM
	tbprojeto t
	INNER JOIN tbfuncionarioprojeto t2 ON t.numeroProjeto = t2.numeroProjeto
	INNER JOIN tbfuncionario t3 ON t2.matriculaFuncionario = t2.matriculaFuncionario
WHERE
	t3.matriculaFuncionario = t2.matriculaFuncionario
GROUP BY
	1,
	2;

/* ********************************************************************************************
 * LIMPANDO OS DADOS COM TRANSFORMAÇÕES CASE - PODEMOS UTILIZAR INSTRUÇÕES CASE PARA VARIAS  **
 * TAREFAS DE LIMPEZA DE DADOS.																 **			
 * ********************************************************************************************/
SELECT
	t.matriculaFuncionario,
	max(
		CASE
			WHEN t.sexo = 'F' THEN 1
			ELSE 0
		END
	) AS feminino,
	max(
		CASE
			WHEN t.sexo = 'M' THEN 1
			ELSE 0
		END
	) AS masculino
FROM
	tbfuncionario t
GROUP BY
	1;

SELECT
	SUM(
		CASE
			WHEN t.sexo = 'F' THEN 1
			ELSE 0
		END
	) AS feminino,
	SUM(
		CASE
			WHEN t.sexo = 'M' THEN 1
			ELSE 0
		END
	) AS masculino
FROM
	tbfuncionario t;

/* UTILIZANDO AS CONVERSOES DE TIPOS EM INSTRUCOES CASE PARA CATEGORIZAR VALORES QUE SÃO NUMERICOS */
SELECT
	t.matriculaFuncionario,
	CASE
		WHEN SUM(t.horasTrabalhadas) <= 60 THEN CONVERT(SUM(t.horasTrabalhadas), CHAR)
		ELSE '60+'
	END AS horasTrabalhadasTotal
FROM
	tbfuncionarioprojeto t
GROUP BY
	t.matriculaFuncionario;

/* NESSE CASO ESTAMOS RETORNANDO A QUANTIDADE DE FUNCIONARIOS QUE FIZERAM MAIS DE 60 HORAS DE PROJETO */
SELECT
	COUNT(*) AS quantidadeMatriculas60Plus
FROM
	(
		SELECT
			t.matriculaFuncionario,
			CASE
				WHEN SUM(t.horasTrabalhadas) <= 60 THEN CONVERT(SUM(t.horasTrabalhadas), CHAR)
				ELSE '60+'
			END AS horasTrabalhadasTotal
		FROM
			tbfuncionarioprojeto t
		GROUP BY
			t.matriculaFuncionario
	) AS subconsulta
WHERE
	subconsulta.horasTrabalhadasTotal = '60+';

/* ********************************************************************************************
 * LIDANDO COM NULOS: FUNCOES COALESCE, NULLIF, NVL											 **
 **********************************************************************************************/
 
/* LIDANDO COM VALORES NULOS USANDO FUNÇÃO CASE */
SELECT
	t.matriculaFuncionario,
	CONCAT(t.nomeFuncionario, ' ', t.sobrenomeFuncionar) AS nome,
	t.sexo,
	t.salarioFuncionario,
	CASE
		WHEN t.matriculaGerente IS NULL THEN 'SEM GERENTE'
		ELSE t.matriculaGerente
	END AS gerente
FROM
	tbfuncionario t
WHERE
	(
		CASE
			WHEN t.matriculaGerente IS NULL THEN 'SEM GERENTE'
			ELSE t.matriculaGerente
		END
	) = 'SEM GERENTE';

/* AQUI UTILIZAMOS A FUNÇÃO COALESCE, UMA MANEIRA MAIS COMPACTA DE RESOLVER VALORES NULOS */
SELECT
	t.matriculaFuncionario,
	CONCAT(t.nomeFuncionario, ' ', t.sobrenomeFuncionar) AS nome,
	t.sexo,
	t.salarioFuncionario,
	COALESCE(t.matriculaGerente, 'SEM GERENTE') AS gerente
FROM
	tbfuncionario t
WHERE
	COALESCE(t.matriculaGerente, 'SEM GERENTE') = 'SEM GERENTE';

DESC tbfuncionarioprojeto;