/* ****************************************************************************
 * SH6 SUZANO — Apontamentos de Produção (filtro fixo + período em H6_DTAPONT)
 *
 * Híbrido: filtro fixo de lote + período de data de apontamento.
 *
 * Filtros:
 *   - Fixos:  H6_LOTECTL LIKE '%SZ%'  +  não deletados
 *   - Param:  H6_DTAPONT BETWEEN :data_inicio AND :data_fim
 * ****************************************************************************/
SELECT
    H6.H6_FILIAL,
    H6.H6_OP,
    H6.H6_PRODUTO,
    B1.B1_DESC,
    B1.B1_UM,
    H6.H6_RECURSO,
    H6.H6_DATAINI,
    H6.H6_HORAINI,
    H6.H6_DATAFIN,
    H6.H6_HORAFIN,
    H6.H6_QTDPROD,
    H6.H6_QTDPERD,
    H6.H6_DTAPONT,           -- filtro de data é aplicado nesta coluna
    H6.H6_LOTECTL,
    H6.H6_DTPROD,
    H6.H6_LOCAL,
    H6.H6_XLOTELI,
    H6.H6_XDIAM,
    H6.H6_XNUMBOB
FROM SH6010 H6
    INNER JOIN SB1010 B1
        ON B1.B1_COD = H6.H6_PRODUTO
        AND B1.D_E_L_E_T_ = ' '
WHERE
    H6.H6_LOTECTL LIKE '%SZ%'
    AND H6.H6_DTAPONT BETWEEN :data_inicio AND :data_fim
    AND H6.D_E_L_E_T_ = ' '
ORDER BY
    H6.H6_FILIAL,
    H6.H6_PRODUTO,
    H6.H6_LOTECTL;
