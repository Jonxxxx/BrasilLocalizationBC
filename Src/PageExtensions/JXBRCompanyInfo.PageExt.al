pageextension 83505 JXBRCompanyInfo extends "Company Information"
{
    layout
    {
        addafter(JXFiscalType)
        {
            field(JXBRCNPJ; Rec.JXBRCNPJ)
            {
                ApplicationArea = All;
                ToolTip = 'C.N.P.J.';
                Visible = IsBrasil;
            }

            field(JXBRIE; Rec.JXBRIE)
            {
                ApplicationArea = All;
                ToolTip = 'I.E';
                Visible = IsBrasil;
            }

            field(JXBRIM; Rec.JXBRIM)
            {
                ApplicationArea = All;
                ToolTip = 'I.M';
                Visible = IsBrasil;
            }

            field(JXBRBrasilLocEnabled; Rec.JXBRBrasilLocEnabled)
            {
                ApplicationArea = All;
                ToolTip = 'Brasil Loc Enabled';
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsBrasil := CompanyInformation.JXIsBrasil();
    end;

    var
        CompanyInformation: Record "Company Information";
        IsBrasil: Boolean;
}