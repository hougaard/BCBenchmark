codeunit 89326 "Asssembly Posting Hgd"
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
        ScoreKeeper.Add(Codeunit::"Asssembly Posting Hgd", Score);
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
        Item: Record Item;
    begin
        LoadSetup(Location, Item);
        CreateAssemblyOrder(AssemblyHeader, WorkDate(), Location.Code, Item, 10);
        PostAssemblyOrder(AssemblyHeader);
    end;

    [Normal]
    local procedure LoadSetup(var Location: Record Location; var Item: Record Item)
    var
        AssemblySetup: Record "Assembly Setup";
        InventorySetup: Record "Inventory Setup";
        ItemJnlTemplateCode: Code[10];
        ItemJnlBatchCode: Code[10];
        LineNo: Integer;
    begin
        Location.SetRange("Directed Put-away and Pick", false);
        Location.SetRange("Use As In-Transit", false);
        Location.SetRange("Bin Mandatory", false);
        Location.FindFirst();

        Item.SetRange(Blocked, false);
        Item.SetRange("Assembly BOM", true);
        Item.FindFirst();

        if SetupInit then
            exit;

        AssemblySetup.Get();
        AssemblySetup.Validate("Stockout Warning", false);
        AssemblySetup.Modify(true);

        SetupItemJnl(ItemJnlTemplateCode, ItemJnlBatchCode);
        InitStock(Item."No.", Location, ItemJnlTemplateCode, ItemJnlBatchCode);

        SetupInit := true;
    end;

    [Normal]
    local procedure SetupItemJnl(var ItemJnlTemplateCode: Code[10]; var ItemJnlBatchCode: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        ItemJournalTemplate.SetRange("Type", ItemJournalTemplate."Type"::Item);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.DeleteAll(true);

        ItemJnlTemplateCode := ItemJournalBatch."Journal Template Name";
        ItemJnlBatchCode := ItemJournalBatch.Name;
    end;

    [Normal]
    local procedure InitStock(ItemNo: Code[20]; Location: Record Location; ItemJnlTemplate: Code[10]; ItemJnlBatch: Code[10])
    var
        BOMComponent: Record "BOM Component";
        ItemComponent: Record Item;
    begin
        BOMComponent.SetRange("Parent Item No.", ItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Resource);
        BOMComponent.DeleteAll(true);

        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        if not BOMComponent.FindSet() then
            exit;

        repeat
            InitStock(BOMComponent."No.", Location, ItemJnlTemplate, ItemJnlBatch);
            CreateItemJnlLine(ItemJnlTemplate, ItemJnlBatch, BOMComponent."No.", BOMComponent."Variant Code", BOMComponent."Unit of Measure Code", Location, BOMComponent."Quantity per" * 99999);
        until BOMComponent.Next() = 0;
    end;

    local procedure CreateItemJnlLine(ItemJnlTemplate: Code[10]; ItemJnlBatch: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; Location: Record Location; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPost: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", ItemJnlTemplate);
        ItemJournalLine.Validate("Journal Batch Name", ItemJnlBatch);
        ItemJournalLine.Validate("Document No.", 'HGD TEST');
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));
        ItemJournalLine.Validate("Document Date", CalcDate('<-1D>', ItemJournalLine."Posting Date"));
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate(Quantity, Quantity);
        ItemJournalLine.Validate("Unit of Measure Code", UOM);
        ItemJournalLine.Validate("Variant Code", VariantCode);
        ItemJournalLine.Validate("Unit Cost", Random(50));
        ItemJournalLine.Validate("Location Code", Location.Code);
        ItemJnlPost.RunWithCheck(ItemJournalLine);
    end;

    [Normal]
    procedure CreateAssemblyOrder(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; LocationCode: Code[10]; Item: Record Item; Quantity: Integer)
    begin
        Clear(AssemblyHeader);
        AssemblyHeader."Document Type" := "Assembly Document Type"::Order;
        AssemblyHeader.Insert(true);
        AssemblyHeader.Validate("Item No.", Item."No.");
        AssemblyHeader.Validate("Location Code", LocationCode);
        AssemblyHeader.Validate("Due Date", DueDate);
        AssemblyHeader.Validate(Quantity, Quantity);
        AssemblyHeader.Modify(true);
    end;

    [Normal]
    procedure PostAssemblyOrder(AssemblyHeader: Record "Assembly Header")
    var
        AssemblyPost: Codeunit "Assembly-Post";
    begin
        AssemblyPost.Run(AssemblyHeader);
        Commit();
    end;

    var
        ScoreKeeper: Codeunit "ScoreKeeper Hgd";
        SetupInit: Boolean;
}