/* ****************************************************************************
 * Relatório Consolidado Suzano - Jhon
 *
 * Consolida bobinas produzidas (SH6) com cadastro do produto (SB1) e pedido
 * de venda do cliente (SC6, resolvido via SUBSTR dos 6 primeiros caracteres
 * da OP).
 *
 * Destaques técnicos:
 *   - Aliases em português com aspas duplas (Oracle preserva case e acentos)
 *   - Colunas NULL fixas (VOL.ID, POSIÇÃO) para preenchimento futuro
 *   - CONCAT com '-' para montar "PEDIDO DO CLIENTE"
 *
 * Abaixo, duas versões:
 *   V1 — versão original (apenas D_E_L_E_T_ no WHERE)
 *   V2 — versão evoluída: filtro %SZ% + período em H6_DATAFIN (campo só usado
 *        no filtro, não retornado) + TRIM nos campos do CONCAT para remover
 *        o padding de CHAR do Protheus
 * ****************************************************************************/


/* =============================================================================
 * V1 — Versão original
 * ============================================================================*/
SELECT
    H6.H6_XLOTELI AS "BOBINA MÃE",
    NULL AS "VOL.ID",
    H6.H6_XNUMBOB AS "BOBINA FILHA",
    H6.H6_XMETRO * 1000 AS "METRAGEM",
    B1.B1_XGRAM1 + B1.B1_XGRAM2 + B1.B1_XGRAM3 AS "GRAMATURA",
    H6.H6_XDIAM / 10 AS "DIAMETRO",
    H6.H6_XPESOB AS "PESO (KG)",
    H6.H6_XEMEND AS "EMENDAS",
    NULL AS "POSIÇÃO",
    H6.H6_XTIRA2 AS "TIRADA",
    H6.H6_LOTECTL AS "LOTE TECHNOCOAT",
    H6.H6_OP AS "NÚMERO DA OP",
    C6.C6_NUMPCOM || '-' || C6.C6_ITEMPC AS "PEDIDO DO CLIENTE"
FROM SH6010 H6
    LEFT JOIN SB1010 B1
        ON B1.B1_COD = H6.H6_PRODUTO
        AND B1.D_E_L_E_T_ = ' '
    LEFT JOIN SC6010 C6
        ON C6.C6_NUM = SUBSTR(H6.H6_OP, 1, 6)
        AND C6.D_E_L_E_T_ = ' '
WHERE H6.D_E_L_E_T_ = ' ';


/* =============================================================================
 * V2 — Versão evoluída (filtro Suzano + período + TRIM)
 * ============================================================================*/
SELECT
    H6.H6_XLOTELI AS "BOBINA MÃE",
    NULL AS "VOL.ID",
    H6.H6_XNUMBOB AS "BOBINA FILHA",
    H6.H6_XMETRO * 1000 AS "METRAGEM",
    B1.B1_XGRAM1 + B1.B1_XGRAM2 + B1.B1_XGRAM3 AS "GRAMATURA",
    H6.H6_XDIAM / 10 AS "DIAMETRO",
    H6.H6_XPESOB AS "PESO (KG)",
    H6.H6_XEMEND AS "EMENDAS",
    NULL AS "POSIÇÃO",
    H6.H6_XTIRA2 AS "TIRADA",
    H6.H6_LOTECTL AS "LOTE TECHNOCOAT",
    H6.H6_OP AS "NÚMERO DA OP",
    TRIM(C6.C6_NUMPCOM) || '-' || TRIM(C6.C6_ITEMPC) AS "PEDIDO DO CLIENTE"
FROM SH6010 H6
    LEFT JOIN SB1010 B1
        ON B1.B1_COD = H6.H6_PRODUTO
        AND B1.D_E_L_E_T_ = ' '
    LEFT JOIN SC6010 C6
        ON C6.C6_NUM = SUBSTR(H6.H6_OP, 1, 6)
        AND C6.D_E_L_E_T_ = ' '
WHERE H6.D_E_L_E_T_ = ' '
    AND H6.H6_LOTECTL LIKE '%SZ%'
    AND H6.H6_DATAFIN BETWEEN :data_inicio AND :data_fim;
