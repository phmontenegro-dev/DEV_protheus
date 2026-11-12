/* ****************************************************************************
 * SD3010 — Movimentações Internas de Estoque (por período)
 *
 * Traz todas as movimentações internas do SD3 com join em produto (SB1) e
 * grupo (SBM), filtrando apenas movimentações vinculadas a Ordem de Produção.
 *
 * Filtros:
 *   - D3_OP preenchida (<> ' ')
 *   - Não deletadas
 *   - D3_FILIAL fora de ('0101003','0101006')
 *   - D3_EMISSAO no período informado
 * ****************************************************************************/
SELECT
    D3_FILIAL,
    D3_COD,
    D3_SEQCALC,
    B1_DESC,
    D3_CF,
    D3_TM,
    D3_UM,
    D3_QUANT,
    D3_OP,
    D3_EMISSAO,
    D3_GRUPO,
    BM_DESC,
    D3_CUSTO1,
    D3_PARCTOT,
    D3_TIPO,
    D3_LOTECTL,
    D3_PERDA
FROM SD3010 SD3
    INNER JOIN SB1010 SB1
        ON B1_COD = D3_COD
        AND SB1.D_E_L_E_T_ = ' '
    INNER JOIN SBM010 SBM
        ON BM_GRUPO = D3_GRUPO
        AND SBM.D_E_L_E_T_ = ' '
WHERE D3_OP <> ' '
    AND SD3.D_E_L_E_T_ = ' '
    AND D3_FILIAL NOT IN ('0101003','0101006')
    AND D3_EMISSAO BETWEEN '20260101' AND '20260228';
