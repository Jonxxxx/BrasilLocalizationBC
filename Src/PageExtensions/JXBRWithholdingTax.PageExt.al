pageextension 83501 JXBRWithholdingTax extends JXLTWithholdingTax
{
    layout
    {
        modify(JXLTTaxType)
        {
            Visible = not IsBrasil;
        }

        modify(JXLTSicoreCode)
        {
            Visible = not IsBrasil;
        }

        addafter(JXLTRetains)
        {
            field(JXBRTaxIdentification; Rec.JXBRTaxIdentification)
            {
                ApplicationArea = All;
                ToolTip = 'Tax Identification';
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