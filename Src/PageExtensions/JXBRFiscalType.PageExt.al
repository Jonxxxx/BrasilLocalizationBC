pageextension 83500 JXBRFiscalType extends JXLTFiscalTypes
{
    layout
    {
        modify(JXFEVATCondition)
        {
            Visible = not IsBrasil;
        }

        modify(JXFiscalType)
        {
            Visible = not IsBrasil;
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