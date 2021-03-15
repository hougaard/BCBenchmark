controladdin HTMLHelper
{
    VerticalStretch = true;
    HorizontalStretch = true;
    Images = 'src/UI/Logo.png';
    RequestedHeight = 155;
    StartupScript = 'src/UI/Startup.js';
    Scripts = 'src/UI/Script.js';
    event RedirectReceived(Code: Text; State: Text);
    event ControlReady();
    event TimerTic();
    procedure LaunchURLinNewWindow(URL: Text);
    procedure StartTimer();
    procedure CloseCurrentWindow();
    procedure CloseWindow();


    procedure Render(HTML: Text);
    event JavaScriptEvent();
    procedure GetBaseUrlForResources(Resource: Text);
    event ReturnBaseURL(URL: Text);
}