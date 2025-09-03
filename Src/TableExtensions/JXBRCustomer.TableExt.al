tableextension 83503 JXBRCustomer extends Customer
{
    fields
    {
        field(83500; JXBRCNPJ; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'C.N.P.J.';

            trigger OnValidate()
            var
                JXBRLogic: Codeunit JXBRLogic;
            begin
                if CompanyInfo.JXIsBrasil() then
                    JXBRLogic.ValidateCNPJCPF(xrec.JXBRCNPJ, Rec.JXBRCNPJ, Rec.JXFiscalType, Rec.JXBRGovernmentCompany, Rec);
            end;
        }

        field(83501; JXBRIE; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'I.E';

            trigger OnValidate()
            var
                JXLTFiscalType: Record JXLTFiscalType;
            begin
                if CompanyInfo.JXIsBrasil() then begin
                    JXLTFiscalType.Reset();
                    JXLTFiscalType.SetRange("No.", Rec.JXFiscalType);
                    if JXLTFiscalType.FindFirst() then
                        JXLTFiscalType.TestField(JXBRFiscalType);

                    IF JXLTFiscalType.JXBRFiscalType = JXLTFiscalType.JXBRFiscalType::EXTERIOR THEN
                        ERROR(Text83500);

                    IF (xRec.JXBRIE <> Rec.JXBRIE) AND (Rec.JXBRIE <> '') AND
                       (UPPERCASE(JXBRIE) <> 'ISENTO') THEN BEGIN
                        IF (LocHideDialog) OR (NOT GUIALLOWED) THEN
                            ValidateIE()
                        ELSE
                            IF CONFIRM(Text83502, TRUE) THEN
                                ValidateIE()
                            ELSE
                                JXBRIEValidate := FALSE;

                    END
                    ELSE
                        IF (xRec.JXBRIE <> Rec.JXBRIE) AND (Rec.JXBRIE = '') THEN
                            JXBRIEValidate := FALSE;
                end;
            end;
        }

        field(83502; JXBRIM; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'I.M';
        }

        field(83503; JXBRGovernmentCompany; Boolean)
        {
            Caption = 'Government Company';
            DataClassification = CustomerContent;
        }

        field(83504; JXBRIEValidate; Boolean)
        {
            Caption = 'I.E. Validado';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        addlast(DropDown; JXBRCNPJ)
        { }
    }

    trigger OnModify()
    begin
        if CompanyInfo.JXIsBrasil() then begin
            if (JXBRCNPJ <> '') and ("VAT Registration No." = '') then
                "VAT Registration No." := JXBRCNPJ;

            if (JXBRCNPJ = '') and ("VAT Registration No." <> '') then
                JXBRCNPJ := "VAT Registration No.";
        end;
    end;

    procedure SetLocHideDialog(lvLocHideDialog: Boolean)
    begin
        LocHideDialog := lvLocHideDialog;
    end;

    procedure ValidateIE()
    Var
        BRCust: Record Customer;
    begin
        BRCust.reset();
        BRCust.SETRANGE(JXFiscalType, Rec.JXFiscalType);
        BRCust.SETRANGE(JXBRIE, Rec.JXBRIE);
        IF BRCust.FindFirst() AND (BRCust."No." <> rec."No.") THEN
            ERROR(Text83503, BRCust."No.", rec.Name);
        InscCheck(rec);
        JXBRIEValidate := TRUE;
    end;

    procedure InscCheck(Customer: Record "Customer")
    var
        "Dígitos": Code[20];
        Estadual: Code[20];
        D: Integer;
        Inscription: Integer;
        P: Integer;
        Peso: array[20] of Integer;
        Result: Integer;
        Soma: Integer;
        IEValida: Text[20];
    begin
        Customer.TESTFIELD("Territory Code");
        IF Customer."Territory Code" = 'SP' THEN BEGIN
            JXBRIE := COPYSTR('000000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 12);
            IF STRLEN(JXBRIE) <> 12 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            i := 8;
            Peso[1] := 1;
            Peso[2] := 3;
            Peso[3] := 4;
            Peso[4] := 5;
            Peso[5] := 6;
            Peso[6] := 7;
            Peso[7] := 8;
            Peso[8] := 10;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;

            UNTIL i = 0;
            Result := Result MOD 11;
            IF STRLEN(FORMAT(Result)) = 2 THEN
                EVALUATE(Result, COPYSTR(FORMAT(Result), 2, 1));
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            i := 11;
            Peso[1] := 3;
            Peso[2] := 2;
            Peso[3] := 10;
            Peso[4] := 9;
            Peso[5] := 8;
            Peso[6] := 7;
            Peso[7] := 6;
            Peso[8] := 5;
            Peso[9] := 4;
            Peso[10] := 3;
            Peso[11] := 2;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;

            UNTIL i = 0;
            Result := Result MOD 11;
            IF STRLEN(FORMAT(Result)) = 2 THEN
                EVALUATE(Result, COPYSTR(FORMAT(Result), 2, 1));
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 12, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 3) + '.' + COPYSTR(JXBRIE, 4, 3) + '.' + COPYSTR(JXBRIE, 7, 3) + '.' + COPYSTR(JXBRIE, 10, 3);
            EXIT;
        END;
        IF Customer."Territory Code" = 'RJ' THEN BEGIN
            JXBRIE := COPYSTR('00000000' + JXBRIE, STRLEN(JXBRIE) + 1, 8);
            IF STRLEN(JXBRIE) <> 8 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 2;
            Peso[2] := 7;
            Peso[3] := 6;
            Peso[4] := 5;
            Peso[5] := 4;
            Peso[6] := 3;
            Peso[7] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 8;
            Result := Result MOD 11;
            IF Result <= 1 THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF STRLEN(FORMAT(Result)) = 2 THEN
                EVALUATE(Result, COPYSTR(FORMAT(Result), 2, 1));
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 8, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 3) + '.' + COPYSTR(JXBRIE, 6, 2) + '-' + COPYSTR(JXBRIE, 8, 1);
            EXIT;
        END;
        IF Customer."Territory Code" = 'AC' THEN BEGIN
            JXBRIE := COPYSTR('0000000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 13);
            IF STRLEN(JXBRIE) <> 13 THEN
                ERROR(Text83501);
            IEValida := COPYSTR(JXBRIE, 1, 11);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 4;
            Peso[2] := 3;
            Peso[3] := 2;
            Peso[4] := 9;
            Peso[5] := 8;
            Peso[6] := 7;
            Peso[7] := 6;
            Peso[8] := 5;
            Peso[9] := 4;
            Peso[10] := 3;
            Peso[11] := 2;
            i := 1;
            REPEAT
                EVALUATE(Character, COPYSTR(IEValida, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
                ;
            UNTIL i = 12;
            Result := Result MOD 11;
            IF Result = 0 THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF STRLEN(FORMAT(Result)) = 2 THEN
                EVALUATE(Result, COPYSTR(FORMAT(Result), 2, 1));
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 12, 1) THEN
                ERROR(Text83501);
            IEValida := IEValida + FORMAT(Result);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 5;
            Peso[2] := 4;
            Peso[3] := 3;
            Peso[4] := 2;
            Peso[5] := 9;
            Peso[6] := 8;
            Peso[7] := 7;
            Peso[8] := 6;
            Peso[9] := 5;
            Peso[10] := 4;
            Peso[11] := 3;
            Peso[12] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(IEValida, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 13;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF STRLEN(FORMAT(Result)) = 2 THEN
                EVALUATE(Result, COPYSTR(FORMAT(Result), 2, 1));
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 13, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 3) + '.' + COPYSTR(JXBRIE, 6, 3) + '/' + COPYSTR(JXBRIE, 9, 3)
                                          + '-' + COPYSTR(JXBRIE, 12, 2);
            EXIT;
        END;
        IF Customer."Territory Code" = 'AL' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 8;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;
            END;
            UNTIL i = 0;
            Result := Result * 10;
            Result := Result MOD 11;
            IF Result = 10 THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
        END;
        IF Customer."Territory Code" = 'AP' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            EVALUATE(Inscription, COPYSTR(JXBRIE, 1, 8));
            IF (Inscription >= 3000001) AND (Inscription <= 3017000) THEN BEGIN
                P := 5;
                D := 0;
            END
            ELSE
                IF (Inscription >= 3017001) AND (Inscription <= 3019022) THEN BEGIN
                    P := 9;
                    D := 1;
                END
                ELSE
                    IF Inscription >= 3019023 THEN BEGIN
                        P := 0;
                        D := 0;
                    END;
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
            END;
            UNTIL i = 10;
            Result := P + Result;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF Result = 10 THEN
                Result := 0
            ELSE
                IF Result = 11 THEN
                    Result := D;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
        END;
        IF Customer."Territory Code" = 'AM' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
            END;
            UNTIL i = 9;
            IF Result < 11 THEN
                Result := 11 - Result
            ELSE BEGIN
                Result := Result MOD 11;
                IF Result <= 1 THEN
                    Result := 0
                ELSE
                    Result := 11 - Result;
            END;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
        END;
        IF Customer."Territory Code" = 'BA' THEN BEGIN
            IF (STRLEN(JXBRIE) <> 9) AND (STRLEN(JXBRIE) <> 8) THEN
                ERROR(Text83501);
            IF (STRLEN(JXBRIE) = 9) THEN BEGIN
                //Para inscrições cujo segundo dígito é 0, 1, 2, 3, 4, 5, 8 cálculo pelo módulo 10
                IF COPYSTR(JXBRIE, 2, 1) IN ['0', '1', '2', '3', '4', '5', '8'] THEN
                  //Cálculo do 2º dígito
                  BEGIN
                    CLEAR(Result);
                    CLEAR(Peso);
                    Peso[1] := 8;
                    Peso[2] := 7;
                    Peso[3] := 6;
                    Peso[4] := 5;
                    Peso[5] := 4;
                    Peso[6] := 3;
                    Peso[7] := 2;
                    i := 1;
                    REPEAT
                    BEGIN
                        EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                        IF i <> 0 THEN
                            Result := Result + Character * Peso[i];
                        i := i + 1;
                    END;
                    UNTIL i = 8;
                    Result := Result MOD 10;
                    IF Result = 0 THEN
                        Result := 0
                    ELSE BEGIN
                        Result := 10 - Result
                    END;
                    //Quando o resto for igual a 0 (zero) o segundo digito é igual a 0 (zero).
                    IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                        ERROR(Text83501);
                    // Cálculo do 1º dígito
                    CLEAR(Result);
                    CLEAR(Peso);
                    Peso[1] := 9;
                    Peso[2] := 8;
                    Peso[3] := 7;
                    Peso[4] := 6;
                    Peso[5] := 5;
                    Peso[6] := 4;
                    Peso[7] := 3;
                    Peso[8] := 2;
                    i := 1;
                    Inscriptiontxt := COPYSTR(JXBRIE, 1, 7) + COPYSTR(JXBRIE, 9, 1);
                    REPEAT
                    BEGIN
                        EVALUATE(Character, COPYSTR(FORMAT(Inscriptiontxt), i, 1));
                        IF i <> 0 THEN
                            Result := Result + Character * Peso[i];
                        i := i + 1;
                    END;
                    UNTIL i = 9;
                    Result := Result MOD 10;
                    IF Result = 0 THEN
                        Result := 0
                    ELSE BEGIN
                        Result := 10 - Result
                    END;
                    IF FORMAT(Result) <> COPYSTR(JXBRIE, 8, 1) THEN
                        ERROR(Text83501);
                    JXBRIE := COPYSTR(JXBRIE, 1, 7) + '-' + COPYSTR(JXBRIE, 8, 2)
                END
                ELSE
                    //Para inscrições cujo segundo dígito é 6, 7 ou 9 cálculo pelo módulo 11
                    IF COPYSTR(JXBRIE, 2, 1) IN ['6', '7', '9'] THEN
                      //Cálculo do 2º dígito
                      BEGIN
                        CLEAR(Result);
                        CLEAR(Peso);
                        Peso[1] := 8;
                        Peso[2] := 7;
                        Peso[3] := 6;
                        Peso[4] := 5;
                        Peso[5] := 4;
                        Peso[6] := 3;
                        Peso[7] := 2;
                        i := 1;
                        REPEAT
                        BEGIN
                            EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                            IF i <> 0 THEN
                                Result := Result + Character * Peso[i];
                            i := i + 1;
                        END;
                        UNTIL i = 8;
                        Result := Result MOD 11;
                        IF Result = 0 THEN
                            Result := 0
                        ELSE BEGIN
                            //Result := Result MOD 11;
                            Result := 11 - Result;
                        END;
                        IF STRLEN(FORMAT(Result)) = 2 THEN               //MtsBr10.04
                            EVALUATE(Result, COPYSTR(FORMAT(Result), 2, 1)); //MtsBr10.04
                        //Cálculo do 1º dígito
                        IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                            ERROR(Text83501);
                        CLEAR(Result);
                        CLEAR(Peso);
                        Peso[1] := 9;
                        Peso[2] := 8;
                        Peso[3] := 7;
                        Peso[4] := 6;
                        Peso[5] := 5;
                        Peso[6] := 4;
                        Peso[7] := 3;
                        Peso[8] := 2;
                        i := 1;
                        EVALUATE(Inscriptiontxt, COPYSTR(JXBRIE, 1, 7) + COPYSTR(JXBRIE, 9, 1));
                        REPEAT
                        BEGIN
                            EVALUATE(Character, COPYSTR(FORMAT(Inscriptiontxt), i, 1));
                            IF i <> 0 THEN
                                Result := Result + Character * Peso[i];
                            i := i + 1;
                        END;
                        UNTIL i = 9;
                        Result := Result MOD 11;
                        IF Result <> 0 THEN
                            Result := 11 - Result;
                        IF FORMAT(Result) <> COPYSTR(JXBRIE, 8, 1) THEN
                            ERROR(Text83501);
                        JXBRIE := COPYSTR(JXBRIE, 1, 7) + '-' + COPYSTR(JXBRIE, 8, 2)
                    END;
                EXIT;
            END;
            IF STRLEN(JXBRIE) = 8 THEN BEGIN
                IF COPYSTR(JXBRIE, 1, 1) IN ['0', '1', '2', '3', '4', '5', '8'] THEN BEGIN
                    CLEAR(Result);
                    CLEAR(Peso);
                    Peso[1] := 7;
                    Peso[2] := 6;
                    Peso[3] := 5;
                    Peso[4] := 4;
                    Peso[5] := 3;
                    Peso[6] := 2;
                    i := 1;
                    REPEAT
                    BEGIN
                        EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                        IF i <> 0 THEN
                            Result := Result + Character * Peso[i];
                        i := i + 1;
                    END;
                    UNTIL i = 7;
                    IF Result = 0 THEN
                        Result := 0
                    ELSE BEGIN
                        Result := Result MOD 10;
                        Result := 10 - Result;
                    END;
                    IF FORMAT(Result) <> COPYSTR(JXBRIE, 8, 1) THEN
                        ERROR(Text83501);
                    CLEAR(Result);
                    CLEAR(Peso);
                    Peso[1] := 8;
                    Peso[2] := 7;
                    Peso[3] := 6;
                    Peso[4] := 5;
                    Peso[5] := 4;
                    Peso[6] := 3;
                    Peso[7] := 2;
                    i := 1;
                    EVALUATE(Inscriptiontxt, COPYSTR(JXBRIE, 1, 6) + COPYSTR(JXBRIE, 8, 1));
                    REPEAT

                        EVALUATE(Character, COPYSTR(FORMAT(Inscriptiontxt), i, 1));
                        IF i <> 0 THEN
                            Result := Result + Character * Peso[i];
                        i := i + 1;

                    UNTIL i = 8;
                    Result := Result MOD 10;
                    Result := 10 - Result;
                    IF FORMAT(Result) <> COPYSTR(JXBRIE, 7, 1) THEN
                        ERROR(Text83501);
                    JXBRIE := COPYSTR(JXBRIE, 1, 6) + '-' + COPYSTR(JXBRIE, 7, 2)
                END
                ELSE
                    IF COPYSTR(JXBRIE, 1, 1) IN ['6', '7', '9'] THEN BEGIN
                        CLEAR(Result);
                        CLEAR(Peso);
                        Peso[1] := 7;
                        Peso[2] := 6;
                        Peso[3] := 5;
                        Peso[4] := 4;
                        Peso[5] := 3;
                        Peso[6] := 2;
                        i := 1;
                        REPEAT

                            EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                            IF i <> 0 THEN
                                Result := Result + Character * Peso[i];
                            i := i + 1;

                        UNTIL i = 7;
                        Result := Result MOD 11;
                        IF Result IN [0, 1] THEN
                            Result := 0
                        ELSE BEGIN
                            Result := 11 - Result;
                        END;
                        IF FORMAT(Result) <> COPYSTR(JXBRIE, 8, 1) THEN
                            ERROR(Text83501);
                        CLEAR(Result);
                        CLEAR(Peso);
                        Peso[1] := 8;
                        Peso[2] := 7;
                        Peso[3] := 6;
                        Peso[4] := 5;
                        Peso[5] := 4;
                        Peso[6] := 3;
                        Peso[7] := 2;
                        i := 1;
                        EVALUATE(Inscriptiontxt, COPYSTR(JXBRIE, 1, 6) + COPYSTR(JXBRIE, 8, 1));
                        REPEAT

                            EVALUATE(Character, COPYSTR(FORMAT(Inscriptiontxt), i, 1));
                            IF i <> 0 THEN
                                Result := Result + Character * Peso[i];
                            i := i + 1;

                        UNTIL i = 8;
                        Result := Result MOD 11;
                        IF Result IN [0, 1] THEN
                            Result := 0
                        ELSE
                            Result := 11 - Result;
                        IF FORMAT(Result) <> COPYSTR(JXBRIE, 7, 1) THEN
                            ERROR(Text83501);
                        JXBRIE := COPYSTR(JXBRIE, 1, 6) + '-' + COPYSTR(JXBRIE, 7, 2)
                    END;
                EXIT;
            END;
        END;
        IF Customer."Territory Code" = 'CE' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF (Result IN [11, 10]) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) + '-' + COPYSTR(JXBRIE, 9, 9);
            EXIT;
        END;
        IF Customer."Territory Code" = 'DF' THEN BEGIN
            JXBRIE := COPYSTR('0000000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 13);
            IF STRLEN(JXBRIE) <> 13 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 4;
            Peso[2] := 3;
            Peso[3] := 2;
            Peso[4] := 9;
            Peso[5] := 8;
            Peso[6] := 7;
            Peso[7] := 6;
            Peso[8] := 5;
            Peso[9] := 4;
            Peso[10] := 3;
            Peso[11] := 2;
            i := 1;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
            END;
            UNTIL i = 12;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 12, 1) THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 5;
            Peso[2] := 4;
            Peso[3] := 3;
            Peso[4] := 2;
            Peso[5] := 9;
            Peso[6] := 8;
            Peso[7] := 7;
            Peso[8] := 6;
            Peso[9] := 5;
            Peso[10] := 4;
            Peso[11] := 3;
            Peso[12] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 13;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 13, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 3) + '.' + COPYSTR(JXBRIE, 4, 5) + '.' + COPYSTR(JXBRIE, 9, 3) +
                      '-' + COPYSTR(JXBRIE, 12, 2);
            EXIT;
        END;
        IF Customer."Territory Code" = 'ES' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            IF (Result < 2) THEN
                Result := 0
            ELSE BEGIN
                Result := 11 - Result;
            END;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) + '-' + COPYSTR(JXBRIE, 9, 9);
            EXIT;
        END;
        IF Customer."Territory Code" = 'GO' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            IF COPYSTR(JXBRIE, 1, 8) = '11094402' THEN
                IF (COPYSTR(JXBRIE, 9, 1) <> '0') AND (COPYSTR(JXBRIE, 9, 1) <> '1') THEN
                    ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            IF (Result = 1) AND ((JXBRIE >= '10103105') AND (JXBRIE <= '10119997')) THEN
                Result := 1
            ELSE
                IF (Result = 1) AND ((JXBRIE < '10103105') OR (JXBRIE > '10119997')) THEN
                    Result := 0
                ELSE BEGIN
                    IF NOT (Result IN [0, 1]) THEN
                        Result := 11 - Result;
                END;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 3) + '.' + COPYSTR(JXBRIE, 6, 3) +
                      '-' + COPYSTR(JXBRIE, 9, 9);
            EXIT;
        END;
        IF Customer."Territory Code" = 'MA' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 3) + '.' + COPYSTR(JXBRIE, 6, 3) +
                      '-' + COPYSTR(JXBRIE, 9, 9);
            EXIT;
        END;
        IF Customer."Territory Code" = 'MT' THEN BEGIN
            JXBRIE := COPYSTR('00000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 11);
            IF STRLEN(JXBRIE) <> 11 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 3;
            Peso[2] := 2;
            Peso[3] := 9;
            Peso[4] := 8;
            Peso[5] := 7;
            Peso[6] := 6;
            Peso[7] := 5;
            Peso[8] := 4;
            Peso[9] := 3;
            Peso[10] := 2;
            i := 1;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
            END;
            UNTIL i = 11;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 11, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 10) +
                      '-' + COPYSTR(JXBRIE, 11, 1);
            EXIT;
        END;
        IF Customer."Territory Code" = 'MS' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            IF Result = 0 THEN
                Result := 0
            ELSE
                IF Result > 0 THEN BEGIN
                    Result := 11 - Result;
                    IF Result > 9 THEN
                        Result := 0;
                END;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) +
                      '-' + COPYSTR(JXBRIE, 9, 1);
            EXIT;
        END;
        IF Customer."Territory Code" = 'MG' THEN BEGIN
            JXBRIE := COPYSTR('0000000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 13);
            IF STRLEN(JXBRIE) <> 13 THEN
                ERROR(Text83501);
            Estadual := COPYSTR(JXBRIE, 1, 3) + '0' + COPYSTR(JXBRIE, 4, 8);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 1;
            Peso[2] := 2;
            Peso[3] := 1;
            Peso[4] := 2;
            Peso[5] := 1;
            Peso[6] := 2;
            Peso[7] := 1;
            Peso[8] := 2;
            Peso[9] := 1;
            Peso[10] := 2;
            Peso[11] := 1;
            Peso[12] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(Estadual, i, 1));
                IF i <> 0 THEN BEGIN
                    Result := Character * Peso[i];
                    IF STRLEN(FORMAT(Result)) > 1 THEN BEGIN
                        EVALUATE(Character, COPYSTR(FORMAT(Result), 1, 1));
                        Dígitos := Dígitos + FORMAT(Character);
                        EVALUATE(Character, COPYSTR(FORMAT(Result), 2, 1));
                        Dígitos := Dígitos + FORMAT(Character);
                    END
                    ELSE
                        Dígitos := Dígitos + FORMAT(Result);
                END;
                i := i + 1;

            UNTIL i = 13;
            CLEAR(Result);
            FOR i := 1 TO STRLEN(Dígitos) DO BEGIN
                EVALUATE(Character, COPYSTR(Dígitos, i, 1));
                Result := Result + Character;
            END;
            CLEAR(Soma);
            IF STRLEN(FORMAT(Result)) > 1 THEN BEGIN
                IF COPYSTR(FORMAT(Result), 2, 1) <> '0' THEN BEGIN
                    Soma := Result + 10;
                    EVALUATE(Dígitos, COPYSTR(FORMAT(Soma), 1, 1) + '0');
                    EVALUATE(Soma, Dígitos);
                END
                ELSE
                    Result := 0;
            END ELSE
                Soma := 10;
            Result := Soma - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 12, 1) THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            CLEAR(Dígitos);
            Peso[1] := 3;
            Peso[2] := 2;
            Peso[3] := 11;
            Peso[4] := 10;
            Peso[5] := 9;
            Peso[6] := 8;
            Peso[7] := 7;
            Peso[8] := 6;
            Peso[9] := 5;
            Peso[10] := 4;
            Peso[11] := 3;
            Peso[12] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 13;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 13, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 3) + '.' + COPYSTR(JXBRIE, 4, 3) + '.' + COPYSTR(JXBRIE, 7, 3) +
                      '/' + COPYSTR(JXBRIE, 10, 4);
            EXIT;
        END;
        IF Customer."Territory Code" = 'PA' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 8;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;

            UNTIL i = 0;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 2) + '-' + COPYSTR(JXBRIE, 3, 6) + '-' + COPYSTR(JXBRIE, 9, 9);
            EXIT;
        END;
        IF Customer."Territory Code" = 'PR' THEN BEGIN
            JXBRIE := COPYSTR('0000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 10);
            IF STRLEN(JXBRIE) <> 10 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 3;
            Peso[2] := 2;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 8;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;

            UNTIL i = 0;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 4;
            Peso[2] := 3;
            Peso[3] := 2;
            Peso[4] := 7;
            Peso[5] := 6;
            Peso[6] := 5;
            Peso[7] := 4;
            Peso[8] := 3;
            Peso[9] := 2;
            i := 9;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;

            UNTIL i = 0;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 10, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 3) + '.' + COPYSTR(JXBRIE, 4, 5) + '-' + COPYSTR(JXBRIE, 9, 2);
            EXIT;
        END;
        IF Customer."Territory Code" = 'PE' THEN
            IF STRLEN(JXBRIE) = 9 THEN BEGIN
                CLEAR(Result);
                CLEAR(Peso);
                Peso[1] := 8;
                Peso[2] := 7;
                Peso[3] := 6;
                Peso[4] := 5;
                Peso[5] := 4;
                Peso[6] := 3;
                Peso[7] := 2;
                i := 1;
                REPEAT

                    EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                    IF i <> 0 THEN
                        Result := Result + Character * Peso[i];
                    i := i + 1;
                    ;

                UNTIL i = 8;
                Result := Result MOD 11;
                IF Result IN [0, 1] THEN
                    Result := 0
                ELSE
                    Result := 11 - Result; //1ª Digito
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 8, 1) THEN
                    ERROR(Text83501);
                CLEAR(Result);
                CLEAR(Peso);
                Peso[1] := 9;
                Peso[2] := 8;
                Peso[3] := 7;
                Peso[4] := 6;
                Peso[5] := 5;
                Peso[6] := 4;
                Peso[7] := 3;
                Peso[8] := 2;
                i := 1;
                REPEAT
                BEGIN
                    EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                    IF i <> 0 THEN
                        Result := Result + Character * Peso[i];
                    i := i + 1;
                END;
                UNTIL i = 9;
                Result := Result MOD 11;
                IF Result IN [0, 1] THEN
                    Result := 0
                ELSE
                    Result := 11 - Result; //2ª Digito
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                    ERROR(Text83501);
                EXIT;
            END ELSE BEGIN
                JXBRIE := COPYSTR('00000000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 14);
                IF STRLEN(JXBRIE) = 14 THEN
                    CLEAR(Result);
                CLEAR(Peso);
                Peso[1] := 5;
                Peso[2] := 4;
                Peso[3] := 3;
                Peso[4] := 2;
                Peso[5] := 1;
                Peso[6] := 9;
                Peso[7] := 8;
                Peso[8] := 7;
                Peso[9] := 6;
                Peso[10] := 5;
                Peso[11] := 4;
                Peso[12] := 3;
                Peso[13] := 2;
                i := 1;
                REPEAT

                    EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                    IF i <> 0 THEN
                        Result := Result + Character * Peso[i];
                    i := i + 1;

                UNTIL i = 14;
                Result := Result MOD 11;
                IF Result IN [0, 1] THEN BEGIN
                    Result := 0;
                END ELSE BEGIN
                    Result := 11 - Result;
                    IF (Result > 9) THEN
                        Result := Result - 10;
                END;
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 14, 1) THEN
                    ERROR(Text83501);
                EXIT;
            END;
        IF Customer."Territory Code" = 'PI' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 8;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i - 1;

            UNTIL i = 0;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) + '-' + COPYSTR(JXBRIE, 9, 9);
            EXIT;
        END;
        IF Customer."Territory Code" = 'RS' THEN BEGIN
            JXBRIE := COPYSTR('0000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 10);
            IF STRLEN(JXBRIE) <> 10 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 2;
            Peso[2] := 9;
            Peso[3] := 8;
            Peso[4] := 7;
            Peso[5] := 6;
            Peso[6] := 5;
            Peso[7] := 4;
            Peso[8] := 3;
            Peso[9] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 10;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 10, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 3) + '/' + COPYSTR(JXBRIE, 4, 10);
            EXIT;
        END;
        IF Customer."Territory Code" = 'RO' THEN BEGIN
            IF STRLEN(JXBRIE) = 9 THEN BEGIN
                EVALUATE(Inscription, COPYSTR(JXBRIE, 4, 5));
                CLEAR(Result);
                CLEAR(Peso);
                Peso[1] := 6;
                Peso[2] := 5;
                Peso[3] := 4;
                Peso[4] := 3;
                Peso[5] := 2;
                i := 1;
                REPEAT
                BEGIN
                    EVALUATE(Character, COPYSTR(FORMAT(Inscription), i, 1));
                    IF i <> 0 THEN
                        Result := Result + Character * Peso[i];
                    i := i + 1;
                END;
                UNTIL i = 6;
                Result := Result MOD 11;
                Result := 11 - Result;
                IF (Result = 10) OR (Result = 11) THEN
                    Result := Result - 10;
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                    ERROR(Text83501);
                JXBRIE := COPYSTR(JXBRIE, 1, 3) + '.' + COPYSTR(JXBRIE, 4, 5) + '-' +
                          COPYSTR(JXBRIE, 9, 1);
            END
            ELSE BEGIN
                IF STRLEN(JXBRIE) = 6 THEN
                    JXBRIE := '00000000' + JXBRIE;
                IF STRLEN(JXBRIE) <> 14 THEN
                    ERROR(Text83501);
                CLEAR(Result);
                CLEAR(Peso);
                Peso[1] := 6;
                Peso[2] := 5;
                Peso[3] := 4;
                Peso[4] := 3;
                Peso[5] := 2;
                Peso[6] := 9;
                Peso[7] := 8;
                Peso[8] := 7;
                Peso[9] := 6;
                Peso[10] := 5;
                Peso[11] := 4;
                Peso[12] := 3;
                Peso[13] := 2;
                i := 1;
                REPEAT

                    EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                    IF i <> 0 THEN
                        Result := Result + Character * Peso[i];
                    i := i + 1;

                UNTIL i = 14;
                Result := Result MOD 11;
                Result := 11 - Result;
                IF (Result = 10) OR (Result = 11) THEN
                    Result := Result - 10;
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 14, 1) THEN
                    ERROR(Text83501);
                JXBRIE := COPYSTR(JXBRIE, 1, 13) + '-' + COPYSTR(JXBRIE, 14, 1);
            END;
            EXIT;
        END;
        IF Customer."Territory Code" = 'RR' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 1;
            Peso[2] := 2;
            Peso[3] := 3;
            Peso[4] := 4;
            Peso[5] := 5;
            Peso[6] := 6;
            Peso[7] := 7;
            Peso[8] := 8;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 9;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) + '-' + COPYSTR(JXBRIE, 9, 1);
            EXIT;
        END;
        IF Customer."Territory Code" = 'SC' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
            END;
            UNTIL i = 9;
            Result := Result MOD 11;
            IF (Result = 0) OR (Result = 1) THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 3) + '.' + COPYSTR(JXBRIE, 4, 3) + '.' +
                      COPYSTR(JXBRIE, 7, 3);
            EXIT;
        END;
        IF Customer."Territory Code" = 'SE' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) + '-' + COPYSTR(JXBRIE, 9, 1);
            EXIT;
        END;
        IF Customer."Territory Code" = 'TO' THEN BEGIN
            IF STRLEN(JXBRIE) = 9 THEN
                EVALUATE(Inscription, COPYSTR(JXBRIE, 1, 2) + COPYSTR(JXBRIE, 3, 6))
            ELSE
                EVALUATE(Inscription, COPYSTR(JXBRIE, 1, 2) + COPYSTR(JXBRIE, 5, 6));
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT
            BEGIN
                EVALUATE(Character, COPYSTR(FORMAT(Inscription), i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;
            END;
            UNTIL i = 9;
            Result := Result MOD 11;
            IF Result < 2 THEN
                Result := 0
            ELSE
                Result := 11 - Result;
            IF STRLEN(JXBRIE) = 9 THEN BEGIN
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                    ERROR(Text83501);
                JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 3) + '.' +
                          COPYSTR(JXBRIE, 6, 3) + '-' + COPYSTR(JXBRIE, 9, 1);
            END ELSE BEGIN
                IF FORMAT(Result) <> COPYSTR(JXBRIE, 11, 1) THEN
                    ERROR(Text83501);
                JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 2) + '.' +
                          COPYSTR(JXBRIE, 5, 6) + '-' + COPYSTR(JXBRIE, 11, 1);
            END;
            EXIT;
        END;
        IF Customer."Territory Code" = 'PB' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result MOD 11;
            Result := 11 - Result;
            IF (Result = 10) OR (Result = 11) THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 8) + '-' + COPYSTR(JXBRIE, 9, 1);
            EXIT;
        END;
        IF Customer."Territory Code" = 'RN' THEN BEGIN
            JXBRIE := COPYSTR('000000000' + JXBRIE, STRLEN(JXBRIE) + 1, 9);
            IF STRLEN(JXBRIE) <> 9 THEN
                ERROR(Text83501);
            CLEAR(Result);
            CLEAR(Peso);
            Peso[1] := 9;
            Peso[2] := 8;
            Peso[3] := 7;
            Peso[4] := 6;
            Peso[5] := 5;
            Peso[6] := 4;
            Peso[7] := 3;
            Peso[8] := 2;
            i := 1;
            REPEAT

                EVALUATE(Character, COPYSTR(JXBRIE, i, 1));
                IF i <> 0 THEN
                    Result := Result + Character * Peso[i];
                i := i + 1;

            UNTIL i = 9;
            Result := Result * 10;
            Result := Result MOD 11;
            IF Result = 10 THEN
                Result := 0;
            IF FORMAT(Result) <> COPYSTR(JXBRIE, 9, 1) THEN
                ERROR(Text83501);
            JXBRIE := COPYSTR(JXBRIE, 1, 2) + '.' + COPYSTR(JXBRIE, 3, 3) + '.' +
                      COPYSTR(JXBRIE, 6, 3) + '-' + COPYSTR(JXBRIE, 9, 1);
            EXIT;
        END;
    end;

    var
        CompanyInfo: Record "Company Information";
        LocHideDialog: Boolean;
        i: Integer;
        Character: Integer;
        Inscriptiontxt: Text[9];
        Text83500: Label 'Not allow to insert I.E. to a foreign customer.';
        Text83501: Label 'I.E. invalid.';
        Text83502: Label 'Do you really want to validate the I.E.?';
        Text83503: Label 'The I.E. is already in use for the customer %1 - %2';

}