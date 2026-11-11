#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/{Protheus.doc} xpcp002a
Etiqueta de Produção
@author Claudio Bozzi
@since 18/07/2025
@version 2410
@type function
/*/
User Function xpcp002a()

	Local aArea		:= GetArea()
	Local cImp		:= ""
	Local lAuto		:= .F.
	Local lImpPDF	:= .F.
	Local cTempDir  := "" //GetTempPath()

	If Type("_lAutoEPrd") <> "U" .AND. _lAutoEPrd
		lAuto := .T.
	EndIf

	// SE NÃO TIVER TELA, CRIAR NA PROTHEUS_DATA
    if ( isBlind() .OR. select( 'SX2' ) <= 0 )
        cTempDir := '\etiquetas\'
        FWMakeDir( cTempDir )
    else
        cTempDir := GetTempPath()
    endIf

	Private cLocal		:= cTempDir
	Private lUltPag		:= .T.
	Private lAdjust		:= .F.
	Private lDisable	:= .T.
	Private oPrinter	:= Nil

	If TemEtqSzn()
		If ! lAuto
			FWAlertWarning("Produto possui configuração para etiqueta Suzano!","Atenção")
		EndIf
		RestArea(aArea)
		Return
	EndIf

	cImp := GetImp(lAuto)
	If Empty(cImp) .AND. !lAuto
		RestArea(aArea)
		Return
	EndIf

	lImpPDF := (Upper(AllTrim(cImp)) == "PDF")

	If ! ExistDir(cTempDir)
		MakeDir(cTempDir)
	EndIf

	If ! ExistDir(cTempDir)
		If ! lAuto
			FWAlertError("Não foi possível criar o diretório " + cTempDir + "","ATENÇÃO")
		EndIf
		RestArea(aArea)
		Return
	EndIf

	oPrinter := FWMSPrinter():New("Etq_Prd_" + DtoS(dDataBase) + "_" + StrTran(Time(),":",""), IMP_PDF, lAdjust, cLocal, lDisable, , , , , , .F.)
	oPrinter:cPathPdf := cTempDir
	oPrinter:SetPortrait()
	oPrinter:setPaperSize(8) // A3

	Private oArial8		:= TFont():New("Arial",,08,,.f.,,,,,.f.,.f.)
	Private oArial8N	:= TFont():New("Arial",,08,,.t.,,,,,.f.,.f.)
	Private oArial10	:= TFont():New("Arial",,10,,.f.,,,,,.f.,.f.)
	Private oArial10N	:= TFont():New("Arial",,10,,.t.,,,,,.f.,.f.)
	Private oArial12	:= TFont():New("Arial",,12,,.f.,,,,,.f.,.f.)
	Private oArial12N	:= TFont():New("Arial",,12,,.t.,,,,,.f.,.f.)
	Private oArial14	:= TFont():New("Arial",,14,,.f.,,,,,.f.,.f.)
	Private oArial14N	:= TFont():New("Arial",,14,,.t.,,,,,.f.,.f.)
	Private oArial16	:= TFont():New("Arial",,16,,.f.,,,,,.f.,.f.)
	Private oArial16N	:= TFont():New("Arial",,16,,.t.,,,,,.f.,.f.)
	Private oArial18N	:= TFont():New("Arial",,18,,.t.,,,,,.f.,.f.)
	Private oArial20N	:= TFont():New("Arial",,20,,.t.,,,,,.f.,.f.)
	Private oArial24	:= TFont():New("Arial",,24,,.f.,,,,,.f.,.f.)
	Private oArial24N	:= TFont():New("Arial",,24,,.t.,,,,,.f.,.f.)
	Private oArial28N	:= TFont():New("Arial",,28,,.t.,,,,,.f.,.f.)

	ImpEtq()

	oPrinter:EndPage()

	If lAuto
		If ! lImpPDF .AND. ! Empty(cImp)
			oPrinter:SetDevice(IMP_SPOOL)
			oPrinter:cPrinter := cImp
			oPrinter:Print()
		Else
			oPrinter:Preview()
		EndIf
	Else
		If lImpPDF
			oPrinter:Preview()
		Else
			oPrinter:SetDevice(IMP_SPOOL)
			oPrinter:cPrinter := cImp
			oPrinter:Print()
		EndIf
	EndIf

	RestArea(aArea)
Return

Static Function TemEtqSzn()

	Local lRet := .F.

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1") + SH6->H6_PRODUTO))
		lRet := (AllTrim(SB1->B1_XETQSZN) == "1")
	EndIf

Return lRet

Static Function GetImp(lAuto)

	Local cRet 		:= ""
	Local aPergs 	:= {}
	Local aRet 		:= {}
	Local cCodImp 	:= Space(TamSX3("CB5_CODIGO")[1])
	Local nTipoImp 	:= 1

	Default lAuto 	:= .F.

	If lAuto
		SH1->(DbSetOrder(1))
		If SH1->(DbSeek(xFilial("SH1") + SH6->H6_RECURSO))
			CB5->(DbSetOrder(1))
			If CB5->(DbSeek(xFilial("CB5") + AllTrim(SH1->H1_XIMPRE)))
				cRet := AllTrim(CB5->CB5_PRINTR)
			EndIf
		EndIf
	Else
		AAdd(aPergs, {2, "Tipo de Saída", nTipoImp, {"PDF", "Impressora"}, 50, "", .F.})
		AAdd(aPergs, {1, "Impressora", cCodImp, "", ".T.", "CB5", ".T.", 80, .F.})

		If ParamBox(aPergs, "Configuração de Impressão", @aRet,,,,,,,,.F.,.F.)
			nTipoImp := aRet[1]
			cCodImp := aRet[2]
			If(ValType(nTipoImp) <> "N")
				nTipoImp := Val(nTipoImp)
			Endif
			If nTipoImp == 1
				cRet := "PDF"
			Else
				CB5->(DbSetOrder(1))
				If CB5->(DbSeek(xFilial("CB5") + AllTrim(cCodImp)))
					cRet := AllTrim(CB5->CB5_PRINTR)
				EndIf
			EndIf
		EndIf
	EndIf

Return cRet

Static Function ImpEtq()

	GetxDados()

	oPrinter:StartPage()

	ImpArea()

Return

Static Function GetxDados()

	Local lTemCliOP := .F.

	SC2->(DbSetOrder(1))
	SC2->(DbSeek(xFilial("SC2") + SH6->H6_OP))

	lTemCliOP := ! Empty(SC2->C2_XCLIENT)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + SH6->H6_PRODUTO))

	// Produto x Cliente (SA7) - para pegar o código do produto no cliente
	// Se a OP tem cliente: filtra SA7 por produto + cliente + loja
	// Se a OP é para estoque (sem cliente): busca qualquer vínculo SA7 pelo produto
	If lTemCliOP
		BeginSql Alias 'TMPSA7'
			SELECT SA7.R_E_C_N_O_ AS RECNOSA7
			  FROM %TABLE:SA7% SA7
			 WHERE SA7.A7_FILIAL  = %xFilial:SA7%
			   AND SA7.A7_PRODUTO = %Exp:SH6->H6_PRODUTO%
			   AND SA7.A7_CLIENTE = %Exp:SC2->C2_XCLIENT%
			   AND SA7.A7_LOJA    = %Exp:SC2->C2_XLOJA%
			   AND SA7.%NOTDEL%
		EndSQL
	Else
		BeginSql Alias 'TMPSA7'
			SELECT SA7.R_E_C_N_O_ AS RECNOSA7
			  FROM %TABLE:SA7% SA7
			 WHERE SA7.A7_FILIAL  = %xFilial:SA7%
			   AND SA7.A7_PRODUTO = %Exp:SH6->H6_PRODUTO%
			   AND SA7.%NOTDEL%
		EndSQL
	EndIf

	If ! TMPSA7->(Eof())
		SA7->(DbGoTo(TMPSA7->RECNOSA7))
	Else
		SA7->(DbGoTo(0))
	EndIf

	TMPSA7->(DbCloseArea())

	// Posiciona SA1:
	// - Se a OP tem cliente: usa o cliente da OP (SC2)
	// - Senão, se a SA7 encontrou vínculo: usa o cliente da SA7 (fallback)
	SA1->(DbSetOrder(1))
	If lTemCliOP
		SA1->(DbSeek(xFilial("SA1") + SC2->C2_XCLIENT + SC2->C2_XLOJA))
	ElseIf ! Empty(SA7->A7_CLIENTE)
		SA1->(DbSeek(xFilial("SA1") + SA7->A7_CLIENTE + SA7->A7_LOJA))
	EndIf

	BeginSql Alias 'TMPSD3'
		SELECT SD3.R_E_C_N_O_ AS RECNOSD3
		  FROM %TABLE:SD3% SD3
		 WHERE SD3.D3_FILIAL = %xFilial:SD3%
		   AND SD3.D3_OP     = %Exp:SH6->H6_OP%
		   AND SD3.D3_COD    = %Exp:SH6->H6_PRODUTO%
		   AND SD3.%NOTDEL%
	EndSQL

	If ! TMPSD3->(Eof())
		SD3->(dbGoTo(TMPSD3->RECNOSD3))
	EndIf

	TMPSD3->(dbCloseArea())

Return

Static Function ImpArea()

Local aProd
Local cAux
Local cDesc
Local cUM
Local nI
Local nLinTmp
Local nPesoB
Local nPesoL

// Fontes específicas do novo layout
Local oArial11N	:= TFont():New("Arial",,11,,.t.,,,,,.f.,.f.)
Local oArial13	:= TFont():New("Arial",,13,,.f.,,,,,.f.,.f.)
Local oArial15N	:= TFont():New("Arial",,15,,.t.,,,,,.f.,.f.)
Local oArial17N	:= TFont():New("Arial",,17,,.t.,,,,,.f.,.f.)
Local oArial18	:= TFont():New("Arial",,18,,.f.,,,,,.f.,.f.)
Local oArial22N	:= TFont():New("Arial",,22,,.t.,,,,,.f.,.f.)
Local oArial26N	:= TFont():New("Arial",,26,,.t.,,,,,.f.,.f.)
Local oArial30N	:= TFont():New("Arial",,30,,.t.,,,,,.f.,.f.)
Local oArial34N	:= TFont():New("Arial",,34,,.t.,,,,,.f.,.f.)
Local oArial46N	:= TFont():New("Arial",,46,,.t.,,,,,.f.,.f.)

// Coordenadas gerais
// Frame largura: 30 a 810 (margens iguais à esquerda e direita em A3 portrait)
Local nColIni := 30
Local nColFim := 810
Local nLinIni := 30
Local nLinFim := 1159
Local nColTexto := 67        // X inicial do conteúdo (após barra azul)
Local nColFsc := 683         // X início do box FSC (mantém box ~127 wide)
Local nColMeia := 438        // X separador vertical central (recalculado para o novo centro)
Local nAzulIndustrial := RGB(34, 51, 108)
Local nRazao := 12.0
Local nRazaoCol := 12.0
Local oBrushAzul := TBRUSH():New(,nAzulIndustrial)

// Indica se o símbolo FSC deve ser desenhado nesta etiqueta
// (só aparece para produtos do grupo 0015 E com o arquivo de imagem disponível)
Local lTemFSC := (AllTrim(SB1->B1_GRUPO) == "0015") .AND. File("\data\imagens\fsc.jpg")

// Referência de centros horizontais usados para centralizar elementos:
//   centro da coluna esquerda = (67 + 400) / 2 = 233
//   centro útil do frame      = (67 + 727) / 2 = 397

// Coordenadas Y das seções (NOVA ORDEM: pesos entre descrição e dados técnicos)
Local nYHeader   := 195    // fim do logo (logo reduzida 20%)
Local nYOrdem    := 270    // fim da Ordem de Produção e FSC box
Local nYCliente  := 340    // fim do Cliente
Local nYCodigos  := 510    // fim da seção Código Produto/Código Cliente
Local nYDescr    := 655    // fim da Descrição (145px)
Local nYPesos    := 755    // fim da seção de Pesos
Local nYDados    := 925    // fim da seção Dados Técnicos
                           // lote: 1159 - 925 = 234px

	// ===== REGRAS CONDICIONAIS BASEADAS NA SA7 =====
	// Se A7_XDESCEX preenchido: pesos convertidos para KG (x1000)
	// Caso contrário: pesos nativos com UM do SB1
	If ! Empty(RTrim(SA7->A7_XDESCEX))
		cUM    := "KG"
		nPesoB := SH6->H6_XPESOB * 1000
		nPesoL := SH6->H6_XPESOL * 1000
	Else
		cUM    := AllTrim(SB1->B1_UM)
		nPesoB := SH6->H6_XPESOB
		nPesoL := SH6->H6_XPESOL
	EndIf

	// ===== FRAME EXTERNO =====
	oPrinter:Line(nLinIni, nColIni, nLinIni, nColFim, ,"-9")         // topo
	oPrinter:Line(nLinIni, nColIni, nLinFim, nColIni, ,"-9")         // esquerda
	oPrinter:Line(nLinIni, nColFim, nLinFim, nColFim, ,"-9")         // direita
	oPrinter:Line(nLinFim, nColIni, nLinFim, nColFim, ,"-9")         // base
	oPrinter:FillRect({nLinIni, nColIni, nLinFim, nColIni + 32}, oBrushAzul)

	// ============ SEÇÃO 1: LOGO TECHNOCOAT (-20%) + FSC BOX ============
	// Logo Technocoat reduzida: 480x170 -> 384x136
	If File("\data\imagens\logo.jpg")
		oPrinter:SayBitmap(nLinIni + 20, nColTexto, "\data\imagens\logo.jpg", 384, 136)
	EndIf

	// FSC box - só desenha borda vertical e imagem se o símbolo FSC existir
	If lTemFSC
		oPrinter:Line(nLinIni, nColFsc, nYOrdem, nColFsc, ,"-9")
		oPrinter:SayBitmap(nLinIni + 20, nColFsc + 15, "\data\imagens\fsc.jpg", 110, 200)
	EndIf

	// Linha horizontal abaixo do logo:
	// - COM FSC: vai só até nColFsc (box FSC continua abaixo)
	// - SEM FSC: ocupa toda a largura do frame
	If lTemFSC
		oPrinter:Line(nYHeader, nColIni, nYHeader, nColFsc, ,"-9")
	Else
		oPrinter:Line(nYHeader, nColIni, nYHeader, nColFim, ,"-9")
	EndIf

	// ============ SEÇÃO 2: ORDEM DE PRODUÇÃO ============
	oPrinter:Say(nYHeader + 45, nColTexto, "ORDEM DE PRODUÇÃO:", oArial26N)
	oPrinter:Say(nYHeader + 38, nColTexto + 310, RTrim(SH6->H6_OP), oArial34N)

	oPrinter:Line(nYOrdem, nColIni, nYOrdem, nColFim, ,"-9")

	// ============ SEÇÃO 3: CLIENTE (máximo 20 caracteres) ============
	cAux := RTrim(SA1->A1_NOME)
	If Empty(cAux)
		cAux := "---"
	EndIf
	cAux := SubStr(cAux, 1, 20)
	oPrinter:Say(nYOrdem + 42, nColTexto, "CLIENTE:", oArial22N)
	oPrinter:Say(nYOrdem + 38, nColTexto + 170, cAux, oArial30N)

	oPrinter:Line(nYCliente, nColIni, nYCliente, nColFim, ,"-9")

	// ============ SEÇÃO 4: CÓDIGO PRODUTO | CÓDIGO CLIENTE ============
	// Separador vertical entre as duas colunas
	oPrinter:Line(nYCliente, nColMeia, nYCodigos, nColMeia, ,"-9")

	// --- Esquerda: Código Produto ---
	// Label no canto superior esquerdo
	oPrinter:Say(nYCliente + 25, nColTexto, "CÓDIGO PRODUTO:", oArial22N)

	cAux := RTrim(SH6->H6_PRODUTO)
	// Barcode e texto centralizados na coluna esquerda (67 a 438, centro 252)
	// X=142 para ambos (para 220px de largura estimada do barcode e do texto)
	oPrinter:FWMSBar("CODE128", (nYCliente + 48) / nRazao, (142) / nRazaoCol, cAux, oPrinter, , , .T., , 1.4, .F., "Arial", , .F., , , .F.)
	oPrinter:Say(nYCliente + 132, 142, cAux, oArial30N)

	// --- Direita: Código Cliente + Brazil ---
	// Código do produto no cliente (SA7->A7_CODCLI)
	oPrinter:Say(nYCliente + 25, nColMeia + 20, "CÓDIGO CLIENTE:", oArial22N)
	cAux := RTrim(SA7->A7_CODCLI)
	If Empty(cAux)
		cAux := "---"
	EndIf
	oPrinter:Say(nYCliente + 75, nColMeia + 20, cAux, oArial30N)

	// BRAZIL / MADE IN BRAZIL + ícones (largura reduzida p/ não esticar os círculos)
	oPrinter:Say(nYCodigos - 55, nColMeia + 55, "BRAZIL/MADE IN BRAZIL", oArial11N)
	If File("\data\imagens\icones.jpg")
		oPrinter:SayBitmap(nYCodigos - 42, nColMeia + 90, "\data\imagens\icones.jpg", 120, 38)
	EndIf

	oPrinter:Line(nYCodigos, nColIni, nYCodigos, nColFim, ,"-9")

	// ============ SEÇÃO 5: DESCRIÇÃO DO PRODUTO (até 150 car.) ============
	oPrinter:Say(nYCodigos + 30, nColTexto, "DESCRIÇÃO DO PRODUTO:", oArial22N)

	// Descrição: prioriza A7_XDESCEX (descrição customizada do cliente)
	// Se vazia, cai para SB1->B1_DESC (descrição padrão)
	cDesc := RTrim(SA7->A7_XDESCEX)
	If Empty(cDesc)
		cDesc := RTrim(SB1->B1_DESC)
	EndIf
	// Quebra em linhas de ~80 chars (usa toda a largura da seção, até a borda direita)
	// Até 4 linhas = capacidade de ~320 chars
	aProd := QBTexto(cDesc, 80, " ")
	nLinTmp := nYCodigos + 70
	For nI := 1 To Min(Len(aProd), 4)
		oPrinter:Say(nLinTmp, nColTexto, aProd[nI], oArial18)
		nLinTmp += 25
	Next nI

	oPrinter:Line(nYDescr, nColIni, nYDescr, nColFim, ,"-9")

	// ============ SEÇÃO 6: PESO BRUTO | PESO LÍQUIDO (NOVO LUGAR + barcode nos dois) ============
	// Separador vertical entre bruto e líquido
	oPrinter:Line(nYDescr, nColMeia, nYPesos, nColMeia, ,"-9")

	// --- Peso Bruto (esquerda) + barcode ---
	// nPesoB e cUM foram pré-computados no topo (x1000 e "KG" quando A7_XDESCEX preenchido)
	// Barcode leitura: apenas o valor numérico (sem UM) para não quebrar o scanner
	oPrinter:Say(nYDescr + 25, nColTexto, "PESO BRUTO:", oArial22N)
	cAux := AllTrim(Transform(nPesoB, RTrim(GetSX3Cache("H6_XPESOB", "X3_PICTURE"))))
	oPrinter:Say(nYDescr + 60, nColTexto, cAux + " " + cUM, oArial26N)
	oPrinter:FWMSBar("CODE128", (nYDescr + 25) / nRazao, (nColTexto + 170) / nRazaoCol, cAux, oPrinter, , , , , 1.5, .F., "Arial", , .F., , , .F.)

	// --- Peso Líquido (direita) + barcode ---
	oPrinter:Say(nYDescr + 25, nColMeia + 15, "PESO LÍQUIDO:", oArial22N)
	cAux := AllTrim(Transform(nPesoL, RTrim(GetSX3Cache("H6_XPESOL", "X3_PICTURE"))))
	oPrinter:Say(nYDescr + 60, nColMeia + 15, cAux + " " + cUM, oArial26N)
	oPrinter:FWMSBar("CODE128", (nYDescr + 25) / nRazao, (nColMeia + 180) / nRazaoCol, cAux, oPrinter, , , , , 1.5, .F., "Arial", , .F., , , .F.)

	oPrinter:Line(nYPesos, nColIni, nYPesos, nColFim, ,"-9")

	// ============ SEÇÃO 7: LARGURA/GRAMATURA | DADOS SH6 (MOVIDA PARA DEPOIS DOS PESOS) ============
	// Separador vertical
	oPrinter:Line(nYPesos, nColMeia, nYDados, nColMeia, ,"-9")

	// --- Esquerda: LARGURA e GRAMATURA (empilhados) ---
	oPrinter:Say(nYPesos + 25, nColTexto, "LARGURA:", oArial17N)
	cAux := AllTrim(Transform(SB1->B1_XLARG, RTrim(GetSX3Cache("B1_XLARG", "X3_PICTURE")))) + " X "
	cAux += AllTrim(Transform(SB1->B1_XCOMP, RTrim(GetSX3Cache("B1_XCOMP", "X3_PICTURE"))))
	oPrinter:Say(nYPesos + 60, nColTexto, cAux, oArial22N)

	oPrinter:Say(nYPesos + 100, nColTexto, "GRAMATURA:", oArial17N)
	// Se tem código do produto no cliente (A7_CODCLI): mostra somatório
	// Caso contrário: mostra o breakdown (GRAM1 + GRAM2 + GRAM3)
	If ! Empty(RTrim(SA7->A7_CODCLI))
		cAux := AllTrim(Transform(SB1->B1_XGRAM1 + SB1->B1_XGRAM2 + SB1->B1_XGRAM3, RTrim(GetSX3Cache("B1_XGRAM1", "X3_PICTURE"))))
	Else
		cAux := AllTrim(Transform(SB1->B1_XGRAM1, RTrim(GetSX3Cache("B1_XGRAM1", "X3_PICTURE")))) + " + "
		cAux += AllTrim(Transform(SB1->B1_XGRAM2, RTrim(GetSX3Cache("B1_XGRAM2", "X3_PICTURE")))) + " + "
		cAux += AllTrim(Transform(SB1->B1_XGRAM3, RTrim(GetSX3Cache("B1_XGRAM3", "X3_PICTURE"))))
	EndIf
	oPrinter:Say(nYPesos + 135, nColTexto, cAux, oArial22N)

	// --- Direita: Grade 3x2 (Origem/Qtde/QtdeM² e Fabricação/Prox/Operador) ---
	oPrinter:Say(nYPesos + 20, nColMeia + 15, "ORIGEM:", oArial13)
	oPrinter:Say(nYPesos + 20, nColMeia + 125, "QTDE:", oArial13)
	oPrinter:Say(nYPesos + 20, nColMeia + 230, "QTDE M²:", oArial13)
	oPrinter:Say(nYPesos + 50, nColMeia + 15, RTrim(SH6->H6_XLOTELI), oArial15N)
	cAux := AllTrim(Transform(SH6->H6_QTDPROD, RTrim(GetSX3Cache("H6_QTDPROD", "X3_PICTURE"))))
	oPrinter:Say(nYPesos + 50, nColMeia + 125, cAux, oArial15N)
	cAux := AllTrim(Transform(SH6->H6_XMTQUA, RTrim(GetSX3Cache("H6_XMTQUA", "X3_PICTURE"))))
	oPrinter:Say(nYPesos + 50, nColMeia + 230, cAux, oArial15N)

	oPrinter:Say(nYPesos + 100, nColMeia + 15, "FABRICACAO:", oArial13)
	oPrinter:Say(nYPesos + 100, nColMeia + 125, "PRÓX.PROCESSO:", oArial13)
	oPrinter:Say(nYPesos + 100, nColMeia + 230, "OPERADOR:", oArial13)
	oPrinter:Say(nYPesos + 130, nColMeia + 15, DtoC(SH6->H6_DTAPONT), oArial15N)
	oPrinter:Say(nYPesos + 130, nColMeia + 125, RTrim(SB1->B1_XPROXP), oArial15N)
	oPrinter:Say(nYPesos + 130, nColMeia + 230, RTrim(SH6->H6_OPERADO), oArial15N)

	oPrinter:Line(nYDados, nColIni, nYDados, nColFim, ,"-9")

	// ============ SEÇÃO 8: LOTE (234px disponíveis) ============
	// Barcode e texto são desenhados por chamadas INDEPENDENTES (FWMSBar + Say)
	// A posição Y de cada um pode ser ajustada separadamente.
	oPrinter:Say(nYDados + 20, nColTexto, "LOTE:", oArial22N)

	cAux := RTrim(SH6->H6_LOTECTL)

	// Barcode em +25 (mesma altura do label LOTE: - não há overlap horizontal)
	// nHeight 2.8 - barcode grande, ocupa boa parte vertical
	// X=281 centralizado para o frame (centro = 438)
	oPrinter:FWMSBar("CODE128", (nYDados + 25) / nRazao, (281) / nRazaoCol, cAux, oPrinter, , , .T., , 2.8, .F., "Arial", , .F., , , .F.)

	// Texto grande do lote (oArial46N) em +205
	// X=238 centralizado
	oPrinter:Say(nYDados + 205, 238, cAux, oArial46N)

Return
