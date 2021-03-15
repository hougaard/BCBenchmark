codeunit 89321 "Sales Posting Hgd"
{
    Subtype = Test;

    trigger OnRun()
    var
        StartTime: Time;
        Score: Integer;
        RunTime: Duration;
    begin
        RunTime := 10 * 1000; // 60 Seconds
        StartTime := Time();
        repeat
            RunSingleTest();
            Score += 1;
        until Time() - StartTime > RunTime;
        ScoreKeeper.Add(Codeunit::"Sales Posting Hgd", Score);
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin

    end;

    [Test]
    procedure RunSingleTest()
    var
        SH: Record "Sales Header";
        SL: Record "Sales Line";
        Customer: Record Vendor;
        Item: Record Item;
        i: Integer;
        Post: Codeunit "Sales-Post";
    begin
        Customer.Setrange(Blocked, Customer.Blocked::" ");
        Customer.FindFirst();
        Item.Setrange(Blocked, false);
        Item.FindFirst();
        SH.init();
        SH."Document Type" := SH."Document Type"::Order;
        SH.Insert(true);
        SH.Validate("Posting Date", Today());
        SH.Validate("Sell-to Customer No.", Customer."No.");
        SH.Modify(true);
        for i := 1 to 10 do begin
            Clear(SL);
            SL.Init();
            SL."Document Type" := SH."Document Type";
            SL."Document No." := SH."No.";
            SL."Line No." := i * 10000;
            SL.Insert(True);
            SL.Validate(Type, SL.Type::Item);
            SL.Validate("No.", Item."No.");
            SL.Validate(Quantity, i);
            SL.Modify(true);
        end;
        SH.Invoice := true;
        SH.Ship := true;
        Post.Run(SH);
    end;

    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
}