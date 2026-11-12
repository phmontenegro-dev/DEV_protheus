/* ****************************************************************************
 * SD4 SUZANO — Empenhos (filtro fixo + período em D4_EMPENHO)
 *
 * Primeiro relatório SUZANO híbrido: mistura filtro fixo de lote com
 * período de data informado pelo usuário.
 *
 * Observação sobre D4_COD vs D4_PRODUTO:
 *   - D4_COD     = código do INSUMO empenhado
 *   - D4_PRODUTO = código do PRODUTO PAI (item final da OP)
 *
 * Filtros:
 *   - Fixos:  D4_LOTECTL LIKE '%SZ%'  +  não deletados
 *   - Param:  D4_EMPENHO BETWEEN :data_inicio AND :data_fim
 * ****************************************************************************/
SELECT
    D4.D4_FILIAL,
    D4.D4_COD,
    B1.B1_UM,
    B1.B1_DESC,
    D4.D4_OP,
    D4.D4_LOCAL,
    D4.D4_DATA,
    D4.D4_QTDEORI,
    D4.D4_QUANT,
    D4.D4_SLDEMP,
    D4.D4_LOTECTL,
    D4.D4_PRODUTO,
    D4.D4_ROTEIRO,
    D4.D4_XLOTE
FROM SD4010 D4
    INNER JOIN SB1010 B1
        ON B1.B1_COD = D4.D4_COD
        AND B1.D_E_L_E_T_ = ' '
WHERE
    D4.D4_LOTECTL LIKE '%SZ%'
    AND D4.D4_EMPENHO BETWEEN :data_inicio AND :data_fim
    AND D4.D_E_L_E_T_ = ' '
ORDER BY
    D4.D4_FILIAL,
    D4.D4_COD,
    D4.D4_LOTECTL;
