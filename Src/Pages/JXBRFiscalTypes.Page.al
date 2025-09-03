page 83501 JXBRFiscalTypes
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = JXLTFiscalType;
    Caption = 'Brasil Fiscal Types', Comment = 'Tipos fiscales Brasil';
    CardPageId = JXLTFiscalType;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Code';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }

                field(JXBRFiscalType; Rec.JXBRFiscalType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Fiscal type',
                        Comment = 'ESP = Tipo fiscal';
                }
            }
        }
    }
}