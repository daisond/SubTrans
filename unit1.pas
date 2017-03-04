unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLtype;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word);
    procedure fillstrgrd1();
    procedure fillstrgrd2();
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  filorig: TextFile;
  filtran: TextFile;// text files for orig. & translated subs
  orig: Array[0..8000] of String;
  tran: Array[0..8000] of String;//arrays of orig. & translated strings
  numer, linen:integer; //number of lines, line selected
  wat, pat:String;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.fillstrgrd1();//procedure for original subs
var                            //filled in listbox 1
  i: integer;                  // and listbox 2 for translating
  begin
    ListBox1.Clear;
    ListBox2.Clear;
    i:=0;
    repeat
    ListBox1.Items.Add(orig[i]);
    ListBox2.Items.Add(orig[i]);
    i:=i+1;
    until i=numer;
    Edit1.Text:='End of Original';
  end;
procedure TForm1.fillstrgrd2();//procedure for translated subs
var                            //filled in listbox 2
  i: integer;
  begin
    ListBox2.Clear;
    i:=0;
    repeat
    ListBox2.Items.Add(tran[i]);
    i:=i+1;
    until i=numer;
    Edit1.Text:='End of Translation';
  end;

procedure TForm1.ListBox1Click(Sender: TObject);//if clicked somewhere in listbox 1
var
  i: integer;
begin
  i:=0;
  repeat
   if ListBox1.Selected[i]=true then linen:=i;//find a number of line in listbox 1
   i:=i+1;
  until i=numer;
  ListBox2.ItemIndex:=linen;//select a same line in listbox 2
  Edit1.Text:=ListBox2.Items[linen];//get this line to edit
  Label3.Caption:=IntToStr(linen);
end;

procedure TForm1.ListBox2Click(Sender: TObject);//if clicked in listbox 2
var
  i: integer;
begin
  i:=0;
  repeat
   if ListBox2.Selected[i]=true then linen:=i;//find a number of line in listbox 2
   i:=i+1;
  until i=numer;
  ListBox1.ItemIndex:=linen;//select a same line in listbox 1
  Edit1.Text:=ListBox2.Items[linen];//get this line to edit
  Label3.Caption:=IntToStr(linen);
end;

procedure TForm1.Button3Click(Sender: TObject);//EXIT button clicked
var
  kat, at: String;
  leng, i, reply, boxstyle:integer;
begin
  boxstyle:=MB_ICONQUESTION + MB_YESNO;//first ask the question about saving transl.
  reply:=Application.MessageBox('Save translated subs?','Exit saving',boxstyle);
  if reply= IDYES then
   begin
    kat:=Label1.Caption;//get a path & filename where original subs are taken
    leng:=Length(kat);//get a length of this string
    at:=Copy(kat,1,(leng-4)); //cut 4 places of the length
    kat:= Concat(at,'_tr.srt');//merge to cutted path & filename string _tr.srt
    i:=0;
    AssignFile(filtran,kat);
    Rewrite(filtran);
     repeat  //saving content of listbox 2 - the translation
      System.WriteLn(filtran,ListBox2.Items[i]);
      i:=i+1;
     until i=numer;
    System.Close(filtran);//close saved translation file
   end;
  Close;//close application
end;

procedure TForm1.Button4Click(Sender: TObject);//OPEN translated sub file
var                                            // could be previous one
 i: integer;
begin
  wat:='';
  OpenDialog2.Filter := 'Srt files|*.srt;*.SRT';
  OpenDialog2.Execute; //dialog to find translated sub file
  if Opendialog2.Execute
   then
    begin wat:=OpenDialog2.FileName;//save path to file in variable wat
    Label2.Caption:=wat;// show it to user
    Assignfile(filtran, wat);
    Reset(filtran);
    i:=0; // reset counter to 0
   repeat
     ReadLn(filtran, tran[i]);
     i:=i+1;
   until EOF(filtran);
   CloseFile(filtran);
  numer:=i;//save line counter number for other procedures
  Label3.Caption:=IntToStr(numer);
  fillstrgrd2();
    end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ShowMessage('This application is made mostly just for translating'+ sLineBreak+
  'subtitles not for editing timing, however it is possible'+sLineBreak+
  'unless you know, what you are doing.'
  +sLineBreak+'Open your subtitles and start to translate, then save.'+sLineBreak+
  'You can also open your previously translated file.'+sLineBreak+
  'Text encoding is default for operating system'+sLineBreak+
  'you use - ANSI in windows, UTF-8 - in Linux'+sLineBreak+
  'Try to avoid editing timing and numbers of subtitles.' +sLineBreak+
  'Click on subtitle line, you want to translate, it appears in'+sLineBreak+
  'the editing string, translate it, hit "enter" - done!'+sLineBreak+
  'You can navigate inside any sub. pan with arrow keys "up"&"down"'+sLineBreak+
  'It saves translated subs in the same place as original,'+sLineBreak+
  'with *_tr.srt at the end of file name. '+sLineBreak+'Author - dais');
end;

procedure TForm1.Edit1KeyUp(Sender: TObject;//you editing line, hit enter and navigate in subs.
  var Key: Word);
begin
  if Key=VK_UP then   //if you hit up arrow
  begin
   linen:=linen-1;//line number decreases
   ListBox2.Selected[linen]:=true;//select new line in listbox 2
   ListBox1.Selected[linen]:=true;//select new line in listbox 1 also
   Edit1.Text:=ListBox2.Items.Strings[linen];  //show line in edit string
   Label3.Caption:=IntToStr(linen);
  end;
  if Key=VK_DOWN then //if you hit down arrow
  begin
   linen:=linen+1;//line number increases
   ListBox2.Selected[linen]:=true; //you know...
   ListBox1.Selected[linen]:=true;
   Edit1.Text:=ListBox2.Items.Strings[linen];  //show line in edit string
   Label3.Caption:=IntToStr(linen);
  end;
  if Key=VK_RETURN then //hit enter key
  begin
  ListBox2.Items.Strings[linen]:=Edit1.Text;//get edited line in translated sub listbox 2
  linen:=linen+1;    //get next line number
  Edit1.Text:='';//clear an editing line
  ListBox2.Selected[linen]:=true;//go to next line in listbox 2
  ListBox1.selected[linen]:=true;//go to next line in listbox 1
  Edit1.Text:=ListBox2.Items.Strings[linen];  //show line in edit string
  Label3.Caption:=IntToStr(linen);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);//OPEN original sub file
 var
 i: integer;
begin
  pat:='';
  OpenDialog1.Filter := 'Srt files|*.srt;*.SRT';
  OpenDialog1.Execute; //dialog to find an original sub file
  pat:=OpenDialog1.FileName;//save path to file in variable pat
  Label1.Caption:=pat;// show it to user
  Assignfile(filorig, pat);
  Reset(filorig);
  i:=0; // reset counter to 0
  repeat
    ReadLn(filorig, orig[i]);
    i:=i+1;
  until EOF(filorig);
  numer:=i;//save line counter number for other procedures
  CloseFile(filorig);
  Label3.Caption:=IntToStr(numer);
  fillstrgrd1();

end;

procedure TForm1.Button2Click(Sender: TObject);//SAVE translated sub file
 var
 pat, at: String;
 leng, i:integer;
begin
 pat:=Label1.Caption;//get a path & filename where original subs are taken
 leng:=Length(pat);//get a length of this string
 at:=Copy(pat,1,(leng-4)); //cut 4 places of the length
 pat:= Concat(at,'_tr.srt');//merge to cutted path & filename string _tr.srt
 i:=0;
 AssignFile(filtran,pat);
 Rewrite(filtran);
 repeat
  System.WriteLn(filtran,ListBox2.Items[i]);
  i:=i+1;
 until i=numer;//saving content of listbox 2 - the translation
 System.Close(filtran);
end;

end.
