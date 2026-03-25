tableextension 83501 JXBRCompanyInfo extends "Company Information"
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
        field(83505; JXBRBrasilLocEnabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Brasil Localization Enabled';

            trigger OnValidate()
            var
                JXBRBrasilApplicationAreaMgt: Codeunit JXBRBrasilApplicationAreaMgt;
                AppArea: Text;
            begin
                if JXBRBrasilLocEnabled then
                    AppArea := '#JXBRshowBrasil'
                else
                    AppArea := '#JXBRNotshowBrasil';

                JXBRBrasilApplicationAreaMgt.SetGlobalAppAreaBrasil(AppArea);
                JXBRBrasilApplicationAreaMgt.ApplyBrasilApplicationArea();
            end;
        }
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

    var
        CompanyInfo: Record "Company Information";
        IsBrasil: Boolean;
}