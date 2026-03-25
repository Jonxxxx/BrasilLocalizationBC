pageextension 83502 JXBRBusinessManagerRC extends "Business Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(JXBRLocalization)
            {
                Caption = 'Brasil', Comment = 'ESP="Brasil"';
                Visible = false;

                group(JXBRTaxesConfigurations)
                {
                    Caption = 'Perceptions setup', Comment = 'ESP="Conf. percepcion"';

                    action(JXBRTaxJurisdictions)
                    {
                        Caption = 'Tax jurisdictions', Comment = 'ESP="Jurisdicciones de impuestos"';
                        RunObject = page JXBRTaxJurisdictions;
                        ApplicationArea = JXBRshowBrasil;
                        Image = SalesTax;
                        ToolTip = 'Tax jurisdictions setup', Comment = 'ESP="Configuracion de jurisdicciones de impuestos"';
                    }

                    action(JXBRTaxGroups)
                    {
                        Caption = 'Tax groups', Comment = 'ESP="Grupos de impuestos"';
                        RunObject = page "Tax Groups";
                        ApplicationArea = JXBRshowBrasil;
                        Image = TaxSetup;
                        ToolTip = 'Tax groups setup', Comment = 'ESP="Configuracion de grupos de impuestos"';
                    }

                    action(JXBRTaxAreas)
                    {
                        Caption = 'Tax area', Comment = 'ESP="Areas de impuestos"';
                        RunObject = page JXLTTaxAreas;
                        ApplicationArea = JXBRshowBrasil;
                        Image = CollectedTax;
                        ToolTip = 'Tax area setup', Comment = 'ESP="Configuracion de areas de impuestos"';
                    }

                    action(JXBRTaxDetails)
                    {
                        Caption = 'Tax details', Comment = 'ESP="Detalles de impuestos"';
                        RunObject = page JXLTTaxDetails;
                        ApplicationArea = JXBRshowBrasil;
                        Image = TaxDetail;
                        ToolTip = 'Tax details setup', Comment = 'ESP="Configuracion de detalles de impuestos"';
                    }
                    action(JXBRFiscalTypes)
                    {
                        Caption = 'Fiscal type', Comment = 'ESP="Tipo fiscal"';
                        RunObject = page JXBRFiscalTypes;
                        ApplicationArea = JXBRshowBrasil;
                        Image = TaxDetail;
                        ToolTip = 'Fiscal types setup', Comment = 'ESP="Configuracion de tipos fiscales"';
                    }
                    action(JXBRProvinces)
                    {
                        Caption = 'Province', Comment = 'ESP="Provincia"';
                        RunObject = page JXLTProvinces;
                        ApplicationArea = JXBRshowBrasil;
                        Image = TaxDetail;
                        ToolTip = 'Province setup', Comment = 'ESP="Configuracion de Provincias"';
                    }
                }

                group(JXBRWithholdingConfiguratons)
                {
                    Caption = 'Withholdings setup', Comment = 'ESP="Conf. retenciones"';

                    action(JXBRWithholdTax)
                    {
                        Caption = 'Withholding taxes', Comment = 'ESP="Impuesto retenciones"';
                        RunObject = page JXLTWithholdingTax;
                        ApplicationArea = JXBRshowBrasil;
                        Image = Setup;
                        ToolTip = 'Withholding taxes setup', Comment = 'ESP="Configuracion de impuesto retenciones"';
                    }

                    action(JXBRWithholdTaxCond)
                    {
                        Caption = 'Withholding Tax conditions', Comment = 'ESP="Condicion de impuesto retenciones"';
                        RunObject = page JXLTWithholdTaxCondition;
                        ApplicationArea = JXBRshowBrasil;
                        Image = TaxSetup;
                        ToolTip = 'Withholding Tax conditions setup', Comment = 'ESP="Configuracion de condicion de impuesto retenciones"';
                    }

                    action(JXBRWithholdTaxDetail)
                    {
                        Caption = 'Witholding detail', Comment = 'ESP="Detalle retencion"';
                        RunObject = page JXLTWithholdDetailEntry;
                        ApplicationArea = JXBRshowBrasil;
                        Image = TaxDetail;
                        ToolTip = 'Witholding detail setup', Comment = 'ESP="Configuracion detalle retencion"';
                    }

                    action(JXBRWithholdTaxScale)
                    {
                        Caption = 'Witholding scale', Comment = 'ESP="Escala retencion"';
                        RunObject = page JXLTWithholdScale;
                        ApplicationArea = JXBRshowBrasil;
                        Image = GeneralPostingSetup;
                        ToolTip = 'Witholding scale setup', Comment = 'ESP="Configuracion escala retencion"';
                    }

                    action(JXBRWithholdAreaList)
                    {
                        Caption = 'Withholding area list', Comment = 'ESP="Lista de area de retencion"';
                        RunObject = page JXLTWithholdAreaList;
                        ApplicationArea = JXBRshowBrasil;
                        Image = SetupList;
                        ToolTip = 'Withholding area list', Comment = 'ESP="Lista de area de retencion"';
                    }
                }

                group(JXBRTreasury)
                {
                    Caption = 'Treasury', Comment = 'ESP=Tesoreria"';

                    action(JXBRPaymentJournal)
                    {
                        Caption = 'Payment Journal (Vendors)', Comment = 'ESP="Diario de pago (Proveedores)"';
                        RunObject = page "Payment Journal";
                        ApplicationArea = JXBRshowBrasil;
                        Image = PaymentJournal;
                        ToolTip = 'Payment Journal (Vendors)', Comment = 'ESP="Diario de pago (Proveedores)"';
                    }

                    action(JXBRReceiptJournal)
                    {
                        Caption = 'Payment Journal (Customers)', Comment = 'ESP="Diario de pago (Clientes)"';
                        RunObject = page "Cash Receipt Journal";
                        ApplicationArea = JXBRshowBrasil;
                        Image = CashReceiptJournal;
                        ToolTip = 'Payment Journal (Customers)', Comment = 'ESP="Diario de pago (Clientes)"';
                    }

                    action(JXBRPostedPaymOrders)
                    {
                        Caption = 'History payment orders', Comment = 'ESP="Historico ordenes de pago"';
                        RunObject = page JXLTHistoryPaymOrderList;
                        ApplicationArea = JXBRshowBrasil;
                        Image = PaymentHistory;
                        ToolTip = 'History payment orders', Comment = 'ESP="Historico ordenes de pago"';
                    }

                    action(JXBRPostedReceipts)
                    {
                        Caption = 'History receipts', Comment = 'ESP="Historico de recibos"';
                        RunObject = page JXLTPostedReceiptsList;
                        ApplicationArea = JXBRshowBrasil;
                        Image = PostedReceipts;
                        ToolTip = 'History receipts', Comment = 'ESP="Historico de recibos"';
                    }

                    action(JXBRThirdPartyCheck)
                    {
                        Caption = 'Third party check', Comment = 'ESP="Cheques de terceros"';
                        RunObject = page JXLTThirdPartyCheck;
                        ApplicationArea = JXBRshowBrasil;
                        Image = CheckList;
                        ToolTip = 'Third party check', Comment = 'ESP="Cheques de terceros"';
                    }

                    action(JXBRTreasurySetup)
                    {
                        Caption = 'Treasury setup', Comment = 'ESP="Conf. tesoreria"';
                        RunObject = page JXLTPaymentSetup;
                        ApplicationArea = JXBRshowBrasil;
                        Image = PostedReceipts;
                        ToolTip = 'Treasury setup', Comment = 'ESP="Configuracion tesoreria"';
                    }
                }

                group(JXBRlectronicInvoice)//Brazil
                {
                    Caption = 'Electronic Doc. Setup', Comment = 'ESP="Config. doc. electronicos"';

                    group(JXBRFEParams)
                    {
                        Caption = 'Electronic Invoice', Comment = 'ESP="Factura electronica"';

                        /*action(JXLTFESetup)
                        {
                            Caption = 'Setup Electronic invoice', Comment = 'ESP="Conf. Factura electronica"';
                            RunObject = page JXLTFEConfiguration;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Setup;
                            ToolTip = 'Electronic Doc. Setup', Comment = 'ESP="Configuracion factura electronica"';
                        }*/

                        action(JXBRPointOfSale)
                        {
                            Caption = 'Point of sale', Comment = 'ESP="Puntos de venta"';
                            RunObject = page JXLTPointOfSale;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Setup;
                            ToolTip = 'Point of sale setup', Comment = 'ESP="Configuracion de puntos de venta"';
                        }

                        action(JXBRFEDocumentTypes)
                        {
                            Caption = 'Document types', Comment = 'ESP="Tipos de documento"';
                            RunObject = page JXLTFEDocumentTypes;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Setup;
                            ToolTip = 'Document types setup', Comment = 'ESP="Configuracion tipos de documento"';
                        }

                        action(JXBRFECustDocumentTypes)
                        {
                            Caption = 'Customer document types', Comment = 'ESP="Tipos de documento clientes"';
                            RunObject = page JXLTFECustDocumentTypes;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Setup;
                            ToolTip = 'Customer document types setup', Comment = 'ESP="Configuracion tipos de documento clientes"';
                        }

                        action(JXBRFEVATDocumentTypes)
                        {
                            Caption = 'Document vat types', Comment = 'ESP="Tipos de documento impuestos"';
                            RunObject = page JXLTFEVATDocumentTypes;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Setup;
                            ToolTip = 'Document vat types setup', Comment = 'ESP="Configuracion tipos de documento impuestos"';
                        }

                        action(JXBRSeriesFEConfiguration)
                        {
                            Caption = 'Document series', Comment = 'ESP="Series de documentos"';
                            RunObject = page JXLTSeriesFEConfiguration;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Setup;
                            ToolTip = 'Document series setup', Comment = 'ESP="Configuracion series de documentos"';
                        }
                    }

                    group(JXBRAdditionalFunctions)
                    {
                        Caption = 'Additonal functions', Comment = 'ESP="Funciones adicionales"';

                        action(JXBRLocalizationReports)
                        {
                            Caption = 'Localization reports', Comment = 'ESP="Reportes localización"';
                            RunObject = page JXBRExecuteReports;
                            ApplicationArea = JXBRshowBrasil;
                            Image = Report;
                            ToolTip = 'Localization reports', Comment = 'ESP="Reportes localización"';
                        }

                        action(JXBRDocumentCorrection)
                        {
                            Caption = 'Document correction', Comment = 'ESP="Corrector de documentos"';
                            RunObject = page JXLTDocumentsCorrection;
                            ApplicationArea = JXBRshowBrasil;
                            Image = AdjustEntries;
                            ToolTip = 'Document correction', Comment = 'ESP="Corrector de documentos"';
                        }
                    }
                }
            }
        }
    }
}