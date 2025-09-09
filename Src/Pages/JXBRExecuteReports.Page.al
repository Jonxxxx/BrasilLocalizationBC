page 83502 JXBRExecuteReports
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Localization Reports', Comment = 'ESP=Reportes localización';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Filter', Comment = 'ESP=Filtro';
                field(FromDate; FromDate)
                {
                    ApplicationArea = All;
                    Caption = 'From', Comment = 'ESP=Desde';
                    ToolTip = 'From', Comment = 'ESP=Desde';
                }
                field(ToDate; ToDate)
                {
                    ApplicationArea = All;
                    Caption = 'To', Comment = 'ESP=Hasta';
                    ToolTip = 'To', Comment = 'ESP=Hasta';
                }
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            group(Reports)
            {
                Caption = 'Reports';

                action(PerceptionsBook)
                {
                    ApplicationArea = All;
                    Caption = 'Perceptions book', Comment = 'ESP=Libro percepciones';
                    ToolTip = 'Perceptions book', Comment = 'ESP=Libro percepciones';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        PerceptionsBook: Report JXLTPerceptionsBook;
                    begin
                        Clear(PerceptionsBook);
                        PerceptionsBook.SetDates(FromDate, ToDate);
                        PerceptionsBook.Run();
                    end;
                }
                action(RetentionsBook)
                {
                    ApplicationArea = All;
                    Caption = 'Withholding book', Comment = 'ESP=Libro retenciones';
                    ToolTip = 'Withholding book', Comment = 'ESP=Libro retenciones';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        RetentionsBook: Report JXLTRetentionsBook;
                    begin
                        Clear(RetentionsBook);
                        RetentionsBook.SetDates(FromDate, ToDate);
                        RetentionsBook.Run();
                    end;
                }

                action(DailyBook)
                {
                    ApplicationArea = All;
                    Caption = 'Daily book', Comment = 'ESP=Libro diario';
                    ToolTip = 'Daily book', Comment = 'ESP=Libro diario';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        JXLTSetupLibroDiario: Page JXLTSetupLibroDiario;
                    begin
                        Clear(JXLTSetupLibroDiario);
                        JXLTSetupLibroDiario.RunModal();
                    end;
                }
            }

            action(ExportSped)
            {
                ApplicationArea = All;
                Caption = 'Sped', Comment = 'ESP=Sped';
                ToolTip = 'Sped', Comment = 'ESP=Sped';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                var
                    JXBRLogic: Codeunit JXBRLogic;
                begin
                    Clear(JXBRLogic);
                    JXBRLogic.ExportSpedContribuicoes(FromDate, ToDate);
                end;
            }

            action(ExportDIRF)
            {
                ApplicationArea = All;
                Caption = 'DIRF', Comment = 'ESP=DIRF';
                ToolTip = 'DIRF', Comment = 'ESP=DIRF';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                var
                    JXBRLogic: Codeunit JXBRLogic;
                begin
                    Clear(JXBRLogic);
                    JXBRLogic.ExportDIRF(FromDate, ToDate);
                end;
            }

            action(ExportDCTF)
            {
                ApplicationArea = All;
                Caption = 'DCTF', Comment = 'ESP=DCTF';
                ToolTip = 'DCTF', Comment = 'ESP=DCTF';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                var
                    JXBRLogic: Codeunit JXBRLogic;
                begin
                    Clear(JXBRLogic);
                    JXBRLogic.ExportDCTF(FromDate, ToDate);
                end;
            }

            action(ExportLFS)
            {
                ApplicationArea = All;
                Caption = 'LFS-e (Libro Fiscal Servicios)', Comment = 'ESP=LFS-e (Libro Fiscal Servicios)';
                ToolTip = 'LFS-e (Libro Fiscal Servicios)', Comment = 'ESP=LFS-e (Libro Fiscal Servicios)';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                var
                    JXBRLogic: Codeunit JXBRLogic;
                begin
                    Clear(JXBRLogic);
                    JXBRLogic.ExportLFS(FromDate, ToDate);
                end;
            }

            action(ExportNIFs)
            {
                ApplicationArea = All;
                Caption = 'Export NIFs', Comment = 'ESP=Exportar CUITs';
                ToolTip = 'Export NIFs', Comment = 'ESP=Exportar CUITs';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                var
                    JXLTExportCuits: XmlPort JXLTExportCuits;
                begin
                    Clear(JXLTExportCuits);
                    JXLTExportCuits.Run();
                end;
            }
        }
    }

    var
        FromDate: Date;
        ToDate: Date;
}