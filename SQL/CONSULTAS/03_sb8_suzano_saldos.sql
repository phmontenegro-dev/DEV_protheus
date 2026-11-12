/* ****************************************************************************
 * SB8 SUZANO — Saldos por Lote (filtros fixos, sem parâmetros)
 *
 * Primeiro relatório da família SUZANO: filtros totalmente fixos,
 * sem nenhum parâmetro do usuário.
 *
 * Filtros fixos:
 *   - B8_SALDO > 1              (só saldos relevantes)
 *   - B8_LOTECTL LIKE '%SZ%'    (lotes Suzano)
 *   - Não deletados
 * ****************************************************************************/
SELECT
    B8_FILIAL,
    B8_QTDORI,
    B8_PRODUTO,
    B8_LOCAL,
    B8_SALDO,
    B8_EMPENHO,
    B8_LOTECTL,
    B8_DOC,
    B8_DFABRIC
FROM SB8010
WHERE
    B8_SALDO > 1
    AND B8_LOTECTL LIKE '%SZ%'
    AND D_E_L_E_T_ = ' '
ORDER BY
    B8_FILIAL,
    B8_PRODUTO,
    B8_LOTECTL;
