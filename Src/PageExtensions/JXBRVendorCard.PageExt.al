pageextension 83504 JXBRVendorCard extends "Vendor Card"
{
    layout
    {
        addafter(JXLTFiscalType)
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