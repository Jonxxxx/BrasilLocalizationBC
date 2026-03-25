report 83501 JXBRPurchVatBook
{
    Caption = 'Purch VAT book', Comment = 'ESP=Libro IVA compras';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    DefaultLayout = RDLC;
    RDLCLayout = 'Src/ReportLayout/BRPurchVatBook.rdl';

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number) order(ascending) where(Number = const(1));

            column(CompanyInfo_Number; Header.Number)
            {

            }
            column("CompanyInfo_City"; CompanyInfo.City)
            {

            }
            column("CompanyInfo_VATRegistrationNo"; CompanyInfo."VAT Registration No.")
            {

            }
            column("CompanyInfo_Name"; CompanyInfo.Name)
            {

            }
            column("CompanyInfo_Address"; CompanyInfo.Address)
            {

            }
            column(CompanyInfo_County; CompanyInfo.County)
            {

            }
            column(CompanyInfo_PostCode; CompanyInfo."Post Code")
            {

            }
            column(FromDate; FromDate)
            {

            }
            column(ToDate; ToDate)
            {

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

        dataitem("Purch. Inv. Header"; "Purch. Inv. Header")
        {
            DataItemTableView = sorting("No.") order(ascending) where(JXLTNotShowInBooks = filter(False));
            ;

            trigger OnPreDataItem()
            begin
                "Purch. Inv. Header".SetRange("Posting Date", FromDate, ToDate);
                "Purch. Inv. Header".SetRange(JXInvoiceType, "Purch. Inv. Header".JXInvoiceType::Invoice);
            end;

            trigger OnAfterGetRecord()
            var
                TaxJurisdictionTemp: Record "Tax Jurisdiction" temporary;
                GLAccount: Record "G/L Account";
            begin
                "Purch. Inv. Header".CalcFields("Amount Including VAT");
                JXLTPurchVatBook.Init();
                ReportKey += 1;
                JXLTPurchVatBook.JXLTKey := ReportKey;
                JXLTPurchVatBook.JXLTPostingDate := "Purch. Inv. Header"."Posting Date";
                JXLTPurchVatBook.JXLTDocumentDate := "Purch. Inv. Header"."Document Date";
                JXLTPurchVatBook.JXLTInvoiceNumber := "Purch. Inv. Header"."Vendor Invoice No.";
                JXLTPurchVatBook.JXLTCompanyName := "Purch. Inv. Header"."Pay-to Name";
                JXLTPurchVatBook.JXLTVATRegistrationNo := "Purch. Inv. Header"."VAT Registration No.";
                JXLTPurchVatBook.JXLTTaxAreaCode := "Purch. Inv. Header"."Tax Area Code";
                JXLTPurchVatBook.JXLTProvince := "Purch. Inv. Header".JXLTProvince;
                JXLTPurchVatBook.JXLTInvoiceType := Format("Purch. Inv. Header".JXInvoiceType::Invoice);
                JXLTPurchVatBook.JXLTInvoiceAmount := Abs("Purch. Inv. Header"."Amount Including VAT");

                if ("Purch. Inv. Header"."Currency Code" <> '') then
                    JXLTPurchVatBook.JXLTInvoiceAmountLCY := Abs("Purch. Inv. Header"."Amount Including VAT") / "Purch. Inv. Header"."Currency Factor"
                else
                    JXLTPurchVatBook.JXLTInvoiceAmountLCY := Abs("Purch. Inv. Header"."Amount Including VAT");
                JXLTPurchVatBook.JXLTCurrency := "Purch. Inv. Header"."Currency Code";

                PurchInvLine.Reset();
                PurchInvLine.SetRange(PurchInvLine."Document No.", "Purch. Inv. Header"."No.");
                if PurchInvLine.FindSet() then
                    repeat
                        TaxGroup.Reset();
                        TaxGroup.SetRange(TaxGroup."Code", PurchInvLine."Tax Group Code");
                        if TaxGroup.FindFirst() then
                            case TaxGroup.JXLTType of
                                TaxGroup.JXLTType::"No base":
                                    if "Purch. Inv. Header"."Currency Code" <> '' then
                                        JXLTPurchVatBook.JXLTNoBaseAmount += Abs(PurchInvLine."Line Amount") / "Purch. Inv. Header"."Currency Factor"
                                    else
                                        JXLTPurchVatBook.JXLTNoBaseAmount += Abs(PurchInvLine."Line Amount");
                                TaxGroup.JXLTType::"Exempt base":
                                    if "Purch. Inv. Header"."Currency Code" <> '' then
                                        JXLTPurchVatBook.JXLTExemptBaseAmount += Abs(PurchInvLine."Line Amount") / "Purch. Inv. Header"."Currency Factor"
                                    else
                                        JXLTPurchVatBook.JXLTExemptBaseAmount += Abs(PurchInvLine."Line Amount");
                            end;
                    until PurchInvLine.Next() = 0;

                TaxJurisdictionTemp.DeleteAll();
                VatEntry.Reset();
                VatEntry.SetRange("Document Type", VatEntry."Document Type"::Invoice);
                VatEntry.SetRange("Document No.", "Purch. Inv. Header"."No.");
                if VatEntry.FindSet() then
                    repeat
                        TaxJurisdictionTemp.Reset();
                        TaxJurisdictionTemp.SetRange(TaxJurisdictionTemp.Code, Format(VatEntry."Sales Tax Connection No."));
                        if not TaxJurisdictionTemp.FindFirst() then begin
                            JXLTPurchVatBook.JXLTBaseAmount += Abs(VatEntry.Base);

                            TaxJurisdictionTemp.Init();
                            TaxJurisdictionTemp.Code := Format(VatEntry."Sales Tax Connection No.");
                            TaxJurisdictionTemp.Insert(false);
                        end;

                        TaxJurisdiction.Reset();
                        TaxJurisdiction.SetRange(TaxJurisdiction."Code", VatEntry."Tax Jurisdiction Code");
                        if TaxJurisdiction.FindFirst() then
                            case TaxJurisdiction.JXBRTaxIdentification of
                                TaxJurisdiction.JXBRTaxIdentification::ISS:
                                    JXLTPurchVatBook.JXLTVAT105 += Abs(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::COFINS:
                                    JXLTPurchVatBook.JXLTVAT21 += Abs(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::PIS:
                                    JXLTPurchVatBook.JXLTVAT27 += Abs(VatEntry.Amount);
                            end;
                    until VatEntry.Next() = 0;

                JXLTPurchVatBook.JXLTFiscalType := LTFiscalType.GetDescription(JXLTFiscalType);

                //Check dif amount
                /*
                JXLTPaymentSetup.Get();
                if JXLTPaymentSetup.JXLTCheckAmountVAT then begin
                    CheckAmount := (JXLTPurchVatBook.JXLTBaseAmount + JXLTPurchVatBook.JXLTNoBaseAmount + JXLTPurchVatBook.JXLTExemptBaseAmount + JXLTPurchVatBook.JXLTVAT105 + JXLTPurchVatBook.JXLTVAT21 + JXLTPurchVatBook.JXLTVAT27 + JXLTPurchVatBook.JXLTVATPercep + JXLTPurchVatBook.JXLTIIBB + JXLTPurchVatBook.JXLTSpecial);
                    if ((JXLTPurchVatBook.JXLTInvoiceAmountLCY - CheckAmount) <> 0) then
                        JXLTPurchVatBook.JXLTBaseAmount += (JXLTPurchVatBook.JXLTInvoiceAmountLCY - CheckAmount);
                end;
                */
                //Check dif amount END

                JXLTPurchVatBook.Insert();
            end;

        }
        dataitem("Purch. Debit Memo Header";
        "Purch. Inv. Header")
        {
            DataItemTableView = sorting("No.") order(Ascending) where(JXLTNotShowInBooks = filter(False));
            ;

            trigger OnPreDataItem()
            begin
                "Purch. Debit Memo Header".SetRange("Posting Date", FromDate, ToDate);
                "Purch. Debit Memo Header".SetRange(JXInvoiceType, "Purch. Debit Memo Header".JXInvoiceType::DebitMemo);
            end;

            trigger OnAfterGetRecord()
            var
                TaxJurisdictionTemp: Record "Tax Jurisdiction" temporary;
                GLAccount: Record "G/L Account";
            begin
                "Purch. Debit Memo Header".CalcFields("Amount Including VAT");
                JXLTPurchVatBook.Init();
                ReportKey += 1;
                JXLTPurchVatBook.JXLTKey := ReportKey;
                JXLTPurchVatBook.JXLTPostingDate := "Purch. Debit Memo Header"."Posting Date";
                JXLTPurchVatBook.JXLTDocumentDate := "Purch. Debit Memo Header"."Document Date";
                JXLTPurchVatBook.JXLTInvoiceNumber := "Purch. Debit Memo Header"."Vendor Invoice No.";
                JXLTPurchVatBook.JXLTCompanyName := "Purch. Debit Memo Header"."Pay-to Name";
                JXLTPurchVatBook.JXLTVATRegistrationNo := "Purch. Debit Memo Header"."VAT Registration No.";
                JXLTPurchVatBook.JXLTTaxAreaCode := "Purch. Debit Memo Header"."Tax Area Code";
                JXLTPurchVatBook.JXLTProvince := "Purch. Debit Memo Header".JXLTProvince;
                JXLTPurchVatBook.JXLTInvoiceType := Format("Purch. Debit Memo Header".JXInvoiceType::DebitMemo);
                JXLTPurchVatBook.JXLTInvoiceAmount := Abs("Purch. Debit Memo Header"."Amount Including VAT");

                if ("Purch. Debit Memo Header"."Currency Code" <> '') then
                    JXLTPurchVatBook.JXLTInvoiceAmountLCY := Abs("Purch. Debit Memo Header"."Amount Including VAT") / "Purch. Debit Memo Header"."Currency Factor"
                else
                    JXLTPurchVatBook.JXLTInvoiceAmountLCY := Abs("Purch. Debit Memo Header"."Amount Including VAT");
                JXLTPurchVatBook.JXLTCurrency := "Purch. Debit Memo Header"."Currency Code";

                PurchInvLine.Reset();
                PurchInvLine.SetRange(PurchInvLine."Document No.", "Purch. Debit Memo Header"."No.");
                if PurchInvLine.FindSet() then
                    repeat
                        TaxGroup.Reset();
                        TaxGroup.SetRange(TaxGroup."Code", PurchInvLine."Tax Group Code");
                        if TaxGroup.FindFirst() then
                            case TaxGroup.JXLTType of
                                TaxGroup.JXLTType::"No base":
                                    if "Purch. Debit Memo Header"."Currency Code" <> '' then
                                        JXLTPurchVatBook.JXLTNoBaseAmount += Abs(PurchInvLine."Line Amount") / "Purch. Debit Memo Header"."Currency Factor"
                                    else
                                        JXLTPurchVatBook.JXLTNoBaseAmount += Abs(PurchInvLine."Line Amount");
                                TaxGroup.JXLTType::"Exempt base":
                                    if "Purch. Debit Memo Header"."Currency Code" <> '' then
                                        JXLTPurchVatBook.JXLTExemptBaseAmount += Abs(PurchInvLine."Line Amount") / "Purch. Debit Memo Header"."Currency Factor"
                                    else
                                        JXLTPurchVatBook.JXLTExemptBaseAmount += Abs(PurchInvLine."Line Amount");
                            end;
                    until PurchInvLine.Next() = 0;

                TaxJurisdictionTemp.DeleteAll();
                VatEntry.Reset();
                VatEntry.SetRange("Document Type", VatEntry."Document Type"::Invoice);
                VatEntry.SetRange("Document No.", "Purch. Debit Memo Header"."No.");
                if VatEntry.FindSet() then
                    repeat
                        TaxJurisdictionTemp.Reset();
                        TaxJurisdictionTemp.SetRange(TaxJurisdictionTemp.Code, Format(VatEntry."Sales Tax Connection No."));
                        if not TaxJurisdictionTemp.FindFirst() then begin
                            JXLTPurchVatBook.JXLTBaseAmount += Abs(VatEntry.Base);

                            TaxJurisdictionTemp.Init();
                            TaxJurisdictionTemp.Code := Format(VatEntry."Sales Tax Connection No.");
                            TaxJurisdictionTemp.Insert(false);
                        end;

                        TaxJurisdiction.Reset();
                        TaxJurisdiction.SetRange(TaxJurisdiction."Code", VatEntry."Tax Jurisdiction Code");
                        if TaxJurisdiction.FindFirst() then
                            case TaxJurisdiction.JXBRTaxIdentification of
                                TaxJurisdiction.JXBRTaxIdentification::ISS:
                                    JXLTPurchVatBook.JXLTVAT105 += Abs(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::COFINS:
                                    JXLTPurchVatBook.JXLTVAT21 += Abs(VatEntry.Amount);

                                TaxJurisdiction.JXBRTaxIdentification::PIS:
                                    JXLTPurchVatBook.JXLTVAT27 += Abs(VatEntry.Amount);
                            end;
                    until VatEntry.Next() = 0;

                JXLTPurchVatBook.JXLTFiscalType := LTFiscalType.GetDescription(JXLTFiscalType);

                //Check dif amount
                /*JXLTPaymentSetup.Get();
                if JXLTPaymentSetup.JXLTCheckAmountVAT then begin
                    CheckAmount := (JXLTPurchVatBook.JXLTBaseAmount + JXLTPurchVatBook.JXLTNoBaseAmount + JXLTPurchVatBook.JXLTExemptBaseAmount + JXLTPurchVatBook.JXLTVAT105 + JXLTPurchVatBook.JXLTVAT21 + JXLTPurchVatBook.JXLTVAT27 + JXLTPurchVatBook.JXLTVATPercep + JXLTPurchVatBook.JXLTIIBB + JXLTPurchVatBook.JXLTSpecial);
                    if ((JXLTPurchVatBook.JXLTInvoiceAmountLCY - CheckAmount) <> 0) then
                        JXLTPurchVatBook.JXLTBaseAmount += (JXLTPurchVatBook.JXLTInvoiceAmountLCY - CheckAmount);
                end;*/
                //Check dif amount END

                JXLTPurchVatBook.Insert();
            end;
        }
        dataitem("Purch. Cr. Memo Hdr."; "Purch. Cr. Memo Hdr.")
        {
            DataItemTableView = sorting("No.") order(Ascending) where(JXLTNotShowInBooks = filter(False));
            ;

            trigger OnPreDataItem()
            begin
                "Purch. Cr. Memo Hdr.".SetRange("Posting Date", FromDate, ToDate);
            end;

            trigger OnAfterGetRecord()
            var
                TaxJurisdictionTemp: Record "Tax Jurisdiction" temporary;
                GLAccount: Record "G/L Account";
            begin
                "Purch. Cr. Memo Hdr.".CalcFields("Amount Including VAT");
                JXLTPurchVatBook.Init();
                ReportKey += 1;
                JXLTPurchVatBook.JXLTKey := ReportKey;
                JXLTPurchVatBook.JXLTPostingDate := "Purch. Cr. Memo Hdr."."Posting Date";
                JXLTPurchVatBook.JXLTDocumentDate := "Purch. Cr. Memo Hdr."."Document Date";
                JXLTPurchVatBook.JXLTInvoiceNumber := "Purch. Cr. Memo Hdr."."Vendor Cr. Memo No.";
                JXLTPurchVatBook.JXLTCompanyName := "Purch. Cr. Memo Hdr."."Pay-to Name";
                JXLTPurchVatBook.JXLTVATRegistrationNo := "Purch. Cr. Memo Hdr."."VAT Registration No.";
                JXLTPurchVatBook.JXLTTaxAreaCode := "Purch. Cr. Memo Hdr."."Tax Area Code";
                JXLTPurchVatBook.JXLTProvince := "Purch. Cr. Memo Hdr.".JXLTProvince;
                JXLTPurchVatBook.JXLTInvoiceType := 'Nota de crédito';
                JXLTPurchVatBook.JXLTInvoiceAmount := Abs("Purch. Cr. Memo Hdr."."Amount Including VAT") * -1;

                if ("Purch. Cr. Memo Hdr."."Currency Code" <> '') then
                    JXLTPurchVatBook.JXLTInvoiceAmountLCY := (Abs("Purch. Cr. Memo Hdr."."Amount Including VAT") * -1) / "Purch. Cr. Memo Hdr."."Currency Factor"
                else
                    JXLTPurchVatBook.JXLTInvoiceAmountLCY := Abs("Purch. Cr. Memo Hdr."."Amount Including VAT") * -1;
                JXLTPurchVatBook.JXLTCurrency := "Purch. Cr. Memo Hdr."."Currency Code";

                PurchCrMemoLine.Reset();
                PurchCrMemoLine.SetRange(PurchCrMemoLine."Document No.", "Purch. Cr. Memo Hdr."."No.");
                if PurchCrMemoLine.FindSet() then
                    repeat
                        TaxGroup.Reset();
                        TaxGroup.SetRange(TaxGroup."Code", PurchCrMemoLine."Tax Group Code");
                        if TaxGroup.FindFirst() then
                            case TaxGroup.JXLTType of
                                TaxGroup.JXLTType::"No base":
                                    if "Purch. Cr. Memo Hdr."."Currency Code" <> '' then
                                        JXLTPurchVatBook.JXLTNoBaseAmount := (Abs(PurchCrMemoLine."Line Amount") * -1) / "Purch. Cr. Memo Hdr."."Currency Factor"
                                    else
                                        JXLTPurchVatBook.JXLTNoBaseAmount += Abs(PurchCrMemoLine."Line Amount") * -1;
                                TaxGroup.JXLTType::"Exempt base":
                                    if "Purch. Cr. Memo Hdr."."Currency Code" <> '' then
                                        JXLTPurchVatBook.JXLTExemptBaseAmount := (Abs(PurchCrMemoLine."Line Amount") * -1) / "Purch. Cr. Memo Hdr."."Currency Factor"
                                    else
                                        JXLTPurchVatBook.JXLTExemptBaseAmount += Abs(PurchCrMemoLine."Line Amount") * -1;
                            end;

                    until PurchCrMemoLine.Next() = 0;

                TaxJurisdictionTemp.deleteAll();
                VatEntry.Reset();
                VatEntry.SetRange("Document Type", VatEntry."Document Type"::"Credit Memo");
                VatEntry.SetRange("Document No.", "Purch. Cr. Memo Hdr."."No.");
                if VatEntry.FindSet() then
                    repeat
                        TaxJurisdictionTemp.Reset();
                        TaxJurisdictionTemp.SetRange(TaxJurisdictionTemp.Code, Format(VatEntry."Sales Tax Connection No."));
                        if not TaxJurisdictionTemp.FindFirst() then begin
                            JXLTPurchVatBook.JXLTBaseAmount += Abs(VatEntry.Base) * -1;
                            TaxJurisdictionTemp.Init();
                            TaxJurisdictionTemp.Code := Format(VatEntry."Sales Tax Connection No.");
                            TaxJurisdictionTemp.Insert(false);
                        end;

                        TaxJurisdiction.Reset();
                        TaxJurisdiction.SetRange(TaxJurisdiction."Code", VatEntry."Tax Jurisdiction Code");
                        if TaxJurisdiction.FindFirst() then
                            case TaxJurisdiction.JXBRTaxIdentification of
                                TaxJurisdiction.JXBRTaxIdentification::ISS:
                                    JXLTPurchVatBook.JXLTVAT105 += Abs(VatEntry.Amount) * -1;

                                TaxJurisdiction.JXBRTaxIdentification::COFINS:
                                    JXLTPurchVatBook.JXLTVAT21 += Abs(VatEntry.Amount) * -1;

                                TaxJurisdiction.JXBRTaxIdentification::PIS:
                                    JXLTPurchVatBook.JXLTVAT27 += Abs(VatEntry.Amount) * -1;
                            end;
                    until VatEntry.Next() = 0;

                JXLTPurchVatBook.JXLTFiscalType := LTFiscalType.GetDescription(JXLTFiscalType);

                //Check dif amount
                /*
                JXLTPaymentSetup.Get();
                if JXLTPaymentSetup.JXLTCheckAmountVAT then begin
                    CheckAmount := (JXLTPurchVatBook.JXLTBaseAmount + JXLTPurchVatBook.JXLTNoBaseAmount + JXLTPurchVatBook.JXLTExemptBaseAmount + JXLTPurchVatBook.JXLTVAT105 + JXLTPurchVatBook.JXLTVAT21 + JXLTPurchVatBook.JXLTVAT27 + JXLTPurchVatBook.JXLTVATPercep + JXLTPurchVatBook.JXLTIIBB + JXLTPurchVatBook.JXLTSpecial);
                    if ((JXLTPurchVatBook.JXLTInvoiceAmountLCY - CheckAmount) <> 0) then
                        JXLTPurchVatBook.JXLTBaseAmount += (JXLTPurchVatBook.JXLTInvoiceAmountLCY - CheckAmount);
                end;
                */
                //Check dif amount END

                JXLTPurchVatBook.Insert();
            end;
        }

        dataitem(Temp; Integer)
        {
            DataItemTableView = sorting(Number) order(ascending);

            column(PostingDate; JXLTPurchVatBook.JXLTPostingDate)
            { }
            column(InvoiceNumber; JXLTPurchVatBook.JXLTInvoiceNumber)
            { }
            column(CompanyName; JXLTPurchVatBook.JXLTCompanyName)
            { }
            column(VATRegistrationNoo; JXLTPurchVatBook.JXLTVATRegistrationNo)
            { }
            column(Taxareacode; JXLTPurchVatBook.JXLTTaxAreaCode)
            { }
            column(Province; JXLTPurchVatBook.JXLTProvince)
            { }
            column(Invoicetype; JXLTPurchVatBook.JXLTInvoiceType)
            { }
            column(Invoiceamount; JXLTPurchVatBook.JXLTInvoiceAmount)
            { }
            column(Baseamount; JXLTPurchVatBook.JXLTBaseAmount)
            { }
            column(NoBaseamount; JXLTPurchVatBook.JXLTNoBaseAmount)
            { }
            column(ExemptBaseamount; JXLTPurchVatBook.JXLTExemptBaseAmount)
            { }
            column(VAT105; JXLTPurchVatBook.JXLTVAT105)
            { }
            column(VAT21; JXLTPurchVatBook.JXLTVAT21)
            { }
            column(VAT27; JXLTPurchVatBook.JXLTVAT27)
            { }
            column(VATpercep; JXLTPurchVatBook.JXLTVATPercep)
            { }
            column(IIBB; JXLTPurchVatBook.JXLTIIBB)
            { }
            column(Special; JXLTPurchVatBook.JXLTSpecial)
            { }
            column(FiscalType; JXLTPurchVatBook.JXLTFiscalType)
            { }
            column(CurrencyCode; JXLTPurchVatBook.JXLTCurrency)
            { }
            column(InvoiceAmountLCY; JXLTPurchVatBook.JXLTInvoiceAmountLCY)
            { }

            column(IIBBArba; JXLTPurchVatBook.JXLTIIBBArba)
            { }

            column(IIBBCaba; JXLTPurchVatBook.JXLTIIBBCaba)
            { }

            column(DocumentDate; JXLTPurchVatBook.JXLTDocumentDate)
            { }

            trigger OnPreDataItem()
            begin
                JXLTPurchVatBook.Reset();
                SetRange(Number, 1, JXLTPurchVatBook.Count());
            end;

            trigger OnAfterGetRecord()
            begin
                if (Number = 1) then
                    JXLTPurchVatBook.FindFirst()
                else
                    JXLTPurchVatBook.Next();

                if StrPos(JXLTPurchVatBook.JXLTVATRegistrationNo, '-') = 0 then
                    JXLTPurchVatBook.JXLTVATRegistrationNo := InsStr((InsStr(JXLTPurchVatBook.JXLTVATRegistrationNo, '-', 3)), '-', 12)
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
        JXLTPurchVatBook: Record JXLTVatBookTmp temporary;
        VatEntry: Record "VAT Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        TaxGroup: Record "Tax Group";
        LTFiscalType: Record JXLTFiscalType;
        GenLedgerSetup: Record "General Ledger Setup";
        FromDate: Date;
        ToDate: Date;
        ReportKey: Integer;
        CheckAmount: Decimal;
}