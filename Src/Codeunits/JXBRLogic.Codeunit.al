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
}