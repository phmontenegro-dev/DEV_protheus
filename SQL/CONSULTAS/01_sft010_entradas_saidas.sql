/* ****************************************************************************
 * SFT010 — Documentos de Entrada e Saída
 *
 * Consolida a tabela de contabilização (SFT) com produto (SB1), grupo (SBM),
 * cliente/fornecedor (SA1/SA2), TES (SF4) e custos das notas de entrada e
 * saída (SD1/SD2). Traz também duas fotos de saldo de estoque (SB9) em datas
 * de referência para comparar o antes/depois do período.
 *
 * Filtros:
 *   - FT_ENTRADA no período informado
 *   - FT_FILIAL diferente de '0101003'
 *   - Linhas não deletadas
 *
 * Observação sobre as subqueries B9:
 *   As datas '20251231' e '20260131' são fixas no exemplo; na ferramenta
 *   final, foram derivadas automaticamente do período informado pelo
 *   usuário (fim do mês anterior ao início + fim do mês da data final).
 * ****************************************************************************/
SELECT
    SFT.FT_FILIAL,
    SFT.FT_TIPOMOV,
    SFT.FT_CLIEFOR,
    COALESCE(SA1.A1_NOME, SA2.A2_NOME) AS NOME_CLIEFOR,
    SFT.FT_NFISCAL,
    SFT.FT_PRODUTO,
    SB1.B1_DESC,
    SB1.B1_TIPO,
    SB1.B1_GRUPO,
    SBM.BM_DESC,
    SB1.B1_EXPRESS AS EXPRESSO,
    SB1.B1_UM,
    SFT.FT_OBSERV,
    SFT.FT_CFOP,
    SFT.FT_TES,
    SF4.F4_TEXTO,
    CASE SF4.F4_TRANFIL
        WHEN '2' THEN 'NAO'
        ELSE 'SIM'
    END AS TRANSF,
    SUM(SFT.FT_PRCUNIT) AS T_PRUNIT,
    SUM(SFT.FT_TOTAL)   AS T_TOTITEM,
    SUM(SFT.FT_QUANT)   AS T_QUANT,
    SUM(SFT.FT_VALICM)  AS ICM,
    SUM(SFT.FT_VALIPI)  AS IPI,
    SUM(SFT.FT_VALPIS)  AS PIS,
    SUM(SFT.FT_VALCOF)  AS COFINS,
    SUM(CASE WHEN SFT.FT_TIPOMOV = 'E' THEN SD1.D1_CUSTO  ELSE 0 END) AS CUSTO_ENTRADA,
    SUM(CASE WHEN SFT.FT_TIPOMOV = 'S' THEN SD2.D2_CUSTO1 ELSE 0 END) AS CUSTO_SAIDA,
    (SELECT B9_CM1  FROM SB9010 WHERE B9_FILIAL = SFT.FT_FILIAL AND B9_COD = SFT.FT_PRODUTO AND B9_DATA = '20251231' AND D_E_L_E_T_ = ' ' AND ROWNUM = 1) AS B9C_202512,
    (SELECT B9_QINI FROM SB9010 WHERE B9_FILIAL = SFT.FT_FILIAL AND B9_COD = SFT.FT_PRODUTO AND B9_DATA = '20251231' AND D_E_L_E_T_ = ' ' AND ROWNUM = 1) AS B9Q_202512,
    (SELECT B9_CM1  FROM SB9010 WHERE B9_FILIAL = SFT.FT_FILIAL AND B9_COD = SFT.FT_PRODUTO AND B9_DATA = '20260131' AND D_E_L_E_T_ = ' ' AND ROWNUM = 1) AS B9C_202601,
    (SELECT B9_QINI FROM SB9010 WHERE B9_FILIAL = SFT.FT_FILIAL AND B9_COD = SFT.FT_PRODUTO AND B9_DATA = '20260131' AND D_E_L_E_T_ = ' ' AND ROWNUM = 1) AS B9Q_202601
FROM SFT010 SFT
    INNER JOIN SB1010 SB1 ON SB1.B1_COD    = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' '
    INNER JOIN SBM010 SBM ON SBM.BM_GRUPO  = SB1.B1_GRUPO   AND SBM.D_E_L_E_T_ = ' '
    LEFT  JOIN SA1010 SA1 ON SA1.A1_COD    = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.D_E_L_E_T_ = ' '
    LEFT  JOIN SA2010 SA2 ON SA2.A2_COD    = SFT.FT_CLIEFOR AND SA2.A2_LOJA = SFT.FT_LOJA AND SA2.D_E_L_E_T_ = ' '
    LEFT  JOIN SF4010 SF4 ON SF4.F4_CODIGO = SFT.FT_TES     AND SF4.D_E_L_E_T_ = ' '
    LEFT  JOIN SD1010 SD1 ON SD1.D1_FILIAL  = SFT.FT_FILIAL
                         AND SD1.D1_DOC     = SFT.FT_NFISCAL
                         AND SD1.D1_SERIE   = SFT.FT_SERIE
                         AND SD1.D1_COD     = SFT.FT_PRODUTO
                         AND SD1.D1_FORNECE = SFT.FT_CLIEFOR
                         AND SD1.D1_LOJA    = SFT.FT_LOJA
                         AND SFT.FT_TIPOMOV = 'E'
                         AND SD1.D_E_L_E_T_ = ' '
    LEFT  JOIN SD2010 SD2 ON SD2.D2_FILIAL  = SFT.FT_FILIAL
                         AND SD2.D2_DOC     = SFT.FT_NFISCAL
                         AND SD2.D2_SERIE   = SFT.FT_SERIE
                         AND SD2.D2_COD     = SFT.FT_PRODUTO
                         AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR
                         AND SD2.D2_LOJA    = SFT.FT_LOJA
                         AND SFT.FT_TIPOMOV = 'S'
                         AND SD2.D_E_L_E_T_ = ' '
WHERE SFT.FT_ENTRADA BETWEEN '20260101' AND '20260228'
  AND SFT.FT_FILIAL <> '0101003'
  AND SFT.D_E_L_E_T_ = ' '
GROUP BY
    SFT.FT_FILIAL,
    SFT.FT_TIPOMOV,
    SFT.FT_CLIEFOR,
    SA1.A1_NOME,
    SA2.A2_NOME,
    SFT.FT_NFISCAL,
    SFT.FT_PRODUTO,
    SB1.B1_DESC,
    SB1.B1_TIPO,
    SB1.B1_GRUPO,
    SBM.BM_DESC,
    SB1.B1_EXPRESS,
    SB1.B1_UM,
    SFT.FT_OBSERV,
    SFT.FT_CFOP,
    SFT.FT_TES,
    SF4.F4_TEXTO,
    SF4.F4_TRANFIL;
