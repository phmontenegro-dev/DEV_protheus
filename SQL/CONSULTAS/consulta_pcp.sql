/* =====================================================================
   RELATÓRIO PCP - Consulta por Lote (B8) - ORACLE
   Base: Protheus (TOTVS)
   Autor: Pedro Montenegro
   Observações:
   - Todos os JOINs filtram D_E_L_E_T_ = ' ' (registro ativo)
   - Oracle: usar NVL (não ISNULL) e || (não + para strings)
   - LEFT JOIN nas tabelas opcionais (D1, D2, D4, H6, C2, BF, C7)
   - Subquery para somatórios (D4_QUANT) para não distorcer o grid
   ===================================================================== */

SELECT
    /* -------- IDENTIFICAÇÃO -------- */
    B8.B8_FILIAL                              AS FILIAL,
    D1.D1_FORNECE                             AS FORNECEDOR,
    D2.D2_CLIENTE                             AS CLIENTE,
    A1.A1_NOME                                AS NOME_CLIENTE,
    D2.D2_LOJA                                AS LOJA,

    /* -------- PRODUTO -------- */
    B8.B8_PRODUTO                             AS COD_PRODUTO,
    B1.B1_TIPO                                AS TIPO_PRODUTO,
    B1.B1_DESC                                AS DESCRICAO_PROD,
    B1.B1_UM                                  AS UNIDADE_MEDIDA,

    /* -------- LOCALIZAÇÃO -------- */
    B8.B8_LOCAL                               AS ARMAZEM,
    BF.BF_LOCALIZ                             AS ENDERECO,

    /* -------- QUANTIDADES -------- */
    REPLACE(TO_CHAR(D1.D1_QUANT),       '.', ',')  AS QNTD_RECEBIDA,
    REPLACE(TO_CHAR(B8.B8_SALDO),       '.', ',')  AS QNTD_DO_LOTE,
    REPLACE(TO_CHAR(NVL(EMP.QTD_EMPENHO,0)), '.', ',') AS QNTD_EMPENHO,
    REPLACE(TO_CHAR(B8.B8_QTDORI),      '.', ',')  AS QNTD_ORIGINAL,

    /* -------- ORDEM DE PRODUÇÃO -------- */
    H6.H6_OP                                  AS OP,
    C2.C2_DATPRI                              AS DATA_PREV_INICIO,
    C2.C2_DATPRF                              AS DATA_PREV_FINAL,
    D4.D4_OPORIG                              AS OP_PAI,
    D4.D4_PRODUTO                             AS PRODUTO_PAI,

    /* -------- LOTE -------- */
    B8.B8_LOTECTL                             AS LOTE,
    H6.H6_XLOTELI                             AS LOTE_LIDO,
    H6.H6_XNUMBOB                             AS BOBINA_02A,

    /* -------- RECURSO / OPERAÇÃO -------- */
    H6.H6_RECURSO                             AS RECURSO,
    H1.H1_DESCRI                              AS DESC_RECURSO,
    H6.H6_OPERAC                              AS OPERACAO,
    VI.VI_DESCRI                              AS DESC_OPERACAO,
    D4.D4_ROTEIRO                             AS ROTEIRO,
    CASE LTRIM(RTRIM(D4.D4_ROTEIRO))
        WHEN '1' THEN 'Produção Padrão'
        WHEN '2' THEN 'Retrabalho Rebobinamento'
        WHEN '3' THEN 'Retrabalho Corona'
        ELSE NULL
    END                                       AS DESC_ROTEIRO,

    /* -------- APONTAMENTO -------- */
    H6.H6_OPERADO                             AS OPERADOR,
    H6.H6_DTAPONT                             AS DATA_APONT,
    H6.H6_DATAINI                             AS DATA_INICIAL,
    H6.H6_HORAINI                             AS HORA_INICIAL,
    H6.H6_DATAFIN                             AS DATA_FINAL,
    H6.H6_HORAFIN                             AS HORA_FINAL,
    H6.H6_TEMPO                               AS TEMPO_REAL,
    REPLACE(TO_CHAR(H6.H6_QTDPROD),     '.', ',')  AS QNTD_PRODUZIDA,
    REPLACE(TO_CHAR(H6.H6_QTDPERD),     '.', ',')  AS QNTD_PERDA,

    /* -------- CARACTERÍSTICAS FÍSICAS DO APONTAMENTO -------- */
    REPLACE(TO_CHAR(H6.H6_XPESOB),      '.', ',')  AS PESO_BRUTO,
    REPLACE(TO_CHAR(H6.H6_XPESOL),      '.', ',')  AS PESO_LIQUIDO,
    REPLACE(TO_CHAR(H6.H6_XDIAM),       '.', ',')  AS DIAMETRO,
    REPLACE(TO_CHAR(H6.H6_XMETRO),      '.', ',')  AS METRAGEM,
    REPLACE(TO_CHAR(H6.H6_XMTQUA),      '.', ',')  AS M2,
    H6.H6_XEMEND                              AS EMENDAS,
    H6.H6_XTIRA2                              AS TIRADAS,
    CASE WHEN B1.B1_UM = 'FL' THEN 'FOLHA' ELSE 'BOBINA' END AS FOLHA_BOBINA,

    /* -------- DIMENSÕES DO LOTE LIDO (produto do H6_XLOTELI) -------- */
    REPLACE(TO_CHAR(B1LI.B1_XLARG),     '.', ',')  AS LARGURA_LOTELID,
    REPLACE(TO_CHAR(NVL(B1LI.B1_XGRAM1,0)+NVL(B1LI.B1_XGRAM2,0)+NVL(B1LI.B1_XGRAM3,0)), '.', ',') AS GRAMATURA_LOTELIDO,
    REPLACE(TO_CHAR(B1LI.B1_XGRAM1),    '.', ',')  AS GRAM_PE1_LOTELIDO,
    REPLACE(TO_CHAR(B1LI.B1_XGRAM2),    '.', ',')  AS GRAM_PE2_LOTELIDO,
    REPLACE(TO_CHAR(B1LI.B1_XGRAM3),    '.', ',')  AS GRAM_PE3_LOTELIDO,

    /* -------- DIMENSÕES DO PRODUTO FINAL -------- */
    REPLACE(TO_CHAR(B1.B1_XLARG),       '.', ',')  AS LARGURA_FINAL,
    REPLACE(TO_CHAR(B1.B1_XCOMP),       '.', ',')  AS COMPRIMENTO,
    REPLACE(TO_CHAR(NVL(B1.B1_XGRAM1,0)+NVL(B1.B1_XGRAM2,0)+NVL(B1.B1_XGRAM3,0)), '.', ',') AS GRAMATURA,
    REPLACE(TO_CHAR(B1.B1_XGRAM1),      '.', ',')  AS GRAM_PE1,
    REPLACE(TO_CHAR(B1.B1_XGRAM2),      '.', ',')  AS GRAM_PE2,
    REPLACE(TO_CHAR(B1.B1_XGRAM3),      '.', ',')  AS GRAM_PE3,
    
    
    /* -------- SAÍDA / FATURAMENTO -------- */
    REPLACE(TO_CHAR(D2.D2_QUANT),       '.', ',')  AS QNTD_FATURADA,
    D2.D2_EMISSAO                             AS DATA_EMISSAO,
    D2.D2_TOTAL                               AS VALOR_VENDA,
    D2.D2_PEDIDO                              AS PEDIDO_VENDA,
    D2.D2_DOC                                 AS NF_SAIDA,
    D2.D2_ITEMPV                              AS ITEM_NF_SAIDA,
    D2.D2_SERIE                               AS SERIE_NF_SAIDA,
    D2.D2_CF                                  AS CODIGO_FISCAL,
    D2.D2_CUSTO1                              AS CUSTO,

    /* -------- COMPRA -------- */
    (RTRIM(C7.C7_NUM) || '/' || RTRIM(C7.C7_ITEM)) AS PEDIDO_ITEM_COMPRA_SUZ,
    D1.D1_TIPO                                AS TIPO_ENTRADA,
    D1.D1_PEDIDO                              AS PEDIDO_COMPRA,
    D1.D1_DOC                                 AS NF_ENTRADA,
    D1.D1_EMISSAO                             AS DATA_EMISSAO_ENTRADA

FROM SB8010 B8

/* Produto final */
LEFT JOIN SB1010 B1
       ON B1.B1_COD     = B8.B8_PRODUTO
      AND B1.D_E_L_E_T_ = ' '

/* Endereço do lote */
LEFT JOIN SBF010 BF
       ON BF.BF_FILIAL  = B8.B8_FILIAL
      AND BF.BF_PRODUTO = B8.B8_PRODUTO
      AND BF.BF_LOCAL   = B8.B8_LOCAL
      AND BF.BF_LOTECTL = B8.B8_LOTECTL
      AND BF.D_E_L_E_T_ = ' '

/* Nota de entrada (compra / recebimento) */
LEFT JOIN SD1010 D1
       ON D1.D1_FILIAL  = B8.B8_FILIAL
      AND D1.D1_COD     = B8.B8_PRODUTO
      AND D1.D1_LOTECTL = B8.B8_LOTECTL
      AND D1.D_E_L_E_T_ = ' '

/* Nota de saída (faturamento) */
LEFT JOIN SD2010 D2
       ON D2.D2_FILIAL  = B8.B8_FILIAL
      AND D2.D2_COD     = B8.B8_PRODUTO
      AND D2.D2_LOTECTL = B8.B8_LOTECTL
      AND D2.D_E_L_E_T_ = ' '
      

/* Empenho / requisição para produção (origem do lote) */
LEFT JOIN SD4010 D4
       ON D4.D4_FILIAL  = B8.B8_FILIAL
      AND D4.D4_COD     = B8.B8_PRODUTO
      AND D4.D4_LOTECTL = B8.B8_LOTECTL
      AND D4.D_E_L_E_T_ = ' '

/* Apontamento de produção */
LEFT JOIN SH6010 H6
       ON H6.H6_FILIAL  = B8.B8_FILIAL
      AND H6.H6_PRODUTO = B8.B8_PRODUTO
      AND H6.H6_LOTECTL = B8.B8_LOTECTL
      AND H6.D_E_L_E_T_ = ' '

/* Ordem de produção */
LEFT JOIN SC2010 C2
       ON C2.C2_FILIAL  = H6.H6_FILIAL
      AND (RTRIM(C2.C2_NUM) || RTRIM(C2.C2_ITEM) || RTRIM(C2.C2_SEQUEN)) = RTRIM(H6.H6_OP)
      AND C2.D_E_L_E_T_ = ' '

/* Cadastro de recursos */
LEFT JOIN SH1010 H1
       ON H1.H1_FILIAL  = H6.H6_FILIAL
      AND H1.H1_CODIGO  = H6.H6_RECURSO
      AND H1.D_E_L_E_T_ = ' '

/* Cadastro de operações */
LEFT JOIN SVI010 VI
       ON VI.VI_FILIAL  = H6.H6_FILIAL
      AND VI.VI_CODIGO  = H6.H6_OPERAC
      AND VI.D_E_L_E_T_ = ' '
      
/* Cadastro de clientes (SA1 geralmente é compartilhada entre filiais) */
LEFT JOIN SA1010 A1
       ON A1.A1_COD     = D2.D2_CLIENTE
      AND A1.A1_LOJA    = D2.D2_LOJA
      AND A1.D_E_L_E_T_ = ' '
                                 
      
/* Pedido de compra (vínculo via D1) - tabela SC7 com alias C7 */
LEFT JOIN SC7010 C7
       ON C7.C7_FILIAL  = D1.D1_FILIAL
      AND C7.C7_NUM     = D1.D1_PEDIDO
      AND C7.C7_ITEM    = D1.D1_ITEMPC
      AND C7.D_E_L_E_T_ = ' '

/* Produto do LOTE LIDO (B1 de outro B8 cujo lote = H6_XLOTELI) */
LEFT JOIN SB8010 B8LI
       ON B8LI.B8_FILIAL  = H6.H6_FILIAL
      AND B8LI.B8_LOTECTL = H6.H6_XLOTELI
      AND B8LI.D_E_L_E_T_ = ' '
LEFT JOIN SB1010 B1LI
       ON B1LI.B1_COD     = B8LI.B8_PRODUTO
      AND B1LI.D_E_L_E_T_ = ' '

/* Somatório do empenho por lote (evita duplicar linhas no grid) */
LEFT JOIN (
    SELECT  D4_FILIAL,
            D4_COD,
            D4_LOTECTL,
            SUM(D4_QUANT) AS QTD_EMPENHO
      FROM  SD4010
     WHERE  D_E_L_E_T_ = ' '
     GROUP BY D4_FILIAL, D4_COD, D4_LOTECTL
) EMP
       ON EMP.D4_FILIAL  = B8.B8_FILIAL
      AND EMP.D4_COD     = B8.B8_PRODUTO
      AND EMP.D4_LOTECTL = B8.B8_LOTECTL
      
      


WHERE B8.D_E_L_E_T_ = ' '
  AND B8.B8_FILIAL  = '0101001'          -- << ajustar a filial desejada
  AND NVL(LTRIM(B1.B1_DESC), 'X') NOT LIKE 'POLIETILENO%'
  
  
  AND (   C2.C2_DATPRI  BETWEEN '20261001' AND '20261031'
       OR C2.C2_DATPRF  BETWEEN '20261001' AND '20261031'
       OR H6.H6_DTAPONT BETWEEN '20261001' AND '20261031'
       OR H6.H6_DATAINI BETWEEN '20261001' AND '20261031'
       OR H6.H6_DATAFIN BETWEEN '20261001' AND '20261031'
       OR D2.D2_EMISSAO BETWEEN '20261001' AND '20261031'
       OR D1.D1_EMISSAO BETWEEN '20261001' AND '20261031'
      )
      


ORDER BY B8.B8_FILIAL,
         B8.B8_PRODUTO,
         B8.B8_LOTECTL,
         H6.H6_DATAINI,
         H6.H6_HORAINI;

