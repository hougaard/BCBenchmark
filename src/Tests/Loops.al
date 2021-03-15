codeunit 89323 "Loops Hgd"
{
    Subtype = Test;

    trigger OnRun()
    var
        StartTime: Time;
        Score: Integer;
        RunTime: Duration;
    begin
        RunTime := 10000;
        StartTime := Time();
        repeat
            RunSingleTest();
            Score += 1;
        until Time() - StartTime > RunTime;
        ScoreKeeper.Add(Codeunit::"Loops Hgd", Score);
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin

    end;

    [Test]
    procedure RunSingleTest()
    var
        i: Integer;
        d: Integer;
        z: Integer;
    begin
        for i := 1 to 1000000 do begin
            for d := 1 to 100 do begin
                z := i - d;
            end;
        end;
    end;

    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
}