codeunit 83500 JXBRLogic
{
    trigger OnRun()
    begin

    end;

    procedure ValidateCNPJCPF(var xRecCNPJCPF: Text[20]; var CNPJCPF: Text[20]; FiscalType: Code[20]; GovernmentCompany: boolean; RecordVariant: Variant): Boolean
    // Categor  OptionCaption = ' ,1.- Person,2.- Company,3.- Foreign,4. - Person/Foreign';
    var
        CompanyInfo: Record "Company Information";
        Cust: Record Customer;
        Vend: Record Vendor;
        JXLTFiscalType: Record JXLTFiscalType;
        AuxRecordRef: RecordRef;
        AuxFieldRef: FieldRef;
        AuxCodeNo: Code[20];
        OriginalCode: Code[20];
        Text35001000: Label 'Please enter the Category.';
        Text35001004: Label 'Do you really want to change the C.P.F.?';
        Text35001005: Label 'Do you really want to change the C.N.P.J.?';
        Text35001006: Label 'C.N.P.J. invalid.';
        Text35001007: Label 'The C.N.P.J./C.P.F. is already in use for the %3 %1 - %2';
        Text35001008: Label 'C.P.F. invalid.';
    begin
        if CompanyInfo.JXIsBrasil() then begin
            if CNPJCPF = '' then
                exit;

            if FiscalType = '' then
                exit;

            JXLTFiscalType.Reset();
            JXLTFiscalType.SetRange("No.", FiscalType);
            if JXLTFiscalType.FindFirst() then
                JXLTFiscalType.TestField(JXBRFiscalType);

            if JXLTFiscalType.JXBRFiscalType = JXLTFiscalType.JXBRFiscalType::EXTERIOR then
                exit;

            OriginalCode := CNPJCPF;
            IF JXLTFiscalType.JXBRFiscalType = JXLTFiscalType.JXBRFiscalType::PERS_FISICA_RES THEN BEGIN
                IF (xRecCNPJCPF <> '') THEN BEGIN
                    IF (CNPJCPF <> xRecCNPJCPF) THEN
                        IF (NOT GUIALLOWED) THEN
                            CPFCheck(OriginalCode)
                        ELSE
                            IF CONFIRM(Text35001004, FALSE) THEN
                                CPFCheck(OriginalCode)
                            ELSE
                                CNPJCPF := xRecCNPJCPF
                END
                ELSE
                    CPFCheck(OriginalCode);
            END
            ELSE
                IF (xRecCNPJCPF <> '') THEN BEGIN
                    IF (CNPJCPF <> xRecCNPJCPF) THEN
                        IF (NOT GUIALLOWED) THEN BEGIN
                            IF NOT CNPJTest(OriginalCode) THEN
                                ERROR(Text35001006);
                        END ELSE
                            IF CONFIRM(Text35001005, FALSE) THEN BEGIN
                                IF (CNPJTest(OriginalCode) = FALSE) THEN
                                    ERROR(Text35001006);
                            END ELSE
                                CNPJCPF := xRecCNPJCPF
                END
                ELSE
                    IF (CNPJTest(OriginalCode) = FALSE) THEN
                        ERROR(Text35001006);

            CNPJCPF := OriginalCode;//Use formatted CNPJ before looking for duplicates

            IF CNPJCPF <> xRecCNPJCPF THEN
                IF NOT GovernmentCompany THEN BEGIN
                    AuxRecordRef.GETTABLE(RecordVariant);
                    AuxFieldRef := AUXRecordRef.FIELD(1);
                    AuxCodeNo := AuxFieldRef.Value;
                    case AuxRecordRef.Number of
                        23:
                            begin
                                Vend.reset();
                                Vend.SETRANGE(JXBRCNPJ, CNPJCPF);
                                Vend.SETFILTER(Vend."No.", '<> %1', AuxCodeNo);
                                IF Vend.FindFirst() THEN
                                    ERROR(Text35001007, Vend."No.", Vend.Name, Vend.TableCaption);

                            end;
                        18:
                            begin
                                Cust.reset();
                                Cust.SETRANGE(JXBRCNPJ, CNPJCPF);
                                Cust.SETFILTER(Cust."No.", '<> %1', AuxCodeNo);
                                IF Cust.FindFirst() THEN
                                    ERROR(Text35001007, Cust."No.", Cust.Name, Cust.TableCaption);

                            end;
                    end;//Case
                END;//NOT GovernmentCompany
            CNPJCPF := OriginalCode;
        end;
    end;

    procedure CPFCheck(var OriginalCode: Code[20]): Boolean
    var

    Begin
        // blank = false 
        // not black = true
        EXIT(CPFFormat(OriginalCode) <> '');
    end;

    procedure CPFFormat(var OriginalCode: Code[20]): Text[20]
    Var
        Calc: Integer;
        Character: Integer;
        Digit1: Integer;
        Digit2: Integer;
        I: Integer;
        Multiply: Integer;
        Text35001008: Label 'C.P.F. invalid.';
    begin
        IF COPYSTR(OriginalCode, 10, 1) = '-' THEN
            OriginalCode := COPYSTR(OriginalCode, 1, 9) + COPYSTR(OriginalCode, 11, 2);

        IF (STRLEN(OriginalCode) < 11) OR (STRLEN(OriginalCode) > 11) THEN
            ERROR(Text35001008);

        IF (OriginalCode = '00000000000') OR (OriginalCode = '11111111111') OR (OriginalCode = '22222222222')
           OR (OriginalCode = '33333333333') OR (OriginalCode = '44444444444') OR (OriginalCode = '55555555555')
             OR (OriginalCode = '66666666666') OR (OriginalCode = '77777777777')
               OR (OriginalCode = '88888888888') OR (OriginalCode = '99999999999') THEN
            ERROR(Text35001008);

        Multiply := 10;
        CLEAR(Calc);
        i := 1;
        REPEAT

            EVALUATE(Character, COPYSTR(OriginalCode, i, 1));
            Calc := Calc + (Character * Multiply);
            Multiply := Multiply - 1;
            i := i + 1;

        UNTIL i = STRLEN(COPYSTR(OriginalCode, 1, 10));
        Digit1 := Calc MOD 11;
        Digit1 := 11 - Digit1;
        IF Digit1 >= 10 THEN
            Digit1 := 0;

        Multiply := 11;
        CLEAR(Calc);
        i := 1;
        REPEAT

            EVALUATE(Character, COPYSTR(OriginalCode, i, 1));
            Calc := Calc + (Character * Multiply);
            Multiply := Multiply - 1;
            i := i + 1;

        UNTIL i = STRLEN(COPYSTR(OriginalCode, 1, 11));
        Digit2 := Calc MOD 11;
        Digit2 := 11 - Digit2;
        IF Digit2 >= 10 THEN
            Digit2 := 0;

        EVALUATE(Character, COPYSTR(OriginalCode, 10, 1));
        IF Digit1 <> Character THEN
            ERROR(Text35001008);

        EVALUATE(Character, COPYSTR(OriginalCode, 11, 1));
        IF Digit2 <> Character THEN
            ERROR(Text35001008);

        OriginalCode := COPYSTR(OriginalCode, 1, 9) + '-' + COPYSTR(OriginalCode, 10, 2);
        EXIT(COPYSTR(OriginalCode, 1, 9) + '-' + COPYSTR(OriginalCode, 10, 2));
    end;

    procedure CNPJTest(var CN: Code[20]): Boolean
    var
    Begin
        // blank = false 
        // not black = true

        EXIT(CNPJFormat(CN) <> '');
    end;

    procedure CNPJFormat(var CN: Code[20]) ResponseCNPJ: Text[20]
    Var
        OriginalCode: Code[20];
        D1: Integer;
        IL: Integer;
        R: Integer;
        SM: Integer;
        Text35001000: Label 'Do you really want to change the C.N.P.J.?';
        Text35001001: Label 'C.N.P.J. Invalid.';

    begin
        CN := DelChr(CN, '=', './-');//MtsBC15
        OriginalCode := CN;//MtsBC15
        IF COPYSTR(OriginalCode, 13, 1) = '-' THEN
            OriginalCode := COPYSTR(OriginalCode, 1, 12) + COPYSTR(OriginalCode, 14, 2);

        IF (STRLEN(OriginalCode) < 14) OR (STRLEN(OriginalCode) > 14) THEN
            ERROR(Text35001001);

        SM := (Ev(CN, 12) + Ev(CN, 4)) * 2 + (Ev(CN, 11) + Ev(CN, 3)) * 3;
        SM := SM + ((Ev(CN, 10) + Ev(CN, 2)) * 4) + (Ev(CN, 8) * 6);
        SM := SM + ((Ev(CN, 9) + Ev(CN, 1)) * 5) + (Ev(CN, 7) * 7);
        SM := SM + Ev(CN, 6) * 8 + Ev(CN, 5) * 9;

        IL := ROUND(SM / 11, 1, '<');
        R := SM - (IL * 11);
        D1 := 11 - R;
        IF (R = 0) OR (R = 1) THEN D1 := 0;

        IF D1 <> Ev(CN, 13) THEN EXIT('');//False

        /*Ciffer: 1 2 3 4 5 6 7 8 9 10 11 12 13*/
        /*Weight: 6 5 4 3 2 9 8 7 6  5  4  3  2*/

        SM := (Ev(CN, 13) + Ev(CN, 5)) * 2 + (Ev(CN, 12) + Ev(CN, 4)) * 3 +
              (Ev(CN, 11) + Ev(CN, 3)) * 4;
        SM := SM + ((Ev(CN, 10) + Ev(CN, 2)) * 5) + (Ev(CN, 8) * 7);
        SM := SM + ((Ev(CN, 9) + Ev(CN, 1)) * 6) + Ev(CN, 7) * 8 + Ev(CN, 6) * 9;

        IL := ROUND(SM / 11, 1, '<');
        R := SM - (IL * 11);
        D1 := 11 - R;
        IF (R = 0) OR (R = 1) THEN D1 := 0;

        IF D1 <> Ev(CN, 14) THEN EXIT('');//FALSE

        CN := COPYSTR(OriginalCode, 1, 12) + '-' + COPYSTR(OriginalCode, 13, 2);
        EXIT(COPYSTR(OriginalCode, 1, 12) + '-' + COPYSTR(OriginalCode, 13, 2));

    end;

    procedure Ev(var TC: Code[20]; TN: Integer) K: Integer
    Var
        Text35001002: Label 'Entered information is too small.';
        Text35001003: Label 'Not a number.';

    begin
        IF STRLEN(TC) < TN THEN ERROR(Text35001002);
        IF EVALUATE(K, COPYSTR(TC, TN, 1)) = FALSE THEN ERROR(Text35001003);
    end;


    //
    procedure ExportSpedContribuicoes(DateFrom: Date; DateTo: Date)
    var
        CompInfo: Record "Company Information";
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
        Cust: Record Customer;
        Vend: Record Vendor;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrLine: Record "Purch. Cr. Memo Line";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FileName: Text;

        // Totales VENTAS (para Bloco M)
        SalesPisBase, SalesPisAmt, SalesCofinsBase, SalesCofinsAmt : Decimal;

        // Totales COMPRAS (para Bloco M - créditos)
        PurchPisBase, PurchPisAmt, PurchCofinsBase, PurchCofinsAmt : Decimal;

        // Contadores por registro (Bloco 9)
        Cnt0000, Cnt0110, CntA100, CntA170, CntF100, CntF120, CntM100, CntM200, Cnt9001, Cnt9900, Cnt9990, Cnt9999 : Integer;

        // Aux VENTAS
        CNPJ, UF, IE, IM, CompanyName : Text;
        DocNo, LastDocNo, CustNo : Code[20];
        DocDate: Date;
        DocBase, DocPisBase, DocPisAmt, DocCofinsBase, DocCofinsAmt : Decimal;
        PisJurFound, CofinsJurFound : Boolean;

        // Parámetros/flags de régimen
        PisCumulativo: Boolean; // true = 0,65% / 3% | false = 1,65% / 7,6%

        // Créditos de venta (Sales Cr. Memo)
        CrHdr: Record "Sales Cr.Memo Header";
        CrDate: Date;
        CrBase, CrPisBase, CrPisAmt, CrCofinsBase, CrCofinsAmt : Decimal;
        CrPisFound, CrCofinsFound : Boolean;
        IndOperForCredit: Integer; // 0 = salida (negativos); 1 = estorno (positivos)

        // COMPRAS — Facturas
        PDocBase, PDocPisBase, PDocPisAmt, PDocCofinsBase, PDocCofinsAmt : Decimal;
        PVendNo: Code[20];
        PDocDate: Date;

        // COMPRAS — Notas de crédito
        PCrBase, PCrPisBase, PCrPisAmt, PCrCofinsBase, PCrCofinsAmt : Decimal;
        PCrDate: Date;
    begin
        CRLF[1] := 13; // Carriage Return
        CRLF[2] := 10; // Line Feed

        // === 1) Datos de la empresa (Company Information) ===
        CompInfo.Get();
        CompanyName := CompInfo.Name;
        CNPJ := CompInfo."VAT Registration No."; // CNPJ en estándar
        IE := CompInfo.JXBRIE;
        IM := CompInfo.JXBRIM;
        UF := CopyStr(CompInfo."Country/Region Code", 1, 2); // Cambiá si usás un campo específico

        // Archivo
        FileName := StrSubstNo('SPED_%1_%2.txt', Format(DateFrom, 0, 9), Format(DateTo, 0, 9));
        TempBlob.CreateOutStream(OutStr);

        // === 2) BLOCO 0 (0000 / 0110) ===
        WriteLine(OutStr, StrSubstNo('0000|LECD|013|0|%1|%2|%3|%4|1|%5|',
            Format(DateFrom, 0, 9),
            Format(DateTo, 0, 9),
            SanitizeDigits(CNPJ),
            SanitizeText(CompanyName),
            SanitizeText(UF)));
        Cnt0000 += 1;

        PisCumulativo := true; // traelo desde tu enum 83501 si querés
        if PisCumulativo then
            WriteLine(OutStr, '0110|1|1|1|1|')
        else
            WriteLine(OutStr, '0110|2|1|1|1|');
        Cnt0110 += 1;

        // === 3) BLOCO A (VENTAS) ===
        SalesPisBase := 0;
        SalesPisAmt := 0;
        SalesCofinsBase := 0;
        SalesCofinsAmt := 0;

        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetCurrentKey("Document No.");
        LastDocNo := '';

        if VATEntry.FindSet() then
            repeat
                DocNo := VATEntry."Document No.";
                if (DocNo <> '') and (DocNo <> LastDocNo) then begin
                    LastDocNo := DocNo;

                    if SalesInvHdr.Get(DocNo) then begin
                        CustNo := SalesInvHdr."Sell-to Customer No.";
                        if Cust.Get(CustNo) then;

                        Clear(DocBase);
                        Clear(DocPisBase);
                        Clear(DocPisAmt);
                        Clear(DocCofinsBase);
                        Clear(DocCofinsAmt);
                        PisJurFound := false;
                        CofinsJurFound := false;

                        SumPisCofinsForDocument(DocNo, DateFrom, DateTo, DocPisBase, DocPisAmt, DocCofinsBase, DocCofinsAmt, PisJurFound, CofinsJurFound);
                        DocBase := GetSalesDocServiceBase(SalesInvHdr);
                        DocDate := SalesInvHdr."Posting Date";

                        // A100 factura
                        WriteLine(OutStr, StrSubstNo('A100|0|%1|%2|%3|%4|%5|%6|0,00|%7|',
                            Format(DocDate, 0, 9),
                            SanitizeText(SalesInvHdr."No."),
                            GetDestTaxId(Cust),
                            SanitizeText(Cust.Name),
                            GetMunicipioIBGE(Cust),
                            FormatDecimal(DocBase),
                            FormatDecimal(DocBase)));
                        CntA100 += 1;

                        // A170
                        WriteLine(OutStr, StrSubstNo('A170|1|%1|%2|%3|%4|%5|%6|',
                            'Serviços prestados',
                            FormatDecimal(DocBase),
                            FormatPercent(PisRate(PisCumulativo)),
                            FormatDecimal(DocPisAmt),
                            FormatPercent(CofinsRate(PisCumulativo)),
                            FormatDecimal(DocCofinsAmt)));
                        CntA170 += 1;

                        // Totales ventas
                        SalesPisBase += DocPisBase;
                        SalesPisAmt += DocPisAmt;
                        SalesCofinsBase += DocCofinsBase;
                        SalesCofinsAmt += DocCofinsAmt;
                    end;
                end;
            until VATEntry.Next() = 0;

        // === 3.b) BLOCO A - Créditos de venta (Sales Cr. Memo) ===
        IndOperForCredit := 0; // 0 = salida con negativo; 1 = estorno positivo

        if CrHdr.FindSet() then
            repeat
                Clear(CrBase);
                Clear(CrPisBase);
                Clear(CrPisAmt);
                Clear(CrCofinsBase);
                Clear(CrCofinsAmt);

                CrDate := CrHdr."Posting Date";
                CrBase := GetSalesCrMemoServiceBase(CrHdr);
                CrPisFound := false;
                CrCofinsFound := false;

                SumPisCofinsForSalesCredit(CrHdr."No.", DateFrom, DateTo, CrPisBase, CrPisAmt, CrCofinsBase, CrCofinsAmt, CrPisFound, CrCofinsFound);

                // A100 crédito
                WriteLine(OutStr, StrSubstNo('A100|%1|%2|%3|%4|%5|%6|%7|0,00|%8|',
                    Format(IndOperForCredit),
                    Format(CrDate, 0, 9),
                    SanitizeText(CrHdr."No."),
                    GetDestTaxIdForCr(CrHdr),
                    SanitizeText(CrHdr."Bill-to Name"),
                    GetMunicipioIBGEForCr(CrHdr),
                    FormatDecimal(ChooseSign(CrBase, IndOperForCredit)),
                    FormatDecimal(ChooseSign(CrBase, IndOperForCredit))));
                CntA100 += 1;

                // A170 crédito
                WriteLine(OutStr, StrSubstNo('A170|1|%1|%2|%3|%4|%5|%6|',
                    'Estorno de serviços',
                    FormatDecimal(ChooseSign(CrBase, IndOperForCredit)),
                    FormatPercent(PisRate(PisCumulativo)),
                    FormatDecimal(ChooseSign(CrPisAmt, IndOperForCredit)),
                    FormatPercent(CofinsRate(PisCumulativo)),
                    FormatDecimal(ChooseSign(CrCofinsAmt, IndOperForCredit))));
                CntA170 += 1;

                // Totales ventas (restan)
                if IndOperForCredit = 0 then begin
                    SalesPisBase += CrPisBase;
                    SalesPisAmt += CrPisAmt;
                    SalesCofinsBase += CrCofinsBase;
                    SalesCofinsAmt += CrCofinsAmt;
                end else begin
                    SalesPisBase -= Abs(CrPisBase);
                    SalesPisAmt -= Abs(CrPisAmt);
                    SalesCofinsBase -= Abs(CrCofinsBase);
                    SalesCofinsAmt -= Abs(CrCofinsAmt);
                end;
            until CrHdr.Next() = 0;

        // === 4) BLOCO F (COMPRAS) ===
        PurchPisBase := 0;
        PurchPisAmt := 0;
        PurchCofinsBase := 0;
        PurchCofinsAmt := 0;

        // 4.a) Facturas de compra
        PurchInvHdr.Reset();
        PurchInvHdr.SetRange("Posting Date", DateFrom, DateTo);
        if PurchInvHdr.FindSet() then
            repeat
                Clear(PDocBase);
                Clear(PDocPisBase);
                Clear(PDocPisAmt);
                Clear(PDocCofinsBase);
                Clear(PDocCofinsAmt);

                PDocDate := PurchInvHdr."Posting Date";
                PVendNo := PurchInvHdr."Buy-from Vendor No.";
                if (PVendNo <> '') and Vend.Get(PVendNo) then;

                // Base del documento (servicios/GL/Item según definas tus compras de servicios)
                PDocBase := GetPurchInvServiceBase(PurchInvHdr);

                // Sumar PIS/COFINS por VAT Entry del documento
                SumPisCofinsForPurchase(PurchInvHdr."No.", DateFrom, DateTo, PDocPisBase, PDocPisAmt, PDocCofinsBase, PDocCofinsAmt);

                // F100 (documento de compras)
                // F100|dt_doc|num_doc|Fornecedor|CNPJ|CodMun|vl_doc|vl_base_pis|vl_pis|vl_base_cof|vl_cof|
                WriteLine(OutStr, StrSubstNo('F100|%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|',
                    Format(PDocDate, 0, 9),
                    SanitizeText(PurchInvHdr."No."),
                    SanitizeText(PurchInvHdr."Buy-from Vendor Name"),
                    GetVendorTaxId(Vend),
                    GetMunicipioIBGEForVendor(Vend),
                    FormatDecimal(PDocBase),
                    FormatDecimal(PDocPisBase),
                    FormatDecimal(PDocPisAmt),
                    FormatDecimal(PDocCofinsBase),
                    FormatDecimal(PDocCofinsAmt)));
                CntF100 += 1;

                // F120 (cálculo de créditos PIS/COFINS)
                // F120|vl_base_pis|aliq_pis|vl_pis|vl_base_cof|aliq_cof|vl_cof|
                WriteLine(OutStr, StrSubstNo('F120|%1|%2|%3|%4|%5|%6|',
                    FormatDecimal(PDocPisBase),
                    FormatPercent(PisRate(PisCumulativo)),
                    FormatDecimal(PDocPisAmt),
                    FormatDecimal(PDocCofinsBase),
                    FormatPercent(CofinsRate(PisCumulativo)),
                    FormatDecimal(PDocCofinsAmt)));
                CntF120 += 1;

                // Totales compras (créditos)
                PurchPisBase += PDocPisBase;
                PurchPisAmt += PDocPisAmt;
                PurchCofinsBase += PDocCofinsBase;
                PurchCofinsAmt += PDocCofinsAmt;
            until PurchInvHdr.Next() = 0;

        // 4.b) Notas de crédito de compra (reversan créditos)
        PurchCrHdr.Reset();
        PurchCrHdr.SetRange("Posting Date", DateFrom, DateTo);
        if PurchCrHdr.FindSet() then
            repeat
                Clear(PCrBase);
                Clear(PCrPisBase);
                Clear(PCrPisAmt);
                Clear(PCrCofinsBase);
                Clear(PCrCofinsAmt);

                PCrDate := PurchCrHdr."Posting Date";
                PVendNo := PurchCrHdr."Buy-from Vendor No.";
                if (PVendNo <> '') and Vend.Get(PVendNo) then;

                // Base (negativa)
                PCrBase := GetPurchCrMemoServiceBase(PurchCrHdr);

                // Sumar PIS/COFINS (negativos)
                SumPisCofinsForPurchaseCredit(PurchCrHdr."No.", DateFrom, DateTo, PCrPisBase, PCrPisAmt, PCrCofinsBase, PCrCofinsAmt);

                // F100 crédito de compra (mantenemos signo natural)
                WriteLine(OutStr, StrSubstNo('F100|%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|',
                    Format(PCrDate, 0, 9),
                    SanitizeText(PurchCrHdr."No."),
                    SanitizeText(PurchCrHdr."Buy-from Vendor Name"),
                    GetVendorTaxId(Vend),
                    GetMunicipioIBGEForVendor(Vend),
                    FormatDecimal(PCrBase),
                    FormatDecimal(PCrPisBase),
                    FormatDecimal(PCrPisAmt),
                    FormatDecimal(PCrCofinsBase),
                    FormatDecimal(PCrCofinsAmt)));
                CntF100 += 1;

                // F120 crédito (negativo)
                WriteLine(OutStr, StrSubstNo('F120|%1|%2|%3|%4|%5|%6|',
                    FormatDecimal(PCrPisBase),
                    FormatPercent(PisRate(PisCumulativo)),
                    FormatDecimal(PCrPisAmt),
                    FormatDecimal(PCrCofinsBase),
                    FormatPercent(CofinsRate(PisCumulativo)),
                    FormatDecimal(PCrCofinsAmt)));
                CntF120 += 1;

                // Totales compras (restan — ya vienen negativos)
                PurchPisBase += PCrPisBase;
                PurchPisAmt += PCrPisAmt;
                PurchCofinsBase += PCrCofinsBase;
                PurchCofinsAmt += PCrCofinsAmt;
            until PurchCrHdr.Next() = 0;

        // === 5) BLOCO M (Apuração) — Neto: ventas – compras ===
        // PIS
        WriteLine(OutStr, StrSubstNo('M100|01|%1|%2|%3|0|0|%2|',
            FormatDecimal(SalesPisBase - PurchPisBase),
            FormatDecimal(SalesPisBase - PurchPisBase),
            FormatDecimal(SalesPisAmt - PurchPisAmt)));
        CntM100 += 1;

        // COFINS
        WriteLine(OutStr, StrSubstNo('M200|01|%1|%2|%3|0|0|%2|',
            FormatDecimal(SalesCofinsBase - PurchCofinsBase),
            FormatDecimal(SalesCofinsBase - PurchCofinsBase),
            FormatDecimal(SalesCofinsAmt - PurchCofinsAmt)));
        CntM200 += 1;

        // === 6) BLOCO 9 (Encerramento) ===
        WriteLine(OutStr, '9001|1|');
        Cnt9001 += 1;

        WriteLine(OutStr, Count9900('0000', Cnt0000));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('0110', Cnt0110));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('A100', CntA100));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('A170', CntA170));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('F100', CntF100));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('F120', CntF120));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('M100', CntM100));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('M200', CntM200));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('9001', Cnt9001));
        Cnt9900 += 1;
        WriteLine(OutStr, Count9900('9900', Cnt9900 + 1));
        Cnt9900 += 1; // este mismo

        WriteLine(OutStr, StrSubstNo('9990|%1|', Cnt9001 + Cnt9900 + 1));
        Cnt9990 += 1;
        WriteLine(OutStr, StrSubstNo('9999|%1|', Cnt0000 + Cnt0110 + CntA100 + CntA170 + CntF100 + CntF120 + CntM100 + CntM200 + Cnt9001 + Cnt9900 + Cnt9990 + 1));
        Cnt9999 += 1;

        // === 7) Descargar archivo ===
        DownloadFromStream(TempBlob.CreateInStream(), '', '', FileName, FileName);
    end;

    // ----------------- Helpers -----------------
    local procedure SumPisCofinsForDocument(DocNo: Code[20]; DateFrom: Date; DateTo: Date; var DocPisBase: Decimal; var DocPisAmt: Decimal; var DocCofinsBase: Decimal; var DocCofinsAmt: Decimal; var PisJurFound: Boolean; var CofinsJurFound: Boolean)
    var
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetRange("Document No.", DocNo);

        if VATEntry.FindSet() then
            repeat
                if TaxJur.Get(VATEntry."Tax Jurisdiction Code") then begin
                    case TaxJur.JXBRTaxIdentification of
                        TaxJur.JXBRTaxIdentification::PIS:
                            begin
                                DocPisBase += Abs(VATEntry.Base);
                                DocPisAmt += Abs(VATEntry.Amount);
                                PisJurFound := true;
                            end;
                        TaxJur.JXBRTaxIdentification::COFINS:
                            begin
                                DocCofinsBase += Abs(VATEntry.Base);
                                DocCofinsAmt += Abs(VATEntry.Amount);
                                CofinsJurFound := true;
                            end;
                    end;
                end;
            until VATEntry.Next() = 0;
    end;

    local procedure SumPisCofinsForSalesCredit(DocNo: Code[20]; DateFrom: Date; DateTo: Date; var DocPisBase: Decimal; var DocPisAmt: Decimal; var DocCofinsBase: Decimal; var DocCofinsAmt: Decimal; var PisJurFound: Boolean; var CofinsJurFound: Boolean)
    var
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetRange("Document No.", DocNo);

        if VATEntry.FindSet() then
            repeat
                if TaxJur.Get(VATEntry."Tax Jurisdiction Code") then begin
                    case TaxJur.JXBRTaxIdentification of
                        TaxJur.JXBRTaxIdentification::PIS:
                            begin
                                DocPisBase += -Abs(VATEntry.Base); // negativo por crédito
                                DocPisAmt += -Abs(VATEntry.Amount);
                                PisJurFound := true;
                            end;
                        TaxJur.JXBRTaxIdentification::COFINS:
                            begin
                                DocCofinsBase += -Abs(VATEntry.Base);
                                DocCofinsAmt += -Abs(VATEntry.Amount);
                                CofinsJurFound := true;
                            end;
                    end;
                end;
            until VATEntry.Next() = 0;
    end;

    local procedure GetSalesDocServiceBase(SalesInvHdr: Record "Sales Invoice Header"): Decimal
    var
        SalesInvLine: Record "Sales Invoice Line";
        Total: Decimal;
    begin
        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
        SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account"); // servicios como Item o G/L
        if SalesInvLine.FindSet() then
            repeat
                Total += SalesInvLine."Line Amount";
            until SalesInvLine.Next() = 0;
        exit(Total);
    end;

    local procedure GetSalesCrMemoServiceBase(CrHdr: Record "Sales Cr.Memo Header"): Decimal
    var
        CrLine: Record "Sales Cr.Memo Line";
        Total: Decimal;
    begin
        CrLine.Reset();
        CrLine.SetRange("Document No.", CrHdr."No.");
        CrLine.SetFilter(Type, '%1|%2', CrLine.Type::Item, CrLine.Type::"G/L Account");
        if CrLine.FindSet() then
            repeat
                Total += CrLine."Line Amount";
            until CrLine.Next() = 0;
        exit(-Abs(Total)); // negativo por crédito
    end;

    local procedure GetDestTaxId(Cust: Record Customer): Text
    begin
        exit(SanitizeDigits(Cust."VAT Registration No.")); // CNPJ/CPF del cliente
    end;

    local procedure GetDestTaxIdForCr(CrHdr: Record "Sales Cr.Memo Header"): Text
    var
        Cust: Record Customer;
    begin
        if Cust.Get(CrHdr."Bill-to Customer No.") then
            exit(SanitizeDigits(Cust."VAT Registration No."));
        exit('');
    end;

    local procedure GetMunicipioIBGE(Cust: Record Customer): Text
    begin
        // Devolvé el código IBGE (7 dígitos). Placeholder hasta que lo tomes de tu campo JXBR.
        exit('0000000');
    end;

    local procedure GetMunicipioIBGEForCr(CrHdr: Record "Sales Cr.Memo Header"): Text
    begin
        exit('0000000'); // idem arriba
    end;

    local procedure PisRate(Cumulativo: Boolean): Decimal
    begin
        exit((Cumulativo) ? 0.65 : 1.65);
    end;

    local procedure CofinsRate(Cumulativo: Boolean): Decimal
    begin
        exit((Cumulativo) ? 3.0 : 7.6);
    end;

    local procedure WriteLine(var OutStr: OutStream; Line: Text)
    begin
        OutStr.WriteText(Line + CRLF);
    end;

    local procedure Count9900(RegCode: Text; Count: Integer): Text
    begin
        exit(StrSubstNo('9900|%1|%2|', RegCode, Format(Count)));
    end;

    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, 9)); // ajustá decimal/coma si tu validador lo requiere
    end;

    local procedure FormatPercent(Value: Decimal): Text
    begin
        exit(FormatDecimal(Value));
    end;

    local procedure SanitizeDigits(Value: Text): Text
    var
        c: Char;
        res: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(Value) do begin
            c := Value[i];
            if (c in ['0' .. '9']) then
                res += Format(c);
        end;
        exit(res);
    end;

    local procedure SanitizeText(Value: Text): Text
    begin
        exit(DelChr(Value, '=', '|'));
    end;

    local procedure ChooseSign(Value: Decimal; IndOper: Integer): Decimal
    begin
        if IndOper = 1 then
            exit(Abs(Value)) // estorno
        else
            exit(Value);     // salida con signo natural (negativo para NC)
    end;

    local procedure SumPisCofinsForPurchase(DocNo: Code[20]; DateFrom: Date; DateTo: Date; var DocPisBase: Decimal; var DocPisAmt: Decimal; var DocCofinsBase: Decimal; var DocCofinsAmt: Decimal)
    var
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetRange("Document No.", DocNo);

        if VATEntry.FindSet() then
            repeat
                if TaxJur.Get(VATEntry."Tax Jurisdiction Code") then begin
                    case TaxJur.JXBRTaxIdentification of
                        TaxJur.JXBRTaxIdentification::PIS:
                            begin
                                DocPisBase += Abs(VATEntry.Base);
                                DocPisAmt += Abs(VATEntry.Amount);
                            end;
                        TaxJur.JXBRTaxIdentification::COFINS:
                            begin
                                DocCofinsBase += Abs(VATEntry.Base);
                                DocCofinsAmt += Abs(VATEntry.Amount);
                            end;
                    end;
                end;
            until VATEntry.Next() = 0;
    end;

    local procedure SumPisCofinsForPurchaseCredit(DocNo: Code[20]; DateFrom: Date; DateTo: Date; var DocPisBase: Decimal; var DocPisAmt: Decimal; var DocCofinsBase: Decimal; var DocCofinsAmt: Decimal)
    var
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetRange("Document No.", DocNo);

        if VATEntry.FindSet() then
            repeat
                if TaxJur.Get(VATEntry."Tax Jurisdiction Code") then begin
                    case TaxJur.JXBRTaxIdentification of
                        TaxJur.JXBRTaxIdentification::PIS:
                            begin
                                DocPisBase += -Abs(VATEntry.Base);
                                DocPisAmt += -Abs(VATEntry.Amount);
                            end;
                        TaxJur.JXBRTaxIdentification::COFINS:
                            begin
                                DocCofinsBase += -Abs(VATEntry.Base);
                                DocCofinsAmt += -Abs(VATEntry.Amount);
                            end;
                    end;
                end;
            until VATEntry.Next() = 0;
    end;

    local procedure GetPurchInvServiceBase(Hdr: Record "Purch. Inv. Header"): Decimal
    var
        Line: Record "Purch. Inv. Line";
        Total: Decimal;
    begin
        Line.Reset();
        Line.SetRange("Document No.", Hdr."No.");
        // Ajustá el filtro según cómo contabilices servicios (G/L, Item Servicio, etc.)
        Line.SetFilter(Type, '%1|%2', Line.Type::Item, Line.Type::"G/L Account");
        if Line.FindSet() then
            repeat
                Total += Line."Line Amount";
            until Line.Next() = 0;
        exit(Total);
    end;

    local procedure GetPurchCrMemoServiceBase(Hdr: Record "Purch. Cr. Memo Hdr."): Decimal
    var
        Line: Record "Purch. Cr. Memo Line";
        Total: Decimal;
    begin
        Line.Reset();
        Line.SetRange("Document No.", Hdr."No.");
        Line.SetFilter(Type, '%1|%2', Line.Type::Item, Line.Type::"G/L Account");
        if Line.FindSet() then
            repeat
                Total += Line."Line Amount";
            until Line.Next() = 0;
        exit(-Abs(Total)); // negativo por NC
    end;

    local procedure GetVendorTaxId(Vend: Record Vendor): Text
    begin
        exit(SanitizeDigits(Vend."VAT Registration No.")); // CNPJ do fornecedor
    end;

    local procedure GetMunicipioIBGEForVendor(Vend: Record Vendor): Text
    begin
        exit('0000000'); // reemplazá cuando tengas IBGE en Vendor/Address (JXBR)
    end;

    //DIRF
    procedure ExportDIRF(DateFrom: Date; DateTo: Date)
    var
        CompInfo: Record "Company Information";
        Vend: Record Vendor;
        Wh: Record "JXLTWithholdLedgerEntry";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FileName: Text;
        // Header
        CompanyName, CNPJ, UF : Text;
        // Totales / contadores
        CntH, CntD, CntT : Integer;
        TotBase, TotWithheld : Decimal;
        // Vars línea
        VCode: Code[20];
        VName, VTaxId, TaxCode, DirfNature, CertNo : Text;
        BaseAmt, WithheldAmt : Decimal;
        WhDate: Date;
        CRLF: Text[2];
    begin
        // --- CRLF real ---
        CRLF[1] := 13; // CR
        CRLF[2] := 10; // LF

        // --- Empresa ---
        CompInfo.Get();
        CompanyName := CompInfo.Name;
        CNPJ := SanitizeDigitsDIRF(CompInfo."VAT Registration No."); // CNPJ emisor
        UF := CopyStr(CompInfo."Country/Region Code", 1, 2);

        // --- Archivo ---
        FileName := StrSubstNo('DIRF_%1_%2.txt', Format(DateFrom, 0, 9), Format(DateTo, 0, 9));
        TempBlob.CreateOutStream(OutStr);

        // --- HEADER (H) ---
        // Formato (MVP): H|CNPJ|RazonSocial|Desde|Hasta|UF|
        WriteRawDIRF(OutStr, StrSubstNo('H|%1|%2|%3|%4|%5|',
            CNPJ,
            SanitizeTextDIRF(CompanyName),
            Format(DateFrom, 0, 9),
            Format(DateTo, 0, 9),
            SanitizeTextDIRF(UF)), CRLF);
        CntH += 1;

        // --- DETALLES (D) ---
        // Filtro: Realizadas, por fecha
        Wh.Reset();
        Wh.SetRange(JXLTWitholdingType, Wh.JXLTWitholdingType::Realizada);
        Wh.SetRange(JXLTWitholdingDate, DateFrom, DateTo);

        TotBase := 0;
        TotWithheld := 0;
        if Wh.FindSet() then
            repeat
                // Datos por línea
                VCode := Wh.JXLTVendorCode;
                VName := '';
                VTaxId := '';
                if (VCode <> '') and Vend.Get(VCode) then begin
                    VName := Vend.Name;
                    VTaxId := SanitizeDigitsDIRF(Vend."VAT Registration No."); // CNPJ/CPF proveedor
                end;

                TaxCode := Wh.JXLTTaxCode;                             // tu código (ej: 'IRRF','PIS RET.','CSLL RET.', etc.)
                DirfNature := MapToDirfNatureDIRF(TaxCode);                // mapeo a naturaleza DIRF
                BaseAmt := Wh.JXLTBase;
                if BaseAmt = 0 then
                    BaseAmt := Wh.JXLTCalculationBase;                 // fallback si usás este campo
                WithheldAmt := Wh.JXLTWitholdingAmount;
                WhDate := Wh.JXLTWitholdingDate;
                CertNo := Wh.JXLTWitholdingCertificateNo;

                // Línea detalle (MVP): D|VendorCode|VendorName|VendorTaxId|TaxCode|DirfNature|Fecha|Base|Importe|Cert|
                WriteRawDIRF(OutStr, StrSubstNo('D|%1|%2|%3|%4|%5|%6|%7|%8|%9|',
                    VCode,
                    SanitizeTextDIRF(VName),
                    VTaxId,
                    SanitizeTextDIRF(TaxCode),
                    SanitizeTextDIRF(DirfNature),
                    Format(WhDate, 0, 9),
                    FormatDecimalDIRF(BaseAmt),
                    FormatDecimalDIRF(WithheldAmt),
                    SanitizeTextDIRF(CertNo)), CRLF);
                CntD += 1;

                TotBase += BaseAmt;
                TotWithheld += WithheldAmt;

            until Wh.Next() = 0;

        // --- TRAILER (T) ---
        // Formato (MVP): T|CntH|CntD|CntT|TotBase|TotRet|
        WriteRawDIRF(OutStr, StrSubstNo('T|%1|%2|%3|%4|%5|',
            CntH, CntD, 1, FormatDecimalDIRF(TotBase), FormatDecimalDIRF(TotWithheld)), CRLF);
        CntT += 1;

        // --- Descargar ---
        DownloadFromStream(TempBlob.CreateInStream(), '', '', FileName, FileName);
    end;

    // ---------------- Helpers ----------------

    local procedure WriteRawDIRF(var OutStr: OutStream; Line: Text; CRLF: Text[2])
    begin
        OutStr.WriteText(Line + CRLF);
    end;

    local procedure FormatDecimalDIRF(Value: Decimal): Text
    begin
        // Ajustá a máscara regional que espere tu validador (coma/punto)
        exit(Format(Value, 0, 9));
    end;

    local procedure SanitizeDigitsDIRF(Value: Text): Text
    var
        c: Char;
        res: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(Value) do begin
            c := Value[i];
            if (c in ['0' .. '9']) then
                res += Format(c);
        end;
        exit(res);
    end;

    local procedure SanitizeTextDIRF(Value: Text): Text
    begin
        // Evitar pipes u otros que rompan layout
        exit(DelChr(Value, '=', '|'));
    end;

    local procedure MapToDirfNatureDIRF(TaxCode: Text): Text
    begin
        // 🔁 Ajustá mapeo a tus códigos reales de JXLTTaxCode
        // Ejemplos comunes:
        if StrPos(UpperCase(TaxCode), 'IRPF') > 0 then
            exit('IRRF_PF'); // IR impuesto de renta retenido PF
        if StrPos(UpperCase(TaxCode), 'IRRF') > 0 then
            exit('IRRF_PJ'); // renta retenida PJ
        if StrPos(UpperCase(TaxCode), 'CSLL') > 0 then
            exit('CSLL_RET');
        if StrPos(UpperCase(TaxCode), 'PIS') > 0 then
            exit('PIS_RET');
        if StrPos(UpperCase(TaxCode), 'COFINS') > 0 then
            exit('COFINS_RET');
        if StrPos(UpperCase(TaxCode), 'INSS') > 0 then
            exit('INSS_RET');
        if StrPos(UpperCase(TaxCode), 'ISS') > 0 then
            exit('ISS_RET');

        exit('OTROS');
    end;
    //DIRF END

    //DCTF
    procedure ExportDCTF(DateFrom: Date; DateTo: Date)
    var
        // Empresa
        CompInfo: Record "Company Information";
        CompanyName, CNPJ, UF : Text;

        // I/O
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FileName: Text;
        CRLF: Text[2];

        // VAT (débitos PIS/COFINS)
        SalesPisBase, SalesPisAmt, SalesCofinsBase, SalesCofinsAmt : Decimal;
        PurchPisBase, PurchPisAmt, PurchCofinsBase, PurchCofinsAmt : Decimal;

        // Retenciones federales (créditos contra DCTF)
        Wh: Record "JXLTWithholdLedgerEntry";
        TotIRRF, TotPISRet, TotCofinsRet, TotCSLLRet : Decimal;

        // Contadores
        CntH, CntD, CntT : Integer;

        // Régimen (para tasas si necesitás)
        PisCumulativo: Boolean;
    begin
        // --- CRLF real ---
        CRLF[1] := 13;
        CRLF[2] := 10;

        // --- Empresa ---
        CompInfo.Get();
        CompanyName := CompInfo.Name;
        CNPJ := SanitizeDigitsDCTF(CompInfo."VAT Registration No.");
        UF := CopyStr(CompInfo."Country/Region Code", 1, 2);

        // --- Archivo ---
        FileName := StrSubstNo('DCTF_%1_%2.txt', Format(DateFrom, 0, 9), Format(DateTo, 0, 9));
        TempBlob.CreateOutStream(OutStr);

        // =========================
        // 1) HEADER
        // =========================
        // H|CNPJ|RazonSocial|PeriodoDesde|PeriodoHasta|UF|
        WriteRawDCTF(OutStr, StrSubstNo('H|%1|%2|%3|%4|%5|',
            CNPJ,
            SanitizeTextDCTF(CompanyName),
            Format(DateFrom, 0, 9),
            Format(DateTo, 0, 9),
            SanitizeTextDCTF(UF)), CRLF);
        CntH += 1;

        // =========================
        // 2) DÉBITOS (PIS/COFINS) — VAT Entry
        // =========================
        // Recalculamos como en SPED (ventas – compras – NCs)
        PisCumulativo := true; // si querés, traelo de tu enum 83501 "BR Fiscal Type"

        CalcPisCofinsSalesDCTF(DateFrom, DateTo, SalesPisBase, SalesPisAmt, SalesCofinsBase, SalesCofinsAmt, PisCumulativo);
        CalcPisCofinsPurchDCTF(DateFrom, DateTo, PurchPisBase, PurchPisAmt, PurchCofinsBase, PurchCofinsAmt, PisCumulativo);

        // Neto período
        // PIS
        AddDctfLineDCTF(OutStr, 'PIS', MapToDctfTaxDCTF('PIS'),
            SalesPisBase - PurchPisBase, SalesPisAmt - PurchPisAmt, CRLF, CntD);
        // COFINS
        AddDctfLineDCTF(OutStr, 'COFINS', MapToDctfTaxDCTF('COFINS'),
            SalesCofinsBase - PurchCofinsBase, SalesCofinsAmt - PurchCofinsAmt, CRLF, CntD);

        // =========================
        // 3) CRÉDITOS / RETENCIONES FEDERALES — JXLTWithholdLedgerEntry
        // =========================
        // Consideramos retenciones "Realizadas" en el período: IRRF (IRPF/IRPJ fuente), PIS Ret., COFINS Ret., CSLL Ret.
        TotIRRF := 0;
        TotPISRet := 0;
        TotCofinsRet := 0;
        TotCSLLRet := 0;

        Wh.Reset();
        Wh.SetRange(JXLTWitholdingType, Wh.JXLTWitholdingType::Realizada);
        Wh.SetRange(JXLTWitholdingDate, DateFrom, DateTo);
        if Wh.FindSet() then
            repeat
                case UpperCase(Wh.JXLTTaxCode) of
                    // Ajustá a tus códigos reales de "Configuración Retención Impuestos"
                    'IRRF', 'IRPF', 'IRPF RET.', 'IRPF RET', 'IRRF RET.':
                        TotIRRF += Wh.JXLTWitholdingAmount;
                    'PIS RET.', 'PIS RET', 'PIS_RET':
                        TotPISRet += Wh.JXLTWitholdingAmount;
                    'COFINS RET.', 'COFINS RET', 'COFINS_RET':
                        TotCofinsRet += Wh.JXLTWitholdingAmount;
                    'CSLL RET.', 'CSLL RET', 'CSLL_RET', 'CSL RET.':
                        TotCSLLRet += Wh.JXLTWitholdingAmount;
                end;
            until Wh.Next() = 0;

        // Emisión de líneas de crédito (valores positivos como créditos a compensar)
        if TotIRRF <> 0 then
            AddDctfCreditLineDCTF(OutStr, 'IRRF', MapToDctfTaxDCTF('IRRF'), TotIRRF, CRLF, CntD);
        if TotPISRet <> 0 then
            AddDctfCreditLineDCTF(OutStr, 'PIS_RET', MapToDctfTaxDCTF('PIS_RET'), TotPISRet, CRLF, CntD);
        if TotCofinsRet <> 0 then
            AddDctfCreditLineDCTF(OutStr, 'COFINS_RET', MapToDctfTaxDCTF('COFINS_RET'), TotCofinsRet, CRLF, CntD);
        if TotCSLLRet <> 0 then
            AddDctfCreditLineDCTF(OutStr, 'CSLL_RET', MapToDctfTaxDCTF('CSLL_RET'), TotCSLLRet, CRLF, CntD);

        // =========================
        // 4) TRAILER
        // =========================
        // T|CntH|CntD|CntT|
        WriteRawDCTF(OutStr, StrSubstNo('T|%1|%2|%3|', CntH, CntD, 1), CRLF);
        CntT += 1;

        // Descargar
        DownloadFromStream(TempBlob.CreateInStream(), '', '', FileName, FileName);
    end;

    // ---------- Helpers core ----------

    local procedure AddDctfLineDCTF(var OutStr: OutStream; TaxName: Text; DctfTaxCode: Text; BaseAmt: Decimal; TaxAmt: Decimal; CRLF: Text[2]; var CntD: Integer)
    begin
        // D|TaxName|DCTFCode|Base|Impuesto|Tipo=DEBITO|
        WriteRawDCTF(OutStr, StrSubstNo('D|%1|%2|%3|%4|DEBITO|',
            SanitizeTextDCTF(TaxName),
            SanitizeTextDCTF(DctfTaxCode),
            FormatDecimalDCTF(BaseAmt),
            FormatDecimalDCTF(TaxAmt)), CRLF);
        CntD += 1;
    end;

    local procedure AddDctfCreditLineDCTF(var OutStr: OutStream; TaxName: Text; DctfTaxCode: Text; CreditAmt: Decimal; CRLF: Text[2]; var CntD: Integer)
    begin
        // D|TaxName|DCTFCode|Base=0|Importe=Crédito|Tipo=CREDITO|
        WriteRawDCTF(OutStr, StrSubstNo('D|%1|%2|%3|%4|CREDITO|',
            SanitizeTextDCTF(TaxName),
            SanitizeTextDCTF(DctfTaxCode),
            '0',
            FormatDecimalDCTF(CreditAmt)), CRLF);
        CntD += 1;
    end;

    local procedure MapToDctfTaxDCTF(TaxName: Text): Text
    begin
        // 🔁 Ajustá al código oficial DCTF (receita/código DARF) que uses en tu cliente
        case UpperCase(TaxName) of
            'PIS':
                exit('PIS');
            'COFINS':
                exit('COFINS');
            'IRRF', 'IRPF':
                exit('IRRF');
            'PIS_RET':
                exit('PIS_RET');
            'COFINS_RET':
                exit('COFINS_RET');
            'CSLL_RET':
                exit('CSLL_RET');
            'CSLL':
                exit('CSLL');
            'IRPJ':
                exit('IRPJ');
        end;
        exit(UpperCase(TaxName));
    end;

    // ---------- Cálculo PIS/COFINS (similar SPED) ----------

    local procedure CalcPisCofinsSalesDCTF(DateFrom: Date; DateTo: Date; var PisBase: Decimal; var PisAmt: Decimal; var CofBase: Decimal; var CofAmt: Decimal; PisCumulativo: Boolean)
    var
        VATEntry: Record "VAT Entry";
        SalesInvHdr: Record "Sales Invoice Header";
        CrHdr: Record "Sales Cr.Memo Header";
        TaxJur: Record "Tax Jurisdiction";
        DocNo: Code[20];
        LastDoc: Code[20];
        DocPisBase, DocPisAmt, DocCofBase, DocCofAmt : Decimal;
    begin
        PisBase := 0;
        PisAmt := 0;
        CofBase := 0;
        CofAmt := 0;

        // Ventas (facturas)
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetCurrentKey("Document No.");
        LastDoc := '';
        if VATEntry.FindSet() then
            repeat
                DocNo := VATEntry."Document No.";
                if (DocNo <> '') and (DocNo <> LastDoc) then begin
                    LastDoc := DocNo;
                    if SalesInvHdr.Get(DocNo) then begin
                        Clear(DocPisBase);
                        Clear(DocPisAmt);
                        Clear(DocCofBase);
                        Clear(DocCofAmt);
                        SumFromVatByJurDCTF(DocNo, DateFrom, DateTo, DocPisBase, DocPisAmt, DocCofBase, DocCofAmt);
                        PisBase += DocPisBase;
                        PisAmt += DocPisAmt;
                        CofBase += DocCofBase;
                        CofAmt += DocCofAmt;
                    end;
                end;
            until VATEntry.Next() = 0;

        // Ventas (notas de crédito)
        CrHdr.Reset();
        CrHdr.SetRange("Posting Date", DateFrom, DateTo);
        if CrHdr.FindSet() then
            repeat
                Clear(DocPisBase);
                Clear(DocPisAmt);
                Clear(DocCofBase);
                Clear(DocCofAmt);
                SumFromVatByJurDCTF(CrHdr."No.", DateFrom, DateTo, DocPisBase, DocPisAmt, DocCofBase, DocCofAmt);
                // Créditos restan
                PisBase -= Abs(DocPisBase);
                PisAmt -= Abs(DocPisAmt);
                CofBase -= Abs(DocCofBase);
                CofAmt -= Abs(DocCofAmt);
            until CrHdr.Next() = 0;
    end;

    local procedure CalcPisCofinsPurchDCTF(DateFrom: Date; DateTo: Date; var PisBase: Decimal; var PisAmt: Decimal; var CofBase: Decimal; var CofAmt: Decimal; PisCumulativo: Boolean)
    var
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        DocPisBase, DocPisAmt, DocCofBase, DocCofAmt : Decimal;
    begin
        PisBase := 0;
        PisAmt := 0;
        CofBase := 0;
        CofAmt := 0;

        // Compras (facturas) — créditos
        PurchInvHdr.Reset();
        PurchInvHdr.SetRange("Posting Date", DateFrom, DateTo);
        if PurchInvHdr.FindSet() then
            repeat
                Clear(DocPisBase);
                Clear(DocPisAmt);
                Clear(DocCofBase);
                Clear(DocCofAmt);
                SumFromVatByJurDCTF(PurchInvHdr."No.", DateFrom, DateTo, DocPisBase, DocPisAmt, DocCofBase, DocCofAmt);
                PisBase += DocPisBase;
                PisAmt += DocPisAmt;
                CofBase += DocCofBase;
                CofAmt += DocCofAmt;
            until PurchInvHdr.Next() = 0;

        // Compras (notas de crédito) — reversa créditos
        PurchCrHdr.Reset();
        PurchCrHdr.SetRange("Posting Date", DateFrom, DateTo);
        if PurchCrHdr.FindSet() then
            repeat
                Clear(DocPisBase);
                Clear(DocPisAmt);
                Clear(DocCofBase);
                Clear(DocCofAmt);
                SumFromVatByJurDCTF(PurchCrHdr."No.", DateFrom, DateTo, DocPisBase, DocPisAmt, DocCofBase, DocCofAmt);
                PisBase -= Abs(DocPisBase);
                PisAmt -= Abs(DocPisAmt);
                CofBase -= Abs(DocCofBase);
                CofAmt -= Abs(DocCofAmt);
            until PurchCrHdr.Next() = 0;
    end;

    local procedure SumFromVatByJurDCTF(DocNo: Code[20]; DateFrom: Date; DateTo: Date; var PisBase: Decimal; var PisAmt: Decimal; var CofBase: Decimal; var CofAmt: Decimal)
    var
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetRange("Document No.", DocNo);

        if VATEntry.FindSet() then
            repeat
                if TaxJur.Get(VATEntry."Tax Jurisdiction Code") then begin
                    case TaxJur.JXBRTaxIdentification of
                        TaxJur.JXBRTaxIdentification::PIS:
                            begin
                                PisBase += Abs(VATEntry.Base);
                                PisAmt += Abs(VATEntry.Amount);
                            end;
                        TaxJur.JXBRTaxIdentification::COFINS:
                            begin
                                CofBase += Abs(VATEntry.Base);
                                CofAmt += Abs(VATEntry.Amount);
                            end;
                    end;
                end;
            until VATEntry.Next() = 0;
    end;

    // ---------- Utilidades ----------

    local procedure WriteRawDCTF(var OutStr: OutStream; Line: Text; CRLF: Text[2])
    begin
        OutStr.WriteText(Line + CRLF);
    end;

    local procedure SanitizeDigitsDCTF(Value: Text): Text
    var
        c: Char;
        res: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(Value) do begin
            c := Value[i];
            if (c in ['0' .. '9']) then
                res += Format(c);
        end;
        exit(res);
    end;

    local procedure SanitizeTextDCTF(Value: Text): Text
    begin
        exit(DelChr(Value, '=', '|'));
    end;

    local procedure FormatDecimalDCTF(Value: Decimal): Text
    begin
        exit(Format(Value, 0, 9)); // ajustá decimal/coma según validador
    end;
    //DCTF END

    //LFS
    procedure ExportLFS(DateFrom: Date; DateTo: Date)
    var
        // Empresa
        CompInfo: Record "Company Information";
        CompanyName, CNPJ, UF, IM : Text;

        // Datos cliente/doc
        Cust: Record Customer;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesCrHdr: Record "Sales Cr.Memo Header";

        // VAT
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";

        // I/O
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FileName: Text;
        CRLF: Text[2];

        // Contadores / totales
        CntH, CntD, CntT : Integer;
        TotServ, TotBaseISS, TotISS : Decimal;

        // Vars por doc
        DocNo: Code[20];
        DocDate: Date;
        DocServVal, DocISSBase, DocISSAmt : Decimal;
        DestName, DestTaxId, DestIBGE : Text;
        Rps: Text; // si tenés Nº RPS/NFS-e en un campo JXBR, podés traerlo aquí
        NBSLC116: Text; // código de servicio (LC 116) si lo tenés
    begin
        // --- CRLF real ---
        CRLF[1] := 13;
        CRLF[2] := 10;

        // --- Empresa ---
        CompInfo.Get();
        CompanyName := CompInfo.Name;
        CNPJ := SanitizeDigitsLFS(CompInfo."VAT Registration No.");
        UF := CopyStr(CompInfo."Country/Region Code", 1, 2);
        IM := CompInfo.JXBRIM; // Inscrição Municipal (campo que agregaste)

        // --- Archivo ---
        FileName := StrSubstNo('LFS_%1_%2.txt', Format(DateFrom, 0, 9), Format(DateTo, 0, 9));
        TempBlob.CreateOutStream(OutStr);

        // =========================
        // 1) HEADER
        // =========================
        // H|CNPJ|RazaoSocial|IM|UF|PeriodoDesde|PeriodoHasta|
        WriteRawLFS(OutStr, StrSubstNo('H|%1|%2|%3|%4|%5|%6|',
            CNPJ,
            SanitizeTextLFS(CompanyName),
            SanitizeTextLFS(IM),
            SanitizeTextLFS(UF),
            Format(DateFrom, 0, 9),
            Format(DateTo, 0, 9)), CRLF);
        CntH += 1;

        // =========================
        // 2) DETALLES – FACTURAS
        // =========================
        // Por cada factura: calculamos Base/ISS desde VATEntry (Jurisdicción = ISS)
        TotServ := 0;
        TotBaseISS := 0;
        TotISS := 0;

        SalesInvHdr.Reset();
        SalesInvHdr.SetRange("Posting Date", DateFrom, DateTo);
        if SalesInvHdr.FindSet() then
            repeat
                Clear(DocServVal);
                Clear(DocISSBase);
                Clear(DocISSAmt);
                DocNo := SalesInvHdr."No.";
                DocDate := SalesInvHdr."Posting Date";

                // Totales del servicio (líneas)
                DocServVal := GetSalesServiceAmountLFS(SalesInvHdr);

                // ISS (VAT Entry)
                SumISSFromVATLFS(DocNo, DateFrom, DateTo, DocISSBase, DocISSAmt);

                // Destinatario
                DestName := '';
                DestTaxId := '';
                DestIBGE := '0000000';
                if Cust.Get(SalesInvHdr."Sell-to Customer No.") then begin
                    DestName := Cust.Name;
                    DestTaxId := SanitizeDigitsLFS(Cust."VAT Registration No."); // CNPJ/CPF
                    DestIBGE := GetMunicipioIBGELFS(Cust);                       // completar cuando tengas campo JXBR
                end;

                // Si no hay movimiento ISS, igual registramos el documento (exento al 0) — opcional
                // D|Data|Tipo(FT)|DocNo|RPS|NFS-e|DestNome|DestTaxId|CodMun|ValServ|BaseISS|Aliq%|ValISS|Sit|
                WriteRawLFS(OutStr, StrSubstNo('D|%1|FT|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11|N|',
                    Format(DocDate, 0, 9),
                    SanitizeTextLFS(DocNo),
                    SanitizeTextLFS(GetRpsForInvoiceLFS(SalesInvHdr)), // si no tenés, deja en blanco
                    SanitizeTextLFS(GetNfseForInvoiceLFS(SalesInvHdr)), // si no tenés, deja en blanco
                    SanitizeTextLFS(DestName),
                    DestTaxId,
                    DestIBGE,
                    FormatDecimalLFS(DocServVal),
                    FormatDecimalLFS(DocISSBase),
                    FormatPercentLFS(CalcIssRateLFS(DocISSBase, DocISSAmt)),
                    FormatDecimalLFS(DocISSAmt)), CRLF);
                CntD += 1;

                TotServ += DocServVal;
                TotBaseISS += DocISSBase;
                TotISS += DocISSAmt;

            until SalesInvHdr.Next() = 0;

        // =========================
        // 3) DETALLES – NOTAS DE CRÉDITO
        // =========================
        SalesCrHdr.Reset();
        SalesCrHdr.SetRange("Posting Date", DateFrom, DateTo);
        if SalesCrHdr.FindSet() then
            repeat
                Clear(DocServVal);
                Clear(DocISSBase);
                Clear(DocISSAmt);
                DocNo := SalesCrHdr."No.";
                DocDate := SalesCrHdr."Posting Date";

                // Valor servicio (negativo)
                DocServVal := GetSalesCrServiceAmountLFS(SalesCrHdr);

                // ISS (negativo)
                SumISSFromVATLFS(DocNo, DateFrom, DateTo, DocISSBase, DocISSAmt);
                DocISSBase := -Abs(DocISSBase);
                DocISSAmt := -Abs(DocISSAmt);

                DestName := '';
                DestTaxId := '';
                DestIBGE := '0000000';
                if Cust.Get(SalesCrHdr."Bill-to Customer No.") then begin
                    DestName := SalesCrHdr."Bill-to Name";
                    DestTaxId := SanitizeDigitsLFS(Cust."VAT Registration No.");
                    DestIBGE := GetMunicipioIBGELFS(Cust);
                end;

                // Tipo = NC
                WriteRawLFS(OutStr, StrSubstNo('D|%1|NC|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11|N|',
                    Format(DocDate, 0, 9),
                    SanitizeTextLFS(DocNo),
                    SanitizeTextLFS(GetRpsForCrLFS(SalesCrHdr)),
                    SanitizeTextLFS(GetNfseForCrLFS(SalesCrHdr)),
                    SanitizeTextLFS(DestName),
                    DestTaxId,
                    DestIBGE,
                    FormatDecimalLFS(DocServVal),
                    FormatDecimalLFS(DocISSBase),
                    FormatPercentLFS(CalcIssRateLFS(DocISSBase, DocISSAmt)), // da positivo si usás Abs en cálculo
                    FormatDecimalLFS(DocISSAmt)), CRLF);
                CntD += 1;

                TotServ += DocServVal;
                TotBaseISS += DocISSBase;
                TotISS += DocISSAmt;

            until SalesCrHdr.Next() = 0;

        // =========================
        // 4) TRAILER
        // =========================
        // T|CntH|CntD|CntT|TotServ|TotBaseISS|TotISS|
        WriteRawLFS(OutStr, StrSubstNo('T|%1|%2|%3|%4|%5|%6|',
            1, CntD, 1,
            FormatDecimalLFS(TotServ),
            FormatDecimalLFS(TotBaseISS),
            FormatDecimalLFS(TotISS)), CRLF);
        CntT += 1;

        // Descargar
        DownloadFromStream(TempBlob.CreateInStream(), '', '', FileName, FileName);
    end;

    // ================= Helpers =================

    local procedure SumISSFromVATLFS(DocNo: Code[20]; DateFrom: Date; DateTo: Date; var BaseISS: Decimal; var ValISS: Decimal)
    var
        VATEntry: Record "VAT Entry";
        TaxJur: Record "Tax Jurisdiction";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", DateFrom, DateTo);
        VATEntry.SetRange("Document No.", DocNo);

        if VATEntry.FindSet() then
            repeat
                if TaxJur.Get(VATEntry."Tax Jurisdiction Code") then begin
                    case TaxJur.JXBRTaxIdentification of
                        TaxJur.JXBRTaxIdentification::ISS:
                            begin
                                BaseISS += Abs(VATEntry.Base);
                                ValISS += Abs(VATEntry.Amount);
                            end;
                    // Si manejás retención de ISS en pagos y querés reportarla acá:
                    // TaxJur.JXBRTaxIdentification::"ISS Ret." -> acumular aparte si corresponde
                    end;
                end;
            until VATEntry.Next() = 0;
    end;

    local procedure GetSalesServiceAmountLFS(Hdr: Record "Sales Invoice Header"): Decimal
    var
        Line: Record "Sales Invoice Line";
        Total: Decimal;
    begin
        Line.Reset();
        Line.SetRange("Document No.", Hdr."No.");
        // Si tus servicios son G/L o Item Servicio
        Line.SetFilter(Type, '%1|%2', Line.Type::Item, Line.Type::"G/L Account");
        if Line.FindSet() then
            repeat
                Total += Line."Line Amount";
            until Line.Next() = 0;
        exit(Total);
    end;

    local procedure GetSalesCrServiceAmountLFS(Hdr: Record "Sales Cr.Memo Header"): Decimal
    var
        Line: Record "Sales Cr.Memo Line";
        Total: Decimal;
    begin
        Line.Reset();
        Line.SetRange("Document No.", Hdr."No.");
        Line.SetFilter(Type, '%1|%2', Line.Type::Item, Line.Type::"G/L Account");
        if Line.FindSet() then
            repeat
                Total += Line."Line Amount";
            until Line.Next() = 0;
        exit(-Abs(Total)); // negativo por NC
    end;

    local procedure CalcIssRateLFS(BaseISS: Decimal; ValISS: Decimal): Decimal
    begin
        if Abs(BaseISS) = 0 then
            exit(0);
        exit(Round(100 * Abs(ValISS) / Abs(BaseISS), 0.00001, '='));
    end;

    local procedure GetMunicipioIBGELFS(Cust: Record Customer): Text
    begin
        // Reemplazar por tu campo JXBR de IBGE cuando lo tengas cargado
        exit('0000000');
    end;

    local procedure GetRpsForInvoiceLFS(Hdr: Record "Sales Invoice Header"): Text
    begin
        // Si tenés Nº RPS/NFS-e en campos JXBR*, devolverlos aquí
        exit('');
    end;

    local procedure GetNfseForInvoiceLFS(Hdr: Record "Sales Invoice Header"): Text
    begin
        exit('');
    end;

    local procedure GetRpsForCrLFS(Hdr: Record "Sales Cr.Memo Header"): Text
    begin
        exit('');
    end;

    local procedure GetNfseForCrLFS(Hdr: Record "Sales Cr.Memo Header"): Text
    begin
        exit('');
    end;

    local procedure WriteRawLFS(var OutStr: OutStream; Line: Text; CRLF: Text[2])
    begin
        OutStr.WriteText(Line + CRLF);
    end;

    local procedure FormatDecimalLFS(Value: Decimal): Text
    begin
        exit(Format(Value, 0, 9)); // ajustá formato decimal (coma/punto) si lo pide el municipio
    end;

    local procedure FormatPercentLFS(Value: Decimal): Text
    begin
        exit(FormatDecimalLFS(Value));
    end;

    local procedure SanitizeDigitsLFS(Value: Text): Text
    var
        c: Char;
        res: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(Value) do begin
            c := Value[i];
            if (c in ['0' .. '9']) then
                res += Format(c);
        end;
        exit(res);
    end;

    local procedure SanitizeTextLFS(Value: Text): Text
    begin
        exit(DelChr(Value, '=', '|'));
    end;
    //LFS END

    var
        CRLF: Text[2];

}