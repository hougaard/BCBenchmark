codeunit 89326 "Asssembly Post Hgd"
{
    Subtype = Test;

    trigger OnRun()
    var
        StartTime: Time;
        Score: Integer;
        RunTime: Duration;
    begin
        RunTime := 1000 * 60; //60 seconds
        StartTime := Time();
        repeat
            RunSingleTest();
            Score += 1;
        until Time() - StartTime > RunTime;
        ScoreKeeper.Add(Codeunit::"Asssembly Post Hgd", Score);
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin

    end;

    [Test]

    procedure RunSingleTest()
    var
        AssemblyHeader: Record "Assembly Header";
        Location: Record Location;
    begin
        LoadSetup(Location);
        AssemblyLib.CreateAssemblyOrder(AssemblyHeader, WorkDate(), Location.Code, 10);
        InitItemsStock(AssemblyHeader, Location);
        AssemblyLib.PostAssemblyHeader(AssemblyHeader, '');
    end;

    [Normal]
    local procedure LoadSetup(var Location: Record Location)
    var
        WarehouseLib: Codeunit "Library - Warehouse";
    begin
        if SetupLoaded then
            exit;

        Location.SetRange("Directed Put-away and Pick", false);
        Location.SetRange("Use As In-Transit", false);
        if not Location.FindFirst() then
            WarehouseLib.CreateLocationWithInventoryPostingSetup(Location);
        AssemblyLib.SetStockoutWarning(false);
        SetupLoaded := true;
    end;

    [Normal]
    local procedure InitItemsStock(AssemblyHeader: Record "Assembly Header"; Location: Record Location)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        if AssemblyLine.FindSet() then
            repeat
                AssemblyLib.AddItemInventory(AssemblyLine, WorkDate(), Location.Code, '', AssemblyLine."Quantity to Consume (Base)");
            until AssemblyLine.Next() = 0;
    end;

    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
        AssemblyLib: Codeunit "Library - Assembly";
        SetupLoaded: Boolean;
}