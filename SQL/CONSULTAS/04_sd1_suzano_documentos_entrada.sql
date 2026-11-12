/* ****************************************************************************
 * SD1 SUZANO — Documentos de Entrada (filtros fixos, sem parâmetros)
 *
 * Filtros fixos:
 *   - D1_LOTECTL LIKE '%SZ%'    (lotes Suzano)
 *   - Não deletados
 * ****************************************************************************/
SELECT
    D1_FILIAL,
    D1_COD,
    D1_XDESCPR,
    D1_UM,
    D1_QUANT,
    D1_LOTECTL,
    D1_DOC,
    D1_EMISSAO,
    D1_DTDIGIT
FROM SD1010
WHERE D1_LOTECTL LIKE '%SZ%'
    AND D_E_L_E_T_ = ' '
ORDER BY
    D1_FILIAL,
    D1_COD,
    D1_LOTECTL;
