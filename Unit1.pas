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
if 13=key then //13 �ǻس�
begin
 if idtcpclnt.Connected then
  begin
  RequestStr := utf8decode(saymmo.Text);
  RequestStr := StringReplace(RequestStr, #13, '', [rfReplaceAll]);
  RequestStr := StringReplace(RequestStr, #10, '', [rfReplaceAll]);
  try
    idtcpclnt.Write(RequestStr);
    saymmo.Text:='';
    Chatedt.Lines.Add('You��'+RequestStr);
    BackStr:=utf8decode(idtcpclnt.CurrentReadBuffer);  //��ȡ����ֵ
    Chatedt.Lines.Add('Robot��'+BackStr);
    except
       Chatedt.Lines.Add('����ʧ��!');
    end;
  end
  else
  begin
   Chatedt.Lines.Add('�����ѱ��Ͽ����޷����ͣ�');
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
      idtcpclnt.Write(RequestStr); //��������
      saymmo.Text:='';
      Chatedt.Lines.Add('You��'+RequestStr);
      BackStr:=utf8decode(idtcpclnt.CurrentReadBuffer);//��������
      Chatedt.Lines.Add('Robot��'+BackStr);
    except
       Chatedt.Lines.Add('����ʧ��!');
    end;
  end
  else
  begin
   Chatedt.Lines.Add('�����ѱ��Ͽ����޷����ͣ�');
  end;


end;

procedure TForm1.concentbtnClick(Sender: TObject);
begin
pnl1.Visible:=True;
 idtcpclnt := TIdTCPClient.Create(nil);
 idtcpclnt.Host:= '192.168.0.1';//Ҫ���ӵ��ⲿip
 idtcpclnt.Port:=8888; //�����˿�
if idtcpclnt.Connected then     //���������
begin
try
 idtcpclnt.Disconnect;
 Chatedt.Lines.Add('socket�����ѶϿ���');
 concentbtn.Caption:='����';
 except
 Chatedt.Lines.Add('�Ͽ�����ʱ����!');
end;
end
else
begin
      try
          idtcpclnt.Connect(5000);

          Chatedt.Lines.Add('����ͨ�������Ѿ��ɹ�������');
          saymmo.SetFocus;
          concentbtn.Caption:='������';
          Chatedt.Lines.Add(idtcpclnt.CurrentReadBuffer);
      except
          Chatedt.Lines.Add('����ʧ��,������������!');
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
Chatedt.SelLength := Length(Chatedt.Text);//��Chatedt�ĵ������Զ����¹���
end;

end.
