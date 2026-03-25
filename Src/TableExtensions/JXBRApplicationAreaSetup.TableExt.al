tableextension 83506 JXBRApplicationAreaSetup extends "Application Area Setup"
{
    fields
    {
        field(83500; JXBRshowBrasil; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Show Loc Brasil';
        }

        field(83501; JXBRNotshowBrasil; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Not Show Loc Brasil';
        }
    }
}