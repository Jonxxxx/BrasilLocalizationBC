enum 83501 JXBRFiscalTypes
{
    Extensible = true;
    Caption = 'Tipo Fiscal Brasil';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; EXTERIOR)
    {
        Caption = 'Cliente/proveedor exterior';
    }
    value(2; ISENTO)
    {
        Caption = 'Exento';
    }
    value(3; "LUCRO_PRESUMIDO")
    {
        Caption = 'Lucro Presumido';
    }
    value(4; "LUCRO_REAL")
    {
        Caption = 'Lucro Real';
    }
    value(5; MEI)
    {
        Caption = 'Microempreendedor Individual';
    }
    value(6; "PERS_FISICA_RES")
    {
        Caption = 'Persona física residente';
    }
    value(7; "PERS_FISICA_NO_RES")
    {
        Caption = 'Persona física no residente';
    }
    value(8; "SIMPLES_NACIONAL")
    {
        Caption = 'Simples Nacional';
    }
    value(9; "ORG_PUBLICO")
    {
        Caption = 'Órgano público / administración';
    }
    value(10; "FINANCEIRA")
    {
        Caption = 'Institución financiera';
    }
    value(11; "COOPERATIVA")
    {
        Caption = 'Cooperativa';
    }
}
