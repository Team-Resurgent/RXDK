#include "Uninstall.iss"

#define VSIXInstallerPath 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\VSIXInstaller.exe'

[Setup]
ChangesEnvironment=true
AppId=RXDK
AppName=RXDK
AppVersion=1.3
WizardStyle=classic
DefaultDirName={autopf}\RXDK
DefaultGroupName=RXDK
Compression=lzma2
SolidCompression=yes
OutputBaseFilename=RXDK-Setup
SetupIconFile=Icon.ico
MissingRunOnceIdsWarning=no
WizardSmallImageFile=WizardSmallImage.bmp
WizardImageFile=WizardImage.bmp

[Code]
var
  XDKPage: TInputFileWizardPage;
  XDKSetupLocation: String;
  XDKPageID: Integer;
  XDKCopyPage: TOutputMarqueeProgressWizardPage;
  XDKCopyPageID: Integer;
  ResultCode: Integer;

procedure InitializeWizard;
begin
  XDKPage := CreateInputFilePage(wpWelcome, 'Select XDK Setup Location', 'Where is XDK Setup located?', 'Select where XDK Setup is located, then click Next.');
  XDKPage.Add('&Location of XDKSetup.exe:', 'Executable files|*.exe', '.exe');
  XDKPageID := XDKPage.ID;
  XDKCopyPage := CreateOutputMarqueeProgressPage('Processing XDK Setup', 'Please wait processing...');
  XDKCopyPageID := XDKCopyPage.ID;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var XDKTemp: String;
begin
  if CurPageID = XDKPageID then
  begin
    XDKSetupLocation := XDKPage.Values[0];
    if not FileExists(XDKSetupLocation) then
    begin
      MsgBox('You must select XDK Setup file.', mbError, MB_OK);
      Result:= FALSE;
    end 
    else
    begin
      XDKCopyPage.Show;
      XDKCopyPage.Animate;
      ExtractTemporaryFile('7za.exe');
      XDKTemp := ExpandConstant('{tmp}\XDKTemp');
      if Exec(ExpandConstant('{tmp}\7za.exe'), 'x ""' + XDKSetupLocation + '"" -aoa -o""' + XDKTemp + '""', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      begin 
        if DirExists(XDKTemp) then
        begin
          XDKCopyPage.Hide;
          Result:= TRUE;
        end
        else
        begin
          MsgBox('Invalid XDK Setup file.', mbError, MB_OK);
          XDKCopyPage.Hide;
          Result:= FALSE;
        end;
      end
      else
      begin
        Result:= FALSE;
      end;
    end;
  end
  else 
  begin
    Result:= TRUE;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade('RXDK')) then
    begin
      UnInstallOldVersion('RXDK');
    end;
    RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'RXDK_LIBS', ExpandConstant('{app}') + '\xbox\');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep=usUninstall) then
  begin
    RegDeleteValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'RXDK_LIBS');
  end;
end;

function InstallerExists(): Boolean;
begin
  Result := FileExists('{#VSIXInstallerPath}');
end;

[Files]
Source: "{tmp}\XDKTemp\XDK\xbox\bin\*"; DestDir: "{app}\xbox\bin\"; Flags: external recursesubdirs
Source: "{tmp}\XDKTemp\XDK\xbox\lib\*"; DestDir: "{app}\xbox\lib\"; Flags: external recursesubdirs
Source: "{tmp}\XDKTemp\XDK\xbox\include\*"; DestDir: "{app}\xbox\include\"; Flags: external recursesubdirs
Source: "{tmp}\XDKTemp\XDK\xbox\symbols\*"; DestDir: "{app}\xbox\symbols\"; Flags: external recursesubdirs
Source: "{tmp}\XDKTemp\XDK\doc\XboxSDK.*"; DestDir: "{app}\doc\"; Flags: external

Source: "Files\7za.exe"; Flags: dontcopy
Source: "Files\extensions\*"; DestDir: "{app}\extensions\"; Flags: recursesubdirs
Source: "Files\xbox\*"; DestDir: "{app}\xbox\"; Flags: recursesubdirs

[Icons]
Name: "{group}\RXDK\Xbox SDK Documentation"; Filename: "{app}\doc\XboxSDK.chm"
Name: "{group}\RXDK\Set Xbox IP"; Filename: "{app}\xbox\bin\xbsetip.exe"
Name: "{group}\RXDK\Xbox Neighborhood"; Filename: "{app}\xbox\bin\RXDKNeighborhood\RXDKNeighborhood.exe"
Name: "{group}\RXDK\Audio\DSP Builder Tool"; Filename: "{app}\xbox\bin\DSPBuilder.exe"
Name: "{group}\RXDK\Audio\Xbox Audio Creation Tool"; Filename: "{app}\xbox\bin\XACT.exe"
Name: "{group}\RXDK\Debugging\Api Monitor"; Filename: "{app}\xbox\bin\xam.exe"
Name: "{group}\RXDK\Debugging\Api Monitor SE"; Filename: "{app}\xbox\bin\xamse.exe"
Name: "{group}\RXDK\Debugging\Xbox Watson"; Filename: "{app}\xbox\bin\xbwatson.exe"
Name: "{group}\RXDK\Graphics\Pixel Shader Debugger"; Filename: "{app}\xbox\bin\xbpscapture.exe"
Name: "{group}\RXDK\Graphics\Vertex Shader Debugger"; Filename: "{app}\xbox\bin\xbvscapture.exe"
Name: "{group}\RXDK\Graphics\Xray Debug Tool"; Filename: "{app}\xbox\bin\xbxray.exe"

[Run]
Filename: "{#VSIXInstallerPath}"; Parameters: """{app}\extensions\RXDK.Samples.vsix"""; Flags: waituntilterminated; Check: InstallerExists()

[UninstallRun]
Filename: "{#VSIXInstallerPath}"; Parameters: "/uninstall:RXDK.Samples"; Flags: waituntilterminated;
