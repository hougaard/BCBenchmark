page 89320 "BC Benchmark"
{
    PageType = NavigatePage;
    SourceTable = "Score Hgd";
    Editable = false;
    UsageCategory = Tasks;
    ApplicationArea = all;
    //SourceTableView = sorting(Score);
    layout
    {
        area(Content)
        {
            usercontrol(Logo; HTMLHelper)
            {
                ApplicationArea = All;
                trigger ControlReady()
                begin
                    CurrPage.Logo.GetBaseUrlForResources('src/UI/Logo.png');
                    CurrPage.Logo.StartTimer();
                end;

                trigger ReturnBaseURL(URL: Text)
                begin
                    LogoURL := URL;
                    RenderPage();
                end;

                trigger TimerTic()
                begin
                    RenderPage();
                end;
            }
            repeater(rep)
            {
                field(RunTime; CodeunitCaption(Rec.CodeUnitNo))
                {
                    Caption = 'Task';
                    ApplicationArea = all;
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DebugRun)
            {
                Caption = 'Debug Benchmark';
                ApplicationArea = all;
                ToolTip = 'Debug a benchmark run';
                InFooterBar = true;
                trigger OnAction()
                var
                    Window: Dialog;
                    SessionId: Integer;
                begin
                    Codeunit.Run(CODEUNIT::"Benchmark Runner Hgd");
                    //Session.StartSession(SessionId, CODEUNIT::"Benchmark Runner Hgd", CompanyName, Parameters);
                end
                ;
            }
            action(Run)
            {
                Caption = 'Run Benchmark';
                ApplicationArea = all;
                ToolTip = 'Run a benchmark';
                InFooterBar = true;
                trigger OnAction()
                var
                    Window: Dialog;
                    SessionId: Integer;
                begin
                    Session.StartSession(SessionId, CODEUNIT::"Benchmark Runner Hgd");
                end
                ;
            }
        }
    }
    trigger OnOpenPage()
    var
        Score: Record "Score Hgd";
    begin
        Score.DeleteAll();
    end;

    procedure RenderPage()
    var
        Status: Text;
        Score: JsonObject;
        Tests: JsonToken;
        Test: JsonToken;
        CU: JsonToken;
        CUScore: JsonToken;
        Total: JsonToken;
        K: Text;
    begin
        Score := GetScore();
        //message(format(score));
        if Score.Contains('Finished') then begin
            Score.Get('Total', Total);
            Score.Get('Tests', Tests);
            Rec.DeleteAll();
            foreach K in Tests.AsObject().Keys() do begin
                if Tests.AsObject().Get(K, Test) then begin
                    Test.AsObject().Get('Codeunit', CU);
                    Test.AsObject().Get('Score', CUScore);
                    Rec.Init();
                    Rec.CodeUnitNo := CU.AsValue().AsInteger();
                    Rec.Score := CUScore.AsValue().AsInteger();
                    Rec.Insert();
                end;
            end;
            Status := '<h2 style="font-family: "Segoe UI Semibold", "Segoe WP Semibold", device-segoe-semibold, "Segoe UI", "Segoe WP", Segoe, Tahoma, Helvetica, Arial, sans-serif !important;font-weight: normal !important;font-style: normal !important;text-transform: none !important;">Score ' + format(Total.AsValue().AsInteger()) + '</h2>'
        end else begin
            Status := '<h2 style="font-family: "Segoe UI Semibold", "Segoe WP Semibold", device-segoe-semibold, "Segoe UI", "Segoe WP", Segoe, Tahoma, Helvetica, Arial, sans-serif !important;font-weight: normal !important;font-style: normal !important;text-transform: none !important;">Benchmark is running ...</h2>';
            Rec.DeleteAll();
        end;

        CurrPage.Logo.Render(
        '<div>' +
        '<img style="display: block;margin-left: 0px;margin-right: auto; width: 100%;" src="' + LogoURL + '">' +
        Status +
        '</div>');

    end;

    procedure Codeunitcaption(No: Integer): Text
    var
        Obj: Record AllObjWithCaption;
    begin
        if obj.get(Obj."Object Type"::Codeunit, No) then
            exit(Obj."Object Caption".Replace(' Hgd', ''));
    end;


    procedure GetScore(): JsonObject
    var
        txt: Text;
        Score: JsonObject;
    begin
        if IsolatedStorage.Get('SCORE', txt) then
            if Score.ReadFrom(txt) then
                exit(Score);
        exit(Score); // Empty Json
    end;

    var
        LogoURL: Text;
}