[Setup]
AppName=Xlog-Decoder
AppVersion=1
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
DefaultDirName={autopf}\Xlog-Decoder\
DefaultGroupName=Xlog-Decoder
SetupIconFile=app_icon.icon
UninstallDisplayIcon={app}\Xlog-Decoder.exe
UninstallDisplayName=Xlog-Decoder
AppPublisher=Xlog-Decoder-IO
VersionInfoVersion=1

[Files]
Source: "Xlog-Decoder\Xlog-Decoder.exe";DestDir: "{app}";DestName: "Xlog-Decoder.exe"
Source: "Xlog-Decoder\*";DestDir: "{app}"
Source: "Xlog-Decoder\data\*";DestDir: "{app}\data\"; Flags: recursesubdirs

[Icons]
Name: "{group}\Xlog-Decoder";Filename: "{app}\Xlog-Decoder.exe"