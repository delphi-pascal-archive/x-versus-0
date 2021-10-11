unit UCMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, StdCtrls, Grids, ImgList;

type
  TResult = (grGame, grXWin, gr0Win, grDrawn);
  TField = (fdEmpty, fdX, fd0);
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    ClientSocket1: TClientSocket;
    ServerSocket1: TServerSocket;
    ImageList1: TImageList;
    DrawGrid1: TDrawGrid;
    lblResults: TLabel;
    Button2: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SetResults;
    procedure Button2Click(Sender: TObject);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  allow: Boolean;
  Pole : array [0..2, 0..2] of TField;
  conn : Boolean;
implementation

{$R *.dfm}

function AnalyzeGame : TResult;
begin
  result := grGame;
  if ((Pole[0,0]=fdX) and (Pole[0,1]=fdX) and (Pole[0,2]=fdX)) or
     ((Pole[1,0]=fdX) and (Pole[1,1]=fdX) and (Pole[1,2]=fdX)) or
     ((Pole[2,0]=fdX) and (Pole[2,1]=fdX) and (Pole[2,2]=fdX)) or
     ((Pole[0,0]=fdX) and (Pole[1,0]=fdX) and (Pole[2,0]=fdX)) or
     ((Pole[0,1]=fdX) and (Pole[1,1]=fdX) and (Pole[2,1]=fdX)) or
     ((Pole[0,2]=fdX) and (Pole[1,2]=fdX) and (Pole[2,2]=fdX)) or
     ((Pole[0,0]=fdX) and (Pole[1,1]=fdX) and (Pole[2,2]=fdX)) or
     ((Pole[2,0]=fdX) and (Pole[1,1]=fdX) and (Pole[0,2]=fdX)) then begin
      result := grXWin;
      exit;
     end;

  if ((Pole[0,0]=fd0) and (Pole[0,1]=fd0) and (Pole[0,2]=fd0)) or
     ((Pole[1,0]=fd0) and (Pole[1,1]=fd0) and (Pole[1,2]=fd0)) or
     ((Pole[2,0]=fd0) and (Pole[2,1]=fd0) and (Pole[2,2]=fd0)) or
     ((Pole[0,0]=fd0) and (Pole[1,0]=fd0) and (Pole[2,0]=fd0)) or
     ((Pole[0,1]=fd0) and (Pole[1,1]=fd0) and (Pole[2,1]=fd0)) or
     ((Pole[0,2]=fd0) and (Pole[1,2]=fd0) and (Pole[2,2]=fd0)) or
     ((Pole[0,0]=fd0) and (Pole[1,1]=fd0) and (Pole[2,2]=fd0)) or
     ((Pole[2,0]=fd0) and (Pole[1,1]=fd0) and (Pole[0,2]=fd0)) then begin
      result := gr0Win;
      exit;
     end;
  if (Pole[0,0] <> fdEmpty) and (Pole[0,1] <> fdEmpty) and (Pole[0,1] <> fdEmpty) and
     (Pole[1,0] <> fdEmpty) and (Pole[1,1] <> fdEmpty) and (Pole[1,2] <> fdEmpty) and
     (Pole[2,0] <> fdEmpty) and (Pole[2,1] <> fdEmpty) and (Pole[2,2] <> fdEmpty) then
      result := grDrawn;
end;

procedure TForm1.SetResults;
var r : TResult;
begin
  r := AnalyzeGame;
  case r of
    grGame : lblResults.Caption := 'Идет игра';
    grXWin : lblResults.Caption := 'Х выиграл!';
    gr0Win : lblResults.Caption := '0 выиграл!';
    grDrawn: lblResults.Caption := 'Ничья!';
  end;
  case r of
    grGame : lblResults.Font.Color := clNavy;
    grXWin : lblResults.Font.Color := clRed;
    gr0Win : lblResults.Font.Color := clBlue;
    grDrawn: lblResults.Font.Color := clFuchsia;
  end;
  if r <> grGame then Allow := false;
end;

function GetPart(Delimetr : Char; Number : Integer; Str : String) : String;
var str1, str2 : String;
    index, oldindex, index2, i : Integer;
begin
  str := str + delimetr;
  index := Length(str);
  oldindex := 0;
  for i := 1 to number do begin
    str1 := Copy(str, index + 1 + oldindex , Length(str) - (index + 1));
    index := Pos(Delimetr, str1);
    oldindex := oldindex + index;
  end;

  index := oldindex;

    str2 :=  Copy(str, index+1, length(str) - index + 1);
    index2 := Pos(Delimetr, str2);

  result := Copy(str, index + 1, index2 - 1);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ClientSocket1.Host := Edit1.Text;
  ClientSocket1.Active := true;
  ServerSocket1.Active := true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ClientSocket1.Active := false;
end;

procedure TForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var s   : String;
    x,y : Integer;
begin
  s := Socket.ReceiveText;
  if s = 'newgame' then begin
    for x := 0 to 2 do
      for y := 0 to 2 do begin
        Pole[x,y] := fdEmpty;
        DrawGrid1DrawCell(self, x,y,DrawGrid1.CellRect(x,y), []);
      end;
    allow := true;
  end else begin

    x := StrToInt(GetPart('x', 1, s));
    y := StrToInt(GetPart('x', 2, s));
    Pole[x,y] := fdX;
    DrawGrid1DrawCell(self, x, y, DrawGrid1.CellRect(x,y), []);
    allow := true;
    SetResults;
  end;
end;

procedure TForm1.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  DrawGrid1.Canvas.Brush.Color := clWhite;
  DrawGrid1.Canvas.FillRect(Rect);
  ImageList1.Draw(DrawGrid1.Canvas, Rect.Left, Rect.Top, Ord(Pole[ACol, ARow]) - 1);
end;

procedure TForm1.DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (not allow) or (not conn) or (Pole[ACol, ARow] <> fdEmpty) then exit;
  Pole[ACol, ARow] := fd0;
  ClientSocket1.Socket.SendText(IntToStr(ACol) + 'x' + IntToStr(ARow));
  allow := false;
  SetResults;
end;

procedure TForm1.Button2Click(Sender: TObject);
var x,y : Integer;
begin
  if not conn then exit;
  for x := 0 to 2 do
    for y := 0 to 2 do begin
      Pole[x,y] := fdEmpty;
      allow := true;
      DrawGrid1DrawCell(self, x, y, DrawGrid1.CellRect(x, y), []);
    end;
  ClientSocket1.Socket.SendText('newgame');
end;

procedure TForm1.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Label1.Caption := 'Соединен';
  Label1.Font.Color := clGreen;
  conn := true;
end;

procedure TForm1.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Label1.Caption := 'Отсоединен';
  Label1.Font.Color := clRed;
  conn := false;
end;

end.
