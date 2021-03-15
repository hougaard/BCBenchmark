//

function Render(html)
{
  while (HTMLContainer.lastElementChild) {
    HTMLContainer.removeChild(HTMLContainer.lastElementChild);
  }
    HTMLContainer.insertAdjacentHTML('beforeend',html);
}

function GetBaseUrlForResources(Resource)
{
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ReturnBaseURL",
    [
        Microsoft.Dynamics.NAV.GetImageResource(Resource)
    ]);

}

var LoginWindow;

function LaunchURLinNewWindow(URL)
{
    LoginWindow = window.open(URL,'_blank',"toolbar=0,location=0,menubar=0,width=500,height=700");
}

function CloseWindow()
{
    LoginWindow.close();
}
function CloseCurrentWindow()
{
    window.close();
}

function StartTimer()
{
    window.setInterval(TimerTic,1000);
}
function TimerTic()
{
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("TimerTic",[]);
}