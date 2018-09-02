unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, jpeg, ExtCtrls, QuickRpt, QRCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection,  IdGlobal,IdTCPClient,
  IdTCPServer;

type
  TForm1 = class(TForm)
    saymmo: TMemo;
    lbl: TLabel;
    concentbtn: TButton;
    sendbtn: TButton;
    img1: TImage;
    mmo1: TMemo;
    pnl1: TPanel;
    Chatedt: TRichEdit;
    lbl1: TLabel;
    idtcpclnt: TIdTCPClient;
    tmr1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure saymmoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sendbtnClick(Sender: TObject);
    procedure concentbtnClick(Sender: TObject);
    procedure lbl1Click(Sender: TObject);
    procedure idtcpclntConnected(Sender: TObject);
    procedure idtcpclntDisconnected(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmr1Timer(Sender: TObject);
    procedure ChatedtChange(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
 td:Dword;
 doRead:boolean;
implementation

{$R *.dfm}


procedure TForm1.FormShow(Sender: TObject);
begin
saymmo.SetFocus;
end;



procedure TForm1.saymmoKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
var
  RequestStr,BackStr:string;
begin
if 13=key then //13 是回车
begin
 if idtcpclnt.Connected then
  begin
  RequestStr := utf8decode(saymmo.Text);
  RequestStr := StringReplace(RequestStr, #13, '', [rfReplaceAll]);
  RequestStr := StringReplace(RequestStr, #10, '', [rfReplaceAll]);
  try
    idtcpclnt.Write(RequestStr);
    saymmo.Text:='';
    Chatedt.Lines.Add('You：'+RequestStr);
    BackStr:=utf8decode(idtcpclnt.CurrentReadBuffer);  //获取返回值
    Chatedt.Lines.Add('Robot：'+BackStr);
    except
       Chatedt.Lines.Add('发送失败!');
    end;
  end
  else
  begin
   Chatedt.Lines.Add('连接已被断开，无法发送！');
  end;
end;
end;

procedure TForm1.sendbtnClick(Sender: TObject);
var
  RequestStr,BackStr:string;
begin
  if idtcpclnt.Connected then
  begin
    RequestStr := utf8decode(saymmo.Text);
    RequestStr := StringReplace(RequestStr, #13, '', [rfReplaceAll]);
    RequestStr := StringReplace(RequestStr, #10, '', [rfReplaceAll]);
    try
      idtcpclnt.Write(RequestStr); //发送请求
      saymmo.Text:='';
      Chatedt.Lines.Add('You：'+RequestStr);
      BackStr:=utf8decode(idtcpclnt.CurrentReadBuffer);//接收请求
      Chatedt.Lines.Add('Robot：'+BackStr);
    except
       Chatedt.Lines.Add('发送失败!');
    end;
  end
  else
  begin
   Chatedt.Lines.Add('连接已被断开，无法发送！');
  end;


end;

procedure TForm1.concentbtnClick(Sender: TObject);
begin
pnl1.Visible:=True;
 idtcpclnt := TIdTCPClient.Create(nil);
 idtcpclnt.Host:= '192.168.0.1';//要连接的外部ip
 idtcpclnt.Port:=8888; //主机端口
if idtcpclnt.Connected then     //如果已连接
begin
try
 idtcpclnt.Disconnect;
 Chatedt.Lines.Add('socket连接已断开！');
 concentbtn.Caption:='连接';
 except
 Chatedt.Lines.Add('断开连接时出错!');
end;
end
else
begin
      try
          idtcpclnt.Connect(5000);

          Chatedt.Lines.Add('控制通道接入已经成功建立！');
          saymmo.SetFocus;
          concentbtn.Caption:='已连接';
          Chatedt.Lines.Add(idtcpclnt.CurrentReadBuffer);
      except
          Chatedt.Lines.Add('接入失败,请检查连接设置!');
         end;


end;
  end;

 
procedure TForm1.lbl1Click(Sender: TObject);
begin
if pnl1.Visible=True then
begin
   pnl1.Visible:=False;
     end
 else
 begin
 pnl1.Visible:=True;
 end;      
  end;



procedure TForm1.idtcpclntConnected(Sender: TObject);
begin
 Chatedt.Lines.Clear;
 Chatedt.Lines.Add('connected to server');
end;

procedure TForm1.idtcpclntDisconnected(Sender: TObject);
begin
ExitThread(td);
Chatedt.Lines.Add('disConnected from server');
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin

idtcpclnt.Disconnect;

end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
temp:string;
begin
idtcpclnt.readfromstack(false,1,false);
while idtcpclnt.InputBuffer.Size> 0   do
begin
temp:=idtcpclnt.ReadLn;
end

end;


procedure TForm1.ChatedtChange(Sender: TObject);
begin
Chatedt.SelLength := Length(Chatedt.Text);//让Chatedt的的内容自动往下滚动
end;

end.
