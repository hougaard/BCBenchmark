var urlParams = new URLSearchParams(window.location.search);
if (urlParams.has('code'))
{
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
        'RedirectReceived',
        [urlParams.get('code'),
         urlParams.get('state'),
        ]);    
} else
{
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
        'RedirectReceived',
        ['',
         '',
        ]);
}


HTMLContainer = document.getElementById("controlAddIn");
    
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady",[]);

