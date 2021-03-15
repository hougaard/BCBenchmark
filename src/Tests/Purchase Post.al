codeunit 89324 "Purchase Posting Hgd"
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
        ScoreKeeper.Add(Codeunit::"Purchase Posting Hgd", Score);
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin

    end;

    [Test]
    procedure RunSingleTest()
    var
        PH: Record "Purchase Header";
        PL: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
        i: Integer;
        Post: Codeunit "Purch.-Post";
    begin
        Vendor.Setrange(Blocked, Vendor.Blocked::" ");
        Vendor.FindFirst();
        Item.Setrange(Blocked, false);
        Item.FindFirst();
        PH.init();
        PH."Document Type" := PH."Document Type"::Order;
        PH.Insert(true);
        PH.Validate("Posting Date", Today());
        PH.Validate("Buy-from Vendor No.", Vendor."No.");
        PH.Validate("Vendor Invoice No.", 'Inv#' + PH."No.");
        PH.Modify(true);
        for i := 1 to 10 do begin
            Clear(PL);
            PL.Init();
            PL."Document Type" := PH."Document Type";
            PL."Document No." := PH."No.";
            PL."Line No." := i * 10000;
            PL.Insert(True);
            PL.Validate(Type, PL.Type::Item);
            PL.Validate("No.", Item."No.");
            PL.Validate(Quantity, i);
            PL.Modify(true);
        end;
        PH.Receive := true;
        PH.Invoice := true;
        Post.Run(PH);
    end;

    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
}