program Map_Unc;

uses
  Vcl.Forms,
  uError,
  System.SysUtils,
  System.Classes,
  Vcl.Dialogs,
  opWString,
  uMap_Unc in 'uMap_Unc.pas' {Form3};

{$R *.res}
var
  SList, hlp, FieldNames: TStringList;
  i, j, len: Integer;
  ObsName, Line, Entry: String;

const
  WordDelims: CharSet = [','];
  WordDelimsSpace: CharSet = [' '];

Procedure ShowArgumentsAndTerminate;
begin
  ShowMessage( 'Map_Unc input_csv_file output_csv_file' );
  // for example %DelphiDebug%\Map_Unc map_unc_in.csv map_unc_out.csv
  Application.Terminate;
end;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
//  Application.CreateForm(TForm3, Form3);

  if not (ParamCount() = 2)   then
     ShowArgumentsAndTerminate;

// Read input csv file with (PEST) observation name, x- en y- coordinate
  SList := TStringList.Create();
  SList.LoadFromFile(ParamStr(1));

// Read output field names from first observation unc-result file (.rs file).
// Example of such a file:
// precal_tunc_sd          0.4430815000000000
// postcal_tunc_sd         4.2152935000000000E-02
// cpusd_cd1               4.8333425287268850E-03
// cpusd_cl1               7.8451449954733150E-03
// cpusd_tx3                0.000000000000000
// cpusd_k                 3.1425626008084550E-02
// ipusd_heads             0.4410717628685836
// ipusd_flx                0.000000000000000
// ipusd_dmh                0.000000000000000
  ObsName := Trim( ExtractWord(1, SList[1], WordDelims, Len ));
  Hlp := TStringList.Create;
  Hlp.LoadFromFile( ObsName+'.rs');
  FieldNames := TStringList.Create;
  for i := 0 to Hlp.Count-1 do
    FieldNames.Add( ExtractWord(1, Hlp[i], WordDelimsSpace, Len ) );
  Hlp.Clear;

// Append output field names to the first line of SList
  for i := 0 to FieldNames.Count-1 do
    SList[0] := SList[0] + ',' + FieldNames[i];

// Add " quotes (for ArcView) in the first line (titles)
  SList[0] := '"' + stringreplace( SList[0], ',', '","', [rfReplaceAll]) + '"';

// Add " quotes to the observation names and
// ppend the values in *.rs files to the corresponding observation names
  for i := 1 to SList.Count - 1 do begin
    ObsName := Trim( ExtractWord(1, SList[i], WordDelims, Len ));
    Hlp.LoadFromFile( ObsName+'.rs');
    SList[i] := '"' + stringreplace( SList[i], ',', '",', [] );
    for j := 0 to FieldNames.Count-1 do
       SList[i] := SList[i] + ',' + ExtractWord(2, Hlp[j], WordDelimsSpace, Len );
    Hlp.Clear;
  end;
  SList.SaveToFile(ParamStr(2));

  FieldNames.Free;
  SList.Free;
  Hlp.Free;
  //Application.Run;
end.
