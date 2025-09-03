page 83500 JXBRTaxJurisdictions
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Tax Jurisdiction";
    Caption = 'Brasil Tax jurisdiction', Comment = 'ESP = Jurisdicciones de impuestos Brasil';

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Code', Comment = 'ESP = Codigo';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description', Comment = 'ESP = Descripcion';
                }
                field("Default Sales and Use Tax"; DefaultTax)
                {
                    ApplicationArea = All;
                    caption = 'Default sales and use tax', comment = 'Impuesto de ventas y uso por defecto';
                    ToolTip = 'Default tax', Comment = 'ESP = Impuesto por defecto';
                    trigger OnValidate()
                    begin
                        SetDefaultTax(DefaultTax);
                    end;

                    trigger OnLookup(VAR Text: Text): Boolean
                    begin
                        GetDefaultTaxDetail(TaxDetail);
                        PAGE.RUNMODAL(PAGE::"Tax Details", TaxDetail);
                        DefaultTax := GetDefaultTax();
                    end;
                }
                field("Calculate Tax on Tax"; Rec."Calculate Tax on Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Calculate tax on tax', Comment = 'ESP = Calcula impuesto in impuesto';
                }
                field("Unrealized VAT Type"; Rec."Unrealized VAT Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Description', Comment = 'ESP = Descripcion';
                }
                field("Adjust for Payment Discount"; Rec."Adjust for Payment Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Adjust for payment discount', Comment = 'ESP = Ajuste por descuento en pago';
                }
                field("Tax Account (Sales)"; Rec."Tax Account (Sales)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax account (sales)', Comment = 'ESP = Cuenta de impuesto (ventas)';
                }
                field("Unreal. Tax Acc. (Sales)"; Rec."Unreal. Tax Acc. (Sales)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unrealized tax account (sales)', Comment = 'ESP = Cuenta de impuesto no realizada (ventas)';
                }
                field("Tax Account (Purchases)"; Rec."Tax Account (Purchases)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax Account (purchases)', Comment = 'ESP = Cuenta de impeustos (compras)';
                }
                field("Reverse Charge (Purchases)"; Rec."Reverse Charge (Purchases)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reverse charge (purchases)', Comment = 'ESP = Cargo inverso (compras)';
                }
                field("Unreal. Tax Acc. (Purchases)"; Rec."Unreal. Tax Acc. (Purchases)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unrealized tax account (purchases)', Comment = 'ESP = Cuenta de impuestos no realizados (compras)';
                }
                field("Unreal. Rev. Charge (Purch.)"; Rec."Unreal. Rev. Charge (Purch.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unrealized reverse charge (purchases)', Comment = 'ESP = Cargo inverso no realizado (compras)';
                }
                field("Report-to Jurisdiction"; Rec."Report-to Jurisdiction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Report to jurisdiction', Comment = 'ESP = Reporte para jurisdiccion';
                }
                field(JXBRTaxIdentification; Rec.JXBRTaxIdentification)
                {
                    Visible = IsBrasil;
                    ApplicationArea = All;
                    ToolTip = 'Tax Identification';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DefaultTax := GetDefaultTax();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TaxSetup.get();
        DefaultTax := 0;
        DefaultTaxIsEnabled := TaxSetup."Auto. Create Tax Details";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DefaultTax := GetDefaultTax();
    end;

    procedure GetDefaultTax(): Decimal
    begin
        GetDefaultTaxDetail(TaxDetail);
        EXIT(TaxDetail."Tax Below Maximum");
    end;

    procedure SetDefaultTax(NewTaxBelowMaximum: Decimal)
    begin
        GetDefaultTaxDetail(TaxDetail);
        TaxDetail."Tax Below Maximum" := NewTaxBelowMaximum;
        TaxDetail.Modify();
    end;

    procedure GetDefaultTaxDetail(VAR TaxDetail: Record "Tax Detail")
    begin
        TaxDetail.SetRange("Tax Jurisdiction Code", Rec.Code);
        TaxDetail.SetRange("Tax Group Code", '');
        //Comment when implement for US or MX version
        //TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
        IF TaxDetail.FindLast() THEN BEGIN
            DefaultTaxIsEnabled := TRUE;
            TaxDetail.SETRANGE("Effective Date", TaxDetail."Effective Date");
            TaxDetail.FindLast();
        END ELSE BEGIN
            DefaultTaxIsEnabled := FALSE;
            TaxDetail.SetRange("Effective Date");
        END;
    end;

    trigger OnOpenPage()
    begin
        IsBrasil := CompanyInformation.JXIsBrasil();
    end;

    var
        CompanyInformation: Record "Company Information";
        TaxSetup: Record "Tax Setup";
        TaxDetail: Record "Tax Detail";
        DefaultTax: Decimal;
        DefaultTaxIsEnabled: Boolean;
        IsBrasil: Boolean;
}