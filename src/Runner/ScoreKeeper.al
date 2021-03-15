codeunit 89322 "ScoreKeeper Hgd"
{
    SingleInstance = true;
    procedure Done()
    var
        T: JsonToken;
        Start: DateTime;
    begin
        //GetFromIsolated();
        if CurrentScore.Get('Start', T) then
            Start := T.AsValue().AsDateTime();
        CurrentScore.Add('Finished', CurrentDateTime());
        CurrentScore.Add('Elapsed', CurrentDateTime() - Start);
        UpdateIsolated();
    end;

    procedure Start()
    var
        Tests: JsonObject;
    begin
        if IsolatedStorage.Contains('SCORE') then
            IsolatedStorage.Delete('SCORE');

        Clear(CurrentScore);
        CurrentScore.Add('Total', 0);
        CurrentScore.Add('Tests', Tests);
        CurrentScore.Add('Start', CurrentDateTime());
        UpdateIsolated();
    end;

    procedure UpdateIsolated()
    var
        txt: Text;
    begin
        CurrentScore.WriteTo(txt);
        if IsolatedStorage.Contains('SCORE') then
            IsolatedStorage.Delete('SCORE');
        IsolatedStorage.Set('SCORE', txt);
    end;

    procedure GetFromIsolated()
    var
        txt: Text;
    begin
        if IsolatedStorage.Get('SCORE', txt) then
            CurrentScore.ReadFrom(txt);
    end;

    procedure Add(CU: Integer; P: Integer)
    var
        Test: JsonObject;
        T: JsonToken;
        Total: Integer;
    begin
        //GetFromIsolated();
        Test.Add('Codeunit', CU);
        Test.Add('Score', P);
        if CurrentScore.Get('Tests', T) then
            if not T.AsObject().Contains(format(CU)) then
                T.AsObject().Add(format(CU), Test)
            else
                T.AsObject().Replace(format(CU), Test);
        if CurrentScore.Get('Total', T) then begin
            Total := T.AsValue().AsInteger();
            Total += P;
            CurrentScore.Replace('Total', Total);
        end;
        //UpdateIsolated();
    end;

    procedure Get(): JsonObject
    begin
        GetFromIsolated();
        exit(CurrentScore);
    end;

    var
        CurrentScore: JsonObject;
}
