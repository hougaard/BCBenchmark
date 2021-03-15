table 89321 "Score Hgd"
{
    TableType = Temporary;
    fields
    {
        field(1; CodeUnitNo; Integer)
        {
            Caption = 'Codeunit No';
        }
        field(2; Score; Integer)
        {
            Caption = 'Score';
        }
    }
    keys
    {
        key(PKey; CodeUnitNo)
        { }
    }
}