codeunit 89320 "Benchmark Runner Hgd"
{
    TestIsolation = Codeunit;
    Subtype = TestRunner;

    trigger OnRun()
    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
        SessionId: Integer;
    begin
        ScoreKeeper.Start();
        Codeunit.Run(CODEUNIT::"Sales Posting Hgd");
        Codeunit.Run(CODEUNIT::"Purchase Posting Hgd");
        Codeunit.Run(Codeunit::"Loops Hgd");
        Codeunit.Run(Codeunit::"Asssembly Post Hgd");
        //Codeunit.Run(Codeunit::"Template Test Hgd");
        ScoreKeeper.Done();
    end;
}