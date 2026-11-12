/* ****************************************************************************
 * SD2 SUZANO — Documentos de Saída (filtros fixos, sem parâmetros)
 *
 * Filtros fixos:
 *   - D2_LOTECTL LIKE '%SZ%'    (lotes Suzano)
 *   - Não deletados
 * ****************************************************************************/
SELECT
    D2_FILIAL,
    D2_COD,
    D2_UM,
    D2_QUANT,
    D2_TES,
    D2_CF,
    D2_CLIENTE,
    D2_LOCAL,
    D2_DOC,
    D2_LOTECTL,
    D2_TP,
    D2_EMISSAO
FROM SD2010
WHERE D2_LOTECTL LIKE '%SZ%'
    AND D_E_L_E_T_ = ' '
ORDER BY
    D2_FILIAL,
    D2_COD,
    D2_LOTECTL;
