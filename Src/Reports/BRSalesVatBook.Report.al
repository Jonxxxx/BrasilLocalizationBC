report 83500 JXBRSalesVatBook
{
    Caption = 'Sales vat book', Comment = 'ESP=Libro IVA ventas';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    DefaultLayout = RDLC;
    RDLCLayout = 'Src/ReportLayout/BRSalesVatBook.rdl';

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number) order(ascending) where(Number = const(1));

            column(CompanyInfo_Number; Header.Number)
            {

            }
            column("CompanyInfo_City"; CompanyInfo.City)
            {//

            }
            column("CompanyInfo_VATRegistrationNo"; CompanyInfo."VAT Registration No.")
            {//

            }
            column("CompanyInfo_Name"; CompanyInfo.Name)
            {//

            }
            column("CompanyInfo_Address"; CompanyInfo.Address)
            {//

            }
            column(CompanyInfo_County; CompanyInfo.County)
            {//

            }
            column(CompanyInfo_PostCode; CompanyInfo."Post Code")
            {

            }
            column(FromDate; FromDate)
            {//

            }
            column(ToDate; ToDate)
            {//

            }

            column(OpenIIBB; GenLedgerSetup.JXLTOpenPercepIIBBReport)
            { }

            trigger OnPreDataItem()

            begin
                CompanyInfo.reset();
                CompanyInfo.Get('');

                GenLedgerSetup.Reset();
                GenLedgerSetup.Get();
            end;
        }

        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.") order(ascending) where(JXLTNotShowInBooks = filter(False));

            trigger OnPreDataItem()
            begin
                "Sales Invoice Header".SetRange("Posting Date", FromDate, ToDate);
                "Sales Invoice Header".SetRange(JXInvoiceType, "Sales Invoice Header".JXInvoiceType::Invoice);
            end;

            trigger OnAfterGetRecord()
            var
                TaxJurisdictionTemp: Record "Tax Jurisdiction" temporary;
            begin
                "Sales Invoice Header".CalcFields("Amount Including VAT");
                JXLTSalesVatBook.Init();
                ReportKey += 1;
                JXLTSalesVatBook.JXLTKey := ReportKey;
                JXLTSalesVatBook.JXLTPostingdate := "Sales Invoice Header"."Posting Date";
                JXLTSalesVatBook.JXLTInvoiceNumber := "Sales Invoice Header"."No.";
                JXLTSalesVatBook.JXLTCompanyName := "Sales Invoice Header"."Bill-to Name";
                JXLTSalesVatBook.JXLTVATRegistrationNo := "Sales Invoice Header"."VAT Registration No.";
                JXLTSalesVatBook.JXLTTaxAreaCode := "Sales Invoice Header"."Tax Area Code";
                JXLTSalesVatBook.JXLTProvince := "Sales Invoice Header".JXLTProvinceCode;
                JXLTSalesVatBook.JXLTInvoiceType := Format("Sales Invoice Header".JXInvoiceType::Invoice);
                JXLTSalesVatBook.JXLTInvoiceAmount := Abs("Sales Invoice Header"."Amount Including VAT");

                if ("Sales Invoice Header"."Currency Code" <> '') then
                    JXLTSalesVatBook.JXLTInvoiceAmountLCY := Abs("Sales Invoice Header"."Amount Including VAT") / "Sales Invoice Header"."Currency Factor"
                else
                    JXLTSalesVatBook.JXLTInvoiceAmountLCY := Abs("Sales Invoice Header"."Amount Including VAT");
                JXLTSalesVatBook.JXLTCurrency := "Sales Invoice Header"."Currency Code";

                SalesInvoiceLine.Reset();
                SalesInvoiceLine.SetRange(SalesInvoiceLine."Document No.", "Sales Invoice Header"."No.");
                if SalesInvoiceLine.FindSet() then
                    repeat
                        TaxGroup.Reset();
                        TaxGroup.SetRange(TaxGroup."Code", SalesInvoiceLine."Tax Group Code");
                        if TaxGroup.FindFirst() then
                            case TaxGroup.JXLTType of
                                TaxGroup.JXLTType::"No base":
                                    if ("Sales Invoice Header"."Currency Code" <> '') then
                                        JXLTSalesVatBook.JXLTNoBaseAmount += Abs(SalesInvoiceLine."Line Amount") / "Sales Invoice Header"."Currency Factor"
                                    else
                                        JXLTSalesVatBook.JXLTNoBaseAmount += Abs(SalesInvoiceLine."Line Amount");
                                TaxGroup.JXLTType::"Exempt base":
                                    if ("Sales Invoice Header"."Currency Code" <> '') then
                                        JXLTSalesVatBook.JXLTExemptBaseAmount += Abs(SalesInvoiceLine."Line Amount") / "Sales Invoice Header"."Currency Factor"
                                    else
                                        JXLTSalesVatBook.JXLTExemptBaseAmount += Abs(SalesInvoiceLine."Line Amount");
                            end;

                    until SalesInvoiceLine.Next() = 0;

                JXLTSalesVatBook.JXLTBaseAmount := 0;
                TaxJurisdictionTemp.DeleteAll();
                VatEntry.Reset();
                VatEntry.SetRange("Document Type", VatEntry."Document Type"::Invoice);
                VatEntry.SetRange("Document No.", "Sales Invoice Header"."No.");
                if VatEntry.FindSet() then
                    repeat
                        TaxJurisdictionTemp.Reset();
                        TaxJurisdictionTemp.SetRange(TaxJurisdictionTemp.Code, Format(VatEntry."Sales Tax Connection No."));
                        if not TaxJurisdictionTemp.FindFirst() then begin
                            JXLTSalesVatBook.JXLTBaseAmount += /*Abs*/(VatEntry.Base);

                            TaxJurisdictionTemp.Init();
                            TaxJurisdictionTemp.Code := Format(VatEntry."Sales Tax Connection No.");
                            TaxJurisdictionTemp.Insert(false);
                        end;

                        TaxJurisdiction.Reset();
                        TaxJurisdiction.SetRange(TaxJurisdiction."Code", VatEntry."Tax Jurisdiction Code");
                        if TaxJurisdiction.FindFirst() then
                            case TaxJurisdiction.JXBRTaxIdentification of
                                TaxJurisdiction.JXBRTaxIdentification::ISS:
                                    JXLTSalesVatBook.JXLTVAT105 += /*Abs*/(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::COFINS:
                                    JXLTSalesVatBook.JXLTVAT21 += /*Abs*/(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::PIS:
                                    JXLTSalesVatBook.JXLTVAT27 += /*Abs*/(VatEntry.Amount);
                            end;
                    until VatEntry.Next() = 0;

                JXLTSalesVatBook.JXLTBaseAmount := abs(JXLTSalesVatBook.JXLTBaseAmount);
                JXLTSalesVatBook.JXLTVAT21 := abs(JXLTSalesVatBook.JXLTVAT21);
                JXLTSalesVatBook.JXLTVAT27 := abs(JXLTSalesVatBook.JXLTVAT27);
                JXLTSalesVatBook.JXLTVAT105 := abs(JXLTSalesVatBook.JXLTVAT105);
                JXLTSalesVatBook.JXLTVATPercep := abs(JXLTSalesVatBook.JXLTVATPercep);
                JXLTSalesVatBook.JXLTIIBB := abs(JXLTSalesVatBook.JXLTIIBB);
                JXLTSalesVatBook.JXLTIIBBArba := abs(JXLTSalesVatBook.JXLTIIBBArba);
                JXLTSalesVatBook.JXLTIIBBCaba := abs(JXLTSalesVatBook.JXLTIIBBCaba);
                JXLTSalesVatBook.JXLTSpecial := abs(JXLTSalesVatBook.JXLTSpecial);

                JXLTSalesVatBook.JXLTFiscalType := LTFiscalType.GetDescription(JXFiscalType);
                JXLTSalesVatBook.Insert();
            end;

        }
        dataitem("Sales Debit Memo Header"; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.") order(Ascending) where(JXLTNotShowInBooks = filter(False));
            ;

            trigger OnPreDataItem()
            begin
                "Sales Debit Memo Header".SetRange("Posting Date", FromDate, ToDate);
                "Sales Debit Memo Header".SetRange(JXInvoiceType, "Sales Debit Memo Header".JXInvoiceType::DebitMemo);
            end;

            trigger OnAfterGetRecord()
            var
                TaxJurisdictionTemp: Record "Tax Jurisdiction" temporary;
            begin
                "Sales Debit Memo Header".CalcFields("Amount Including VAT");
                JXLTSalesVatBook.Init();
                ReportKey += 1;
                JXLTSalesVatBook.JXLTKey := ReportKey;
                JXLTSalesVatBook.JXLTPostingdate := "Sales Debit Memo Header"."Posting Date";
                JXLTSalesVatBook.JXLTInvoiceNumber := "Sales Debit Memo Header"."No.";
                JXLTSalesVatBook.JXLTCompanyName := "Sales Debit Memo Header"."Bill-to Name";
                JXLTSalesVatBook.JXLTVATRegistrationNo := "Sales Debit Memo Header"."VAT Registration No.";
                JXLTSalesVatBook.JXLTTaxAreaCode := "Sales Debit Memo Header"."Tax Area Code";
                JXLTSalesVatBook.JXLTProvince := "Sales Debit Memo Header".JXLTProvinceCode;
                JXLTSalesVatBook.JXLTInvoiceType := Format("Sales Debit Memo Header".JXInvoiceType::DebitMemo);
                JXLTSalesVatBook.JXLTInvoiceAmount := Abs("Sales Debit Memo Header"."Amount Including VAT");

                if ("Sales Debit Memo Header"."Currency Code" <> '') then
                    JXLTSalesVatBook.JXLTInvoiceAmountLCY := Abs("Sales Debit Memo Header"."Amount Including VAT") / "Sales Debit Memo Header"."Currency Factor"
                else
                    JXLTSalesVatBook.JXLTInvoiceAmountLCY := Abs("Sales Debit Memo Header"."Amount Including VAT");
                JXLTSalesVatBook.JXLTCurrency := "Sales Debit Memo Header"."Currency Code";

                SalesInvoiceLine.Reset();
                SalesInvoiceLine.SetRange(SalesInvoiceLine."Document No.", "Sales Debit Memo Header"."No.");
                if SalesInvoiceLine.FindSet() then
                    repeat
                        TaxGroup.Reset();
                        TaxGroup.SetRange(TaxGroup."Code", SalesInvoiceLine."Tax Group Code");
                        if TaxGroup.FindFirst() then
                            case TaxGroup.JXLTType of
                                TaxGroup.JXLTType::"No base":
                                    if ("Sales Debit Memo Header"."Currency Code" <> '') then
                                        JXLTSalesVatBook.JXLTNoBaseAmount += Abs(SalesInvoiceLine."Line Amount") / "Sales Debit Memo Header"."Currency Factor"
                                    else
                                        JXLTSalesVatBook.JXLTNoBaseAmount += Abs(SalesInvoiceLine."Line Amount");

                                TaxGroup.JXLTType::"Exempt base":
                                    if ("Sales Debit Memo Header"."Currency Code" <> '') then
                                        JXLTSalesVatBook.JXLTExemptBaseamount += Abs(SalesInvoiceLine."Line Amount") / "Sales Debit Memo Header"."Currency Factor"
                                    else
                                        JXLTSalesVatBook.JXLTExemptBaseamount += Abs(SalesInvoiceLine."Line Amount");
                            end;

                    until SalesInvoiceLine.Next() = 0;

                JXLTSalesVatBook.JXLTBaseAmount := 0;
                TaxJurisdictionTemp.deleteAll();
                VatEntry.Reset();
                VatEntry.SetRange("Document Type", VatEntry."Document Type"::Invoice);
                VatEntry.SetRange("Document No.", "Sales Debit Memo Header"."No.");
                if VatEntry.FindSet() then
                    repeat
                        TaxJurisdictionTemp.Reset();
                        TaxJurisdictionTemp.SetRange(TaxJurisdictionTemp.Code, Format(VatEntry."Sales Tax Connection No."));
                        if not TaxJurisdictionTemp.FindFirst() then begin
                            JXLTSalesVatBook.JXLTBaseAmount += Abs(VatEntry.Base);
                            TaxJurisdictionTemp.Init();
                            TaxJurisdictionTemp.Code := Format(VatEntry."Sales Tax Connection No.");
                            TaxJurisdictionTemp.Insert(false);
                        end;

                        TaxJurisdiction.Reset();
                        TaxJurisdiction.SetRange(TaxJurisdiction."Code", VatEntry."Tax Jurisdiction Code");
                        if TaxJurisdiction.FindFirst() then
                            case TaxJurisdiction.JXBRTaxIdentification of
                                TaxJurisdiction.JXBRTaxIdentification::ISS:
                                    JXLTSalesVatBook.JXLTVAT105 += (VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::COFINS:
                                    JXLTSalesVatBook.JXLTVAT21 += (VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::PIS:
                                    JXLTSalesVatBook.JXLTVAT27 += (VatEntry.Amount);
                            end;
                    until VatEntry.Next() = 0;

                JXLTSalesVatBook.JXLTFiscalType := LTFiscalType.GetDescription(JXFiscalType);
                JXLTSalesVatBook.Insert();
            end;
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            DataItemTableView = sorting("No.") order(Ascending) where(JXLTNotShowInBooks = filter(False));
            ;

            trigger OnPreDataItem()
            begin
                "Sales Cr.Memo Header".SetRange("Posting Date", FromDate, ToDate);
            end;

            trigger OnAfterGetRecord()
            var
                TaxJurisdictionTemp: Record "Tax Jurisdiction" temporary;
            begin
                "Sales Cr.Memo Header".CalcFields("Amount Including VAT");
                JXLTSalesVatBook.Init();
                ReportKey += 1;
                JXLTSalesVatBook.JXLTKey := ReportKey;
                JXLTSalesVatBook.JXLTPostingdate := "Sales Cr.Memo Header"."Posting Date";
                JXLTSalesVatBook.JXLTInvoiceNumber := "Sales Cr.Memo Header"."No.";
                JXLTSalesVatBook.JXLTCompanyName := "Sales Cr.Memo Header"."Bill-to Name";
                JXLTSalesVatBook.JXLTVATRegistrationNo := "Sales Cr.Memo Header"."VAT Registration No.";
                JXLTSalesVatBook.JXLTTaxAreaCode := "Sales Cr.Memo Header"."Tax Area Code";
                JXLTSalesVatBook.JXLTProvince := "Sales Cr.Memo Header".JXLTProvinceCode;
                JXLTSalesVatBook.JXLTInvoiceType := 'Nota de crédito';
                JXLTSalesVatBook.JXLTInvoiceAmount := Abs("Sales Cr.Memo Header"."Amount Including VAT") * -1;

                if ("Sales Cr.Memo Header"."Currency Code" <> '') then
                    JXLTSalesVatBook.JXLTInvoiceAmountLCY := (Abs("Sales Cr.Memo Header"."Amount Including VAT") * -1) / "Sales Cr.Memo Header"."Currency Factor"
                else
                    JXLTSalesVatBook.JXLTInvoiceAmountLCY := Abs("Sales Cr.Memo Header"."Amount Including VAT") * -1;
                JXLTSalesVatBook.JXLTCurrency := "Sales Cr.Memo Header"."Currency Code";

                SalesCrMemoLine.Reset();
                SalesCrMemoLine.SetRange(SalesCrMemoLine."Document No.", "Sales Cr.Memo Header"."No.");
                if SalesCrMemoLine.FindSet() then
                    repeat
                        TaxGroup.Reset();
                        TaxGroup.SetRange(TaxGroup."Code", SalesCrMemoLine."Tax Group Code");
                        if TaxGroup.FindFirst() then
                            case TaxGroup.JXLTType of
                                TaxGroup.JXLTType::"No base":
                                    if ("Sales Cr.Memo Header"."Currency Code" <> '') then
                                        JXLTSalesVatBook.JXLTNoBaseAmount += (Abs(SalesCrMemoLine."Line Amount") * -1) / "Sales Cr.Memo Header"."Currency Factor"
                                    else
                                        JXLTSalesVatBook.JXLTNoBaseAmount += Abs(SalesCrMemoLine."Line Amount") * -1;

                                TaxGroup.JXLTType::"Exempt base":
                                    if ("Sales Cr.Memo Header"."Currency Code" <> '') then
                                        JXLTSalesVatBook.JXLTExemptBaseAmount += (Abs(SalesCrMemoLine."Line Amount") * -1) / "Sales Cr.Memo Header"."Currency Factor"
                                    else
                                        JXLTSalesVatBook.JXLTExemptBaseAmount += Abs(SalesCrMemoLine."Line Amount") * -1;
                            end;

                    until SalesCrMemoLine.Next() = 0;

                JXLTSalesVatBook.JXLTBaseAmount := 0;
                TaxJurisdictionTemp.DeleteAll();
                VatEntry.Reset();
                VatEntry.SetRange("Document Type", VatEntry."Document Type"::"Credit Memo");
                VatEntry.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
                if VatEntry.FindSet() then
                    repeat
                        TaxJurisdictionTemp.Reset();
                        TaxJurisdictionTemp.SetRange(TaxJurisdictionTemp.Code, Format(VatEntry."Sales Tax Connection No."));
                        if not TaxJurisdictionTemp.FindFirst() then begin
                            JXLTSalesVatBook.JXLTBaseAmount += /*Abs*/(VatEntry.Base) /** -1*/;
                            TaxJurisdictionTemp.Init();
                            TaxJurisdictionTemp.Code := Format(VatEntry."Sales Tax Connection No.");
                            TaxJurisdictionTemp.Insert(false);
                        end;

                        TaxJurisdiction.Reset();
                        TaxJurisdiction.SetRange(TaxJurisdiction."Code", VatEntry."Tax Jurisdiction Code");
                        if TaxJurisdiction.FindFirst() then
                            case TaxJurisdiction.JXBRTaxIdentification of
                                TaxJurisdiction.JXBRTaxIdentification::ISS:
                                    JXLTSalesVatBook.JXLTVAT105 += /*Abs*/(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::COFINS:
                                    JXLTSalesVatBook.JXLTVAT21 += /*Abs*/(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::PIS:
                                    JXLTSalesVatBook.JXLTVAT27 += /*Abs*/(VatEntry.Amount);
                            end;
                    until VatEntry.Next() = 0;

                JXLTSalesVatBook.JXLTBaseAmount := abs(JXLTSalesVatBook.JXLTBaseAmount) * -1;
                JXLTSalesVatBook.JXLTVAT21 := abs(JXLTSalesVatBook.JXLTVAT21) * -1;
                JXLTSalesVatBook.JXLTVAT27 := abs(JXLTSalesVatBook.JXLTVAT27) * -1;
                JXLTSalesVatBook.JXLTVAT105 := abs(JXLTSalesVatBook.JXLTVAT105) * -1;
                JXLTSalesVatBook.JXLTVATPercep := abs(JXLTSalesVatBook.JXLTVATPercep) * -1;
                JXLTSalesVatBook.JXLTIIBB := abs(JXLTSalesVatBook.JXLTIIBB) * -1;
                JXLTSalesVatBook.JXLTIIBBArba := abs(JXLTSalesVatBook.JXLTIIBBArba) * -1;
                JXLTSalesVatBook.JXLTIIBBCaba := abs(JXLTSalesVatBook.JXLTIIBBCaba) * -1;
                JXLTSalesVatBook.JXLTSpecial := abs(JXLTSalesVatBook.JXLTSpecial) * -1;

                JXLTSalesVatBook.JXLTFiscalType := LTFiscalType.GetDescription(JXFiscalType);
                JXLTSalesVatBook.Insert();
            end;
        }

        dataitem(Temp; Integer)
        {
            DataItemTableView = sorting(Number) order(ascending);

            column(PostingDate; JXLTSalesVatBook.JXLTPostingdate)
            { }
            column(InvoiceNumber; JXLTSalesVatBook.JXLTInvoiceNumber)
            { }
            column(CompanyName; JXLTSalesVatBook.JXLTCompanyName)
            { }
            column(VATRegistrationNoo; JXLTSalesVatBook.JXLTVATRegistrationNo)
            { }
            column(Taxareacode; JXLTSalesVatBook.JXLTTaxAreaCode)
            { }
            column(Province; JXLTSalesVatBook.JXLTProvince)
            { }
            column(Invoicetype; JXLTSalesVatBook.JXLTInvoiceType)
            { }
            column(Invoiceamount; JXLTSalesVatBook.JXLTInvoiceAmount)
            { }
            column(BaseAmount; JXLTSalesVatBook.JXLTBaseAmount)
            { }
            column(NoBaseAmount; JXLTSalesVatBook.JXLTNoBaseAmount)
            { }
            column(ExemptBaseAmount; JXLTSalesVatBook.JXLTExemptBaseAmount)
            { }
            column(VAT105; JXLTSalesVatBook.JXLTVAT105)
            { }
            column(VAT21; JXLTSalesVatBook.JXLTVAT21)
            { }
            column(VAT27; JXLTSalesVatBook.JXLTVAT27)
            { }
            column(VATpercep; JXLTSalesVatBook.JXLTVATPercep)
            { }
            column(IIBB; JXLTSalesVatBook.JXLTIIBB)
            { }
            column(Special; JXLTSalesVatBook.JXLTSpecial)
            { }
            column(FiscalType; JXLTSalesVatBook.JXLTFiscalType)
            { }
            column(CurrencyCode; JXLTSalesVatBook.JXLTCurrency)
            { }
            column(InvoiceAmountLCY; JXLTSalesVatBook.JXLTInvoiceAmountLCY)
            { }
            column(IIBBArba; JXLTSalesVatBook.JXLTIIBBArba)
            { }

            column(IIBBCaba; JXLTSalesVatBook.JXLTIIBBCaba)
            { }

            trigger OnPreDataItem()
            begin
                JXLTSalesVatBook.Reset();
                SetRange(Number, 1, JXLTSalesVatBook.Count());
            end;

            trigger OnAfterGetRecord()
            begin
                if (Number = 1) then
                    JXLTSalesVatBook.FindFirst()
                else
                    JXLTSalesVatBook.Next();

                if StrPos(JXLTSalesVatBook.JXLTVATRegistrationNo, '-') = 0 then
                    JXLTSalesVatBook.JXLTVATRegistrationNo := InsStr((InsStr(JXLTSalesVatBook.JXLTVATRegistrationNo, '-', 3)), '-', 12)
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Dates)
                {
                    Caption = 'Dates', Comment = 'ESP=Fechas';
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
            area(processing)
            {
            }
        }
    }

    procedure SetDates(_FromDate: Date; _ToDate: Date)
    begin
        FromDate := _FromDate;
        ToDate := _ToDate;
    end;

    var
        CompanyInfo: Record "Company Information";
        JXLTSalesVatBook: Record JXLTVatBookTmp temporary;
        VatEntry: Record "VAT Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TaxGroup: Record "Tax Group";
        LTFiscalType: Record JXLTFiscalType;
        GenLedgerSetup: Record "General Ledger Setup";
        FromDate: Date;
        ToDate: Date;
        ReportKey: Integer;
}