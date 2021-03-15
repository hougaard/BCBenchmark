codeunit 89325 "Template Test Hgd"
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
        ScoreKeeper.Add(Codeunit::"Template Test Hgd", Score);
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin

    end;

    [Test]
    procedure RunSingleTest()
    begin

    end;

    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
}