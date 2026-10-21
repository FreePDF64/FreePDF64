unit uFreePDF64PDFiumCore;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Math,
  System.Generics.Collections, Vcl.Graphics;

type
  EPDFiumViewer = class(Exception);
  EPDFiumPasswordRequired = class(EPDFiumViewer);
  TPDFInkPoint = packed record
    X, Y: Single;
  end;
  TPDFInkRect = packed record
    Left, Bottom, Right, Top: Single;
  end;
  TPDFTextMatch = record
    PageIndex: Integer;
    CharIndex: Integer;
    CharCount: Integer;
  end;
  TPDFLinkTarget = record
    URI: string;
    PageIndex: Integer; // -1 bei externem Link
  end;
  TPDFInkStroke = class(TList<TPDFInkPoint>)
  public
    LineWidth: Single; // Strichstaerke in PDF-Punkten
    StrokeColor: TColor; // individuelle Farbe der Markierung
  end;
  TPDFBookmarkItem = class
  public
    Title: string;
    PageIndex: Integer;
    Children: TObjectList<TPDFBookmarkItem>;
    constructor Create;
    destructor Destroy; override;
  end;
  TFreePDF64PDFiumCore = class
  private
    FDocument: Pointer;
    FSearchTerm: string;
    FSearchCache: TArray<TPDFTextMatch>;
    FSearchCacheValid: Boolean;
    FFileName: string;
    FPageCount: Integer;
    FStrokes: TObjectList<TPDFInkStroke>;
    FStrokePages: TList<Integer>;
    FModified: Boolean;
    FUndoFile: string;
    FUndoWasModified: Boolean;
    FHasUndo: Boolean;
    FUndoSource: string;
    procedure InvalidateSearchCache;
  public
    constructor Create;
    destructor Destroy; override;
    procedure OpenFile(const AFileName: string; const APassword: AnsiString = '');
    procedure CloseFile;
    procedure RenderPage(APageIndex: Integer; ABitmap: TBitmap;
      AWidth, AHeight: Integer; ARotation: Integer = 0);
    procedure AddStroke(APageIndex: Integer; APoints: TPDFInkStroke);
    procedure SaveAs(const AFileName: string);
    procedure DeletePages(const APageIndices: TArray<Integer>);
    procedure BeginUndo;
    procedure UndoLast;
    procedure ClearUndo;
    procedure RotateInMemory(AFirstPage, ALastPage, AAngle: Integer);
    property CanUndo: Boolean read FHasUndo;
    procedure RotatePages(AFirstPage, ALastPage, AAngle: Integer; const ATargetFile: string);
    function PagePointToDevice(APageIndex, AWidth, AHeight: Integer;
      AX, AY: Double; out X, Y: Integer): Boolean;
    function DevicePointToPage(APageIndex, AWidth, AHeight, X, Y: Integer;
      out AX, AY: Double): Boolean;
    property Modified: Boolean read FModified;
    property Strokes: TObjectList<TPDFInkStroke> read FStrokes;
    property StrokePages: TList<Integer> read FStrokePages;
    function LinkAtPoint(APageIndex, AWidth, AHeight, X, Y: Integer;
      out ATarget: TPDFLinkTarget): Boolean;
    function PageSize(APageIndex: Integer; out AWidth, AHeight: Single): Boolean;
    function FindTextPage(const AText: string; AStartPage: Integer): Integer;
    function FindAllTextMatches(const AText: string): TArray<TPDFTextMatch>;
    function FindTextMatchesOnPage(const AText: string; APage: Integer): TArray<TPDFTextMatch>;
    function MatchCharRects(APage, ACharIndex, ACharCount: Integer): TArray<TPDFInkRect>;
    function TextCharAt(APage: Integer; AX, AY: Double): Integer;
    function TextCharCount(APage: Integer): Integer;
    function TextRange(APage, AStart, ACount: Integer): string;
    function FindTextMatch(const AText: string; AStartPage, AStartChar,
      ADirection: Integer; out APage, ACharIndex, ACharCount: Integer): Boolean;
    function MetaText(const AKey: AnsiString): string;
    procedure ReadBookmarks(AItems: TObjectList<TPDFBookmarkItem>);
    function PDFVersion: string;
    function SecurityRevision: Integer;
    function SecurityPermissions: UInt64;
    property FileName: string read FFileName;
    property PageCount: Integer read FPageCount;
  end;

implementation

type
  PPDFFileWrite = ^TPDFFileWrite;
  TPDFWriteBlock = function(AWriter: PPDFFileWrite; AData: Pointer;
    ASize: Cardinal): Integer; cdecl;
  TPDFFileWrite = record
    Version: Integer;
    WriteBlock: TPDFWriteBlock;
  end;
  POutputWriter = ^TOutputWriter;
  TOutputWriter = record
    Base: TPDFFileWrite;
    Stream: TFileStream;
  end;

function PDFWriteBlock(AWriter: PPDFFileWrite; AData: Pointer;
  ASize: Cardinal): Integer; cdecl;
begin
  try
    Result := Integer(POutputWriter(AWriter).Stream.Write(AData^, ASize) = Integer(ASize));
  except
    Result := 0;
  end;
end;

function FPDFBookmark_GetFirstChild(Doc, Bookmark: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFBookmark_GetNextSibling(Doc, Bookmark: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFBookmark_GetTitle(Bookmark, Buffer: Pointer; BufLen: Cardinal): Cardinal; stdcall; external 'pdfium.dll';
function FPDFBookmark_GetDest(Doc, Bookmark: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFBookmark_GetAction(Bookmark: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFAction_GetType(Action: Pointer): Cardinal; stdcall; external 'pdfium.dll';
function FPDFLink_GetLinkAtPoint(Page: Pointer; X, Y: Double): Pointer; stdcall; external 'pdfium.dll';
function FPDFLink_LoadWebLinks(TextPage: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFLink_CountWebLinks(LinkPage: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDFLink_GetURL(LinkPage: Pointer; LinkIndex: Integer;
  Buffer: PWideChar; BufLen: Integer): Integer; stdcall; external 'pdfium.dll';
function FPDFLink_CountRects(LinkPage: Pointer; LinkIndex: Integer): Integer; stdcall; external 'pdfium.dll';
function FPDFLink_GetRect(LinkPage: Pointer; LinkIndex, RectIndex: Integer;
  var Left, Top, Right, Bottom: Double): Integer; stdcall; external 'pdfium.dll';
procedure FPDFLink_CloseWebLinks(LinkPage: Pointer); stdcall; external 'pdfium.dll';
function FPDFText_GetUnicode(TextPage: Pointer; Index: Integer): Cardinal; stdcall; external 'pdfium.dll';
function FPDFLink_GetAction(Link: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFLink_GetDest(Doc, Link: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFAction_GetURIPath(Doc, Action, Buffer: Pointer; BufLen: Cardinal): Cardinal; stdcall; external 'pdfium.dll';
function FPDFAction_GetDest(Doc, Action: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFDest_GetDestPageIndex(Doc, Dest: Pointer): Integer; stdcall; external 'pdfium.dll';

procedure FPDF_InitLibrary; stdcall; external 'pdfium.dll';
procedure FPDF_DestroyLibrary; stdcall; external 'pdfium.dll';
function FPDF_LoadDocument(FileName, Password: PAnsiChar): Pointer; stdcall; external 'pdfium.dll';
function FPDF_GetLastError: Cardinal; stdcall; external 'pdfium.dll';
function FPDF_GetSecurityHandlerRevision(Doc: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDF_GetDocPermissions(Doc: Pointer): NativeUInt; stdcall; external 'pdfium.dll';
procedure FPDF_CloseDocument(Doc: Pointer); stdcall; external 'pdfium.dll';
function FPDF_GetPageCount(Doc: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDF_GetFileVersion(Doc: Pointer; var FileVersion: Integer): Integer;
  stdcall; external 'pdfium.dll';
function FPDF_GetFileSize(Doc: Pointer): NativeUInt; stdcall; external 'pdfium.dll';
function FPDF_GetMetaText(Doc: Pointer; Tag: PAnsiChar; Buffer: Pointer;
  BufLen: Cardinal): Cardinal; stdcall; external 'pdfium.dll';
function FPDF_LoadPage(Doc: Pointer; Index: Integer): Pointer; stdcall; external 'pdfium.dll';
procedure FPDF_ClosePage(Page: Pointer); stdcall; external 'pdfium.dll';
procedure FPDFPage_Delete(Doc: Pointer; PageIndex: Integer); stdcall; external 'pdfium.dll';
function FPDFPage_GetRotation(Page: Pointer): Integer; stdcall; external 'pdfium.dll';
procedure FPDFPage_SetRotation(Page: Pointer; Rotate: Integer); stdcall; external 'pdfium.dll';
function FPDF_DeviceToPage(Page: Pointer; StartX, StartY, SizeX, SizeY, Rotate,
  DeviceX, DeviceY: Integer; var PageX, PageY: Double): Integer; stdcall; external 'pdfium.dll';
function FPDF_PageToDevice(Page: Pointer; StartX, StartY, SizeX, SizeY,
  Rotate: Integer; PageX, PageY: Double; var DeviceX, DeviceY: Integer): Integer;
  stdcall; external 'pdfium.dll';
function FPDFPage_CreateAnnot(Page: Pointer; Subtype: Integer): Pointer; stdcall; external 'pdfium.dll';
procedure FPDFPage_CloseAnnot(Annot: Pointer); stdcall; external 'pdfium.dll';
function FPDFAnnot_AddInkStroke(Annot: Pointer; Points: Pointer; Count: NativeUInt): Integer; stdcall; external 'pdfium.dll';
function FPDFAnnot_SetColor(Annot: Pointer; ColorType: Integer; R, G, B, A: Cardinal): Integer; stdcall; external 'pdfium.dll';
function FPDFAnnot_SetBorder(Annot: Pointer; HR, VR, BW: Single): Integer; stdcall; external 'pdfium.dll';
function FPDFAnnot_SetRect(Annot: Pointer; const R: TPDFInkRect): Integer; stdcall; external 'pdfium.dll';
function FPDFAnnot_SetFlags(Annot: Pointer; Flags: Integer): Integer; stdcall; external 'pdfium.dll';
function FPDF_SaveAsCopy(Doc: Pointer; Writer: PPDFFileWrite; Flags: Integer): Integer; stdcall; external 'pdfium.dll';
function FPDFText_LoadPage(Page: Pointer): Pointer; stdcall; external 'pdfium.dll';
procedure FPDFText_ClosePage(TextPage: Pointer); stdcall; external 'pdfium.dll';
function FPDFText_CountChars(TextPage: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDFText_GetText(TextPage: Pointer; StartIndex, Count: Integer;
  ResultBuffer: PWideChar): Integer; stdcall; external 'pdfium.dll';
function FPDFText_FindStart(TextPage: Pointer; FindWhat: PWideChar;
  Flags: Cardinal; StartIndex: Integer): Pointer; stdcall; external 'pdfium.dll';
function FPDFText_FindNext(Handle: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDFText_FindPrev(Handle: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDFText_GetSchResultIndex(Handle: Pointer): Integer; stdcall; external 'pdfium.dll';
function FPDFText_GetSchCount(Handle: Pointer): Integer; stdcall; external 'pdfium.dll';
procedure FPDFText_FindClose(Handle: Pointer); stdcall; external 'pdfium.dll';
function FPDFText_GetCharBox(TextPage: Pointer; Index: Integer; var Left, Right, Bottom, Top: Double): Integer; stdcall; external 'pdfium.dll';
function FPDFText_GetCharIndexAtPos(TextPage: Pointer; X, Y, XTolerance, YTolerance: Double): Integer; stdcall; external 'pdfium.dll';
function FPDFText_CountRects(TextPage: Pointer; StartIndex, Count: Integer): Integer; stdcall; external 'pdfium.dll';
function FPDFText_GetRect(TextPage: Pointer; RectIndex: Integer; var Left, Top, Right, Bottom: Double): Integer; stdcall; external 'pdfium.dll';
function FPDF_GetPageWidthF(Page: Pointer): Single; stdcall; external 'pdfium.dll';
function FPDF_GetPageHeightF(Page: Pointer): Single; stdcall; external 'pdfium.dll';
function FPDFBitmap_Create(Width, Height, Alpha: Integer): Pointer; stdcall; external 'pdfium.dll';
procedure FPDFBitmap_Destroy(Bitmap: Pointer); stdcall; external 'pdfium.dll';
function FPDFBitmap_GetBuffer(Bitmap: Pointer): Pointer; stdcall; external 'pdfium.dll';
function FPDFBitmap_GetStride(Bitmap: Pointer): Integer; stdcall; external 'pdfium.dll';
procedure FPDFBitmap_FillRect(Bitmap: Pointer; Left, Top, Width, Height: Integer; Color: Cardinal); stdcall; external 'pdfium.dll';
procedure FPDF_RenderPageBitmap(Bitmap, Page: Pointer; StartX, StartY, SizeX, SizeY, Rotate, Flags: Integer); stdcall; external 'pdfium.dll';

type
  PPixelRow = ^TPixelRow;
  TPixelRow = array[0..65535] of Cardinal;

var
  LibraryUsers: Integer = 0;

function TFreePDF64PDFiumCore.MetaText(const AKey: AnsiString): string;
var
  N: Cardinal;
  Buffer: TArray<WideChar>;
begin
  Result := '';
  if FDocument = nil then Exit;
  N := FPDF_GetMetaText(FDocument, PAnsiChar(AKey), nil, 0);
  if (N < 2) or (N > 65536) then Exit;
  SetLength(Buffer, (N div 2) + 1);
  if FPDF_GetMetaText(FDocument, PAnsiChar(AKey), @Buffer[0], N) > 0 then
    Result := string(PWideChar(@Buffer[0]));
end;

function TFreePDF64PDFiumCore.SecurityRevision: Integer;
begin
  Result := -1;
  if FDocument <> nil then
    Result := FPDF_GetSecurityHandlerRevision(FDocument);
end;

function TFreePDF64PDFiumCore.SecurityPermissions: UInt64;
begin
  Result := 0;
  if FDocument <> nil then
    Result := UInt64(FPDF_GetDocPermissions(FDocument));
end;

function TFreePDF64PDFiumCore.PDFVersion: string;
var V: Integer;
begin
  Result := '';
  V := 0;
  if (FDocument <> nil) and (FPDF_GetFileVersion(FDocument, V) <> 0) then
    Result := Format('%d.%d', [V div 10, V mod 10]);
end;

constructor TPDFBookmarkItem.Create;
begin
  inherited Create;
  PageIndex := -1;
  Children := TObjectList<TPDFBookmarkItem>.Create(True);
end;

destructor TPDFBookmarkItem.Destroy;
begin
  Children.Free;
  inherited;
end;

procedure TFreePDF64PDFiumCore.ReadBookmarks(AItems: TObjectList<TPDFBookmarkItem>);
  procedure AddLevel(AParent: Pointer; AList: TObjectList<TPDFBookmarkItem>; ADepth: Integer);
  var
    B, D, Act: Pointer;
    N: Cardinal;
    Buf: TArray<WideChar>;
    Item: TPDFBookmarkItem;
    Count: Integer;
  begin
    if ADepth > 48 then Exit;
    B := FPDFBookmark_GetFirstChild(FDocument, AParent);
    Count := 0;
    while (B <> nil) and (Count < 20000) do
    begin
      Inc(Count);
      Item := TPDFBookmarkItem.Create;
      N := FPDFBookmark_GetTitle(B, nil, 0);
      if (N >= 2) and (N <= 65536) then
      begin
        SetLength(Buf, N div 2 + 1);
        if FPDFBookmark_GetTitle(B, @Buf[0], N) > 0 then
          Item.Title := string(PWideChar(@Buf[0]));
      end;
      if Item.Title = '' then Item.Title := '(Ohne Titel)';
      D := FPDFBookmark_GetDest(FDocument, B);
      if D = nil then
      begin
        Act := FPDFBookmark_GetAction(B);
        if (Act <> nil) and (FPDFAction_GetType(Act) = 1) then
          D := FPDFAction_GetDest(FDocument, Act);
      end;
      if D <> nil then
        Item.PageIndex := FPDFDest_GetDestPageIndex(FDocument, D);
      AList.Add(Item);
      AddLevel(B, Item.Children, ADepth + 1);
      B := FPDFBookmark_GetNextSibling(FDocument, B);
    end;
  end;
begin
  AItems.Clear;
  if FDocument <> nil then AddLevel(nil, AItems, 0);
end;

constructor TFreePDF64PDFiumCore.Create;
begin
  inherited Create;
  FStrokes := TObjectList<TPDFInkStroke>.Create(True);
  FStrokePages := TList<Integer>.Create;
  if LibraryUsers = 0 then
    FPDF_InitLibrary;
  Inc(LibraryUsers);
end;

destructor TFreePDF64PDFiumCore.Destroy;
begin
  CloseFile;
  FStrokePages.Free;
  FStrokes.Free;
  Dec(LibraryUsers);
  if LibraryUsers = 0 then
    FPDF_DestroyLibrary;
  inherited Destroy;
end;

procedure TFreePDF64PDFiumCore.InvalidateSearchCache;
begin
  FSearchCacheValid := False;
  FSearchTerm := '';
  SetLength(FSearchCache, 0);
end;

procedure TFreePDF64PDFiumCore.CloseFile;
begin
  InvalidateSearchCache;
  if FDocument <> nil then
  begin
    FPDF_CloseDocument(FDocument);
    FDocument := nil;
  end;
  ClearUndo;
  FFileName := '';
  FPageCount := 0;
  FStrokes.Clear;
  FStrokePages.Clear;
  FModified := False;
end;

procedure TFreePDF64PDFiumCore.OpenFile(const AFileName: string; const APassword: AnsiString);
var
  Utf8Name: UTF8String;
begin
  CloseFile;
  if not FileExists(AFileName) then
    raise EPDFiumViewer.Create('PDF-Datei nicht gefunden: ' + AFileName);
  Utf8Name := UTF8Encode(ExpandFileName(AFileName));
  FDocument := FPDF_LoadDocument(PAnsiChar(Utf8Name), PAnsiChar(APassword));
  if FDocument = nil then
  begin
    if FPDF_GetLastError = 4 then // FPDF_ERR_PASSWORD
      raise EPDFiumPasswordRequired.Create('Für diese PDF-Datei ist ein gültiges Kennwort erforderlich.');
    raise EPDFiumViewer.Create('PDFium konnte die PDF-Datei nicht öffnen (PDFium-Fehler ' +
      IntToStr(FPDF_GetLastError) + ').');
  end;
  FFileName := ExpandFileName(AFileName);
  FPageCount := FPDF_GetPageCount(FDocument);
end;

procedure TFreePDF64PDFiumCore.AddStroke(APageIndex: Integer; APoints: TPDFInkStroke);
begin
  if (APoints = nil) or (APoints.Count < 2) then Exit;
  FStrokes.Add(APoints);
  FStrokePages.Add(APageIndex);
  FModified := True;
end;

function TFreePDF64PDFiumCore.PagePointToDevice(APageIndex, AWidth,
  AHeight: Integer; AX, AY: Double; out X, Y: Integer): Boolean;
var P: Pointer;
begin
  Result := False;
  if (FDocument = nil) or (APageIndex < 0) or
     (APageIndex >= FPageCount) then Exit;
  P := FPDF_LoadPage(FDocument, APageIndex);
  if P = nil then Exit;
  try
    Result := FPDF_PageToDevice(P, 0, 0, AWidth, AHeight, 0,
      AX, AY, X, Y) <> 0;
  finally
    FPDF_ClosePage(P);
  end;
end;

function TFreePDF64PDFiumCore.DevicePointToPage(APageIndex, AWidth, AHeight,
  X, Y: Integer; out AX, AY: Double): Boolean;
var P: Pointer;
begin
  Result := False;
  if (FDocument = nil) or (APageIndex < 0) or (APageIndex >= FPageCount) then Exit;
  P := FPDF_LoadPage(FDocument, APageIndex);
  if P = nil then Exit;
  try
    Result := FPDF_DeviceToPage(P, 0, 0, AWidth, AHeight, 0,
      X, Y, AX, AY) <> 0;
  finally
    FPDF_ClosePage(P);
  end;
end;

function TFreePDF64PDFiumCore.LinkAtPoint(APageIndex, AWidth, AHeight,
  X, Y: Integer; out ATarget: TPDFLinkTarget): Boolean;
var
  Page, Link, Action, Dest, TP, Web: Pointer;
  I, J, K, Hit, A, B, AtPos, DotPos: Integer;
  L, T, R, Bottom, CL, CR, CB, CT, NL, NR, NB, NT: Double;
  TextURL, Fragment: string;
  C: Cardinal;
  WBuf: array of WideChar;
  PX, PY: Double;
  N: Cardinal;
  Buf: TBytes;
  URL: UTF8String;
begin
  Result := False;
  ATarget.URI := '';
  ATarget.PageIndex := -1;
  if (FDocument = nil) or (APageIndex < 0) or (APageIndex >= FPageCount) or
     (AWidth <= 0) or (AHeight <= 0) then Exit;
  Page := FPDF_LoadPage(FDocument, APageIndex);
  if Page = nil then Exit;
  try
    if FPDF_DeviceToPage(Page, 0, 0, AWidth, AHeight, 0,
      X, Y, PX, PY) = 0 then Exit;
    Link := FPDFLink_GetLinkAtPoint(Page, PX, PY);
    if Link = nil then
    begin
      // Automatisch erkannte URLs sind oft keine PDF-Link-Annotationen.
      TP := FPDFText_LoadPage(Page);
      if TP = nil then Exit;
      try
        Web := FPDFLink_LoadWebLinks(TP);
        if Web <> nil then
        try
          for I := 0 to FPDFLink_CountWebLinks(Web) - 1 do
            for J := 0 to FPDFLink_CountRects(Web, I) - 1 do
              if (FPDFLink_GetRect(Web, I, J, L, T, R, Bottom) <> 0) and
                 (PX >= L) and (PX <= R) and (PY >= Bottom) and (PY <= T) then
              begin
                K := FPDFLink_GetURL(Web, I, nil, 0);
                if (K > 1) and (K < 8192) then
                begin
                  SetLength(WBuf, K);
                  FPDFLink_GetURL(Web, I, @WBuf[0], K);
                  ATarget.URI := PWideChar(@WBuf[0]);
                  // PDFium kann bei Textlinks ein www.-Ziel ohne Schema liefern.
                  if ATarget.URI.StartsWith('www.', True) then
                    ATarget.URI := 'https://' + ATarget.URI
                  else if (Pos('@', ATarget.URI) > 1) and
                          (Pos(':', ATarget.URI) = 0) then
                    ATarget.URI := 'mailto:' + ATarget.URI;
                  Exit(ATarget.URI <> '');
                end;
              end;
        finally
          FPDFLink_CloseWebLinks(Web);
        end;

        // Nur Zeichen derselben Textzeile verwenden. Word-PDFs koennen
        // zusaetzliche Leerzeichen und Steuerzeichen in der Textschicht haben.
        Hit := FPDFText_GetCharIndexAtPos(TP, PX, PY, 3, 3);
        if Hit < 0 then Exit;
        if FPDFText_GetCharBox(TP, Hit, CL, CR, CB, CT) = 0 then Exit;
        A := Hit;
        B := Hit;
        while (A > 0) and (Hit - A < 256) do
        begin
          if FPDFText_GetCharBox(TP, A - 1, NL, NR, NB, NT) = 0 then Break;
          if (Abs((NT + NB) / 2 - (CT + CB) / 2) > (CT - CB) * 0.45) or
             (CL - NR > (CT - CB) * 0.9) then Break;
          C := FPDFText_GetUnicode(TP, A - 1);
          if (C = 10) or (C = 13) then Break;
          Dec(A);
          CL := NL;
        end;
        CL := 0;
        while (B < FPDFText_CountChars(TP) - 1) and (B - Hit < 256) do
        begin
          if FPDFText_GetCharBox(TP, B, CL, CR, CB, CT) = 0 then Break;
          if FPDFText_GetCharBox(TP, B + 1, NL, NR, NB, NT) = 0 then Break;
          if (Abs((NT + NB) / 2 - (CT + CB) / 2) > (CT - CB) * 0.45) or
             (NL - CR > (CT - CB) * 0.9) then Break;
          C := FPDFText_GetUnicode(TP, B + 1);
          if (C = 10) or (C = 13) then Break;
          Inc(B);
        end;
        Fragment := '';
        for K := A to B do
        begin
          C := FPDFText_GetUnicode(TP, K);
          if (C > 32) and (C <= $FFFF) then
            Fragment := Fragment + Char(C);
        end;
        TextURL := Fragment.Trim;
        while (TextURL <> '') and CharInSet(TextURL[Length(TextURL)],
          ['.', ',', ';', ')', '>', '"']) do
          Delete(TextURL, Length(TextURL), 1);
        AtPos := Pos('@', TextURL);
        DotPos := LastDelimiter('.', TextURL);
        if TextURL.StartsWith('mailto:', True) and (AtPos > 8) and
           (DotPos > AtPos + 1) and (DotPos < Length(TextURL)) then
          ATarget.URI := TextURL
        else if (AtPos > 1) and (DotPos > AtPos + 1) and
                (DotPos < Length(TextURL)) and
                (Pos('://', TextURL) = 0) and (Pos(':', TextURL) = 0) then
          ATarget.URI := 'mailto:' + TextURL
        else if TextURL.StartsWith('www.', True) then
          ATarget.URI := 'https://' + TextURL
        else if TextURL.StartsWith('https://', True) or
                TextURL.StartsWith('http://', True) then
          ATarget.URI := TextURL;
        Result := ATarget.URI <> '';
      finally
        FPDFText_ClosePage(TP);
      end;
      Exit;
    end;
    Action := FPDFLink_GetAction(Link);
    if Action <> nil then
    begin
      case FPDFAction_GetType(Action) of
        3: begin // PDFACTION_URI
          N := FPDFAction_GetURIPath(FDocument, Action, nil, 0);
          if (N = 0) or (N > 8192) then Exit;
          SetLength(Buf, N);
          N := FPDFAction_GetURIPath(FDocument, Action, @Buf[0], N);
          if N = 0 then Exit;
          SetString(URL, PAnsiChar(@Buf[0]), N);
          ATarget.URI := string(URL).Trim;
          if (ATarget.URI <> '') and (ATarget.URI[Length(ATarget.URI)] = #0) then
            Delete(ATarget.URI, Length(ATarget.URI), 1);
          if ATarget.URI.StartsWith('www.', True) then
            ATarget.URI := 'https://' + ATarget.URI
          else if (Pos('@', ATarget.URI) > 1) and
                  (Pos(':', ATarget.URI) = 0) then
            ATarget.URI := 'mailto:' + ATarget.URI;
          Result := ATarget.URI <> '';
        end;
        1: begin // PDFACTION_GOTO
          Dest := FPDFAction_GetDest(FDocument, Action);
          if Dest <> nil then
            ATarget.PageIndex := FPDFDest_GetDestPageIndex(FDocument, Dest);
          Result := (ATarget.PageIndex >= 0) and (ATarget.PageIndex < FPageCount);
        end;
      end;
    end
    else
    begin
      Dest := FPDFLink_GetDest(FDocument, Link);
      if Dest <> nil then
        ATarget.PageIndex := FPDFDest_GetDestPageIndex(FDocument, Dest);
      Result := (ATarget.PageIndex >= 0) and (ATarget.PageIndex < FPageCount);
    end;
  finally
    FPDF_ClosePage(Page);
  end;
end;

procedure TFreePDF64PDFiumCore.RotatePages(AFirstPage, ALastPage,
  AAngle: Integer; const ATargetFile: string);
var
  I, NewRotation: Integer;
  Page: Pointer;
  W: TOutputWriter;
begin
  if FDocument = nil then
    raise EPDFiumViewer.Create('Es ist keine PDF-Datei geöffnet.');
  if (AFirstPage < 1) or (ALastPage > FPageCount) or
     (AFirstPage > ALastPage) or ((AAngle <> 90) and (AAngle <> 180) and (AAngle <> 270)) then
    raise EPDFiumViewer.Create('Ungültiger Seitenbereich oder Drehwinkel.');
  if SameText(ExpandFileName(ATargetFile), FFileName) then
    raise EPDFiumViewer.Create('Die Ausgabedatei muss von der Quelldatei abweichen.');
  for I := AFirstPage - 1 to ALastPage - 1 do
  begin
    Page := FPDF_LoadPage(FDocument, I);
    if Page = nil then
      raise EPDFiumViewer.CreateFmt('Seite %d konnte nicht geladen werden.', [I + 1]);
    try
      NewRotation := (FPDFPage_GetRotation(Page) + (AAngle div 90)) mod 4;
      FPDFPage_SetRotation(Page, NewRotation);
    finally
      FPDF_ClosePage(Page);
    end;
  end;
  FillChar(W, SizeOf(W), 0);
  W.Base.Version := 1;
  W.Base.WriteBlock := PDFWriteBlock;
  W.Stream := TFileStream.Create(ATargetFile, fmCreate);
  try
    if FPDF_SaveAsCopy(FDocument, @W.Base, 0) = 0 then
      raise EPDFiumViewer.Create('Die gedrehte PDF konnte nicht gespeichert werden.');
  finally
    W.Stream.Free;
  end;
end;

procedure TFreePDF64PDFiumCore.ClearUndo;
begin
  FHasUndo := False;
  if (FUndoFile <> '') and FileExists(FUndoFile) then
    DeleteFile(FUndoFile);
  FUndoFile := '';
end;

procedure TFreePDF64PDFiumCore.BeginUndo;
var
  Dir: array[0..MAX_PATH] of Char;
  Tmp: array[0..MAX_PATH] of Char;
  WasModified: Boolean;
  Source: string;
begin
  if FDocument = nil then Exit;
  ClearUndo;
  WasModified := FModified;
  Source := FFileName;
  if (GetTempPath(MAX_PATH, Dir) = 0) or
     (GetTempFileName(Dir, 'fpu', 0, Tmp) = 0) then RaiseLastOSError;
  FUndoFile := string(Tmp);
  try
    SaveAs(FUndoFile);
    FModified := WasModified;
    FUndoWasModified := WasModified;
    FUndoSource := Source;
    FHasUndo := True;
  except
    ClearUndo;
    raise;
  end;
end;

procedure TFreePDF64PDFiumCore.UndoLast;
var
  Temp, Source: string;
  WasModified: Boolean;
begin
  if not FHasUndo then Exit;
  Temp := FUndoFile;
  Source := FUndoSource;
  WasModified := FUndoWasModified;
  // Sicherungsdatei vor CloseFile vor automatischem Loeschen schuetzen.
  FUndoFile := '';
  FHasUndo := False;
  OpenFile(Temp);
  FFileName := Source;
  FModified := WasModified;
  // Die geoeffnete PDFium-Datei darf unter Windows noch referenziert sein.
  FUndoFile := '';
  FHasUndo := False;
end;

procedure TFreePDF64PDFiumCore.RotateInMemory(AFirstPage, ALastPage, AAngle: Integer);
var
  I: Integer;
  Page: Pointer;
begin
  if (AFirstPage < 1) or (ALastPage > FPageCount) or
     (AFirstPage > ALastPage) or (AAngle <> 90) then
    raise EPDFiumViewer.Create('Ungueltiger Seitenbereich oder Drehwinkel.');
  for I := AFirstPage - 1 to ALastPage - 1 do
  begin
    Page := FPDF_LoadPage(FDocument, I);
    if Page = nil then raise EPDFiumViewer.Create('Seite konnte nicht gedreht werden.');
    try
      FPDFPage_SetRotation(Page, (FPDFPage_GetRotation(Page) + 1) mod 4);
    finally
      FPDF_ClosePage(Page);
    end;
  end;
  FModified := True;
  InvalidateSearchCache;
end;

procedure TFreePDF64PDFiumCore.DeletePages(const APageIndices: TArray<Integer>);
var
  I, J, N: Integer;
  Selected: TArray<Boolean>;
begin
  if (FDocument = nil) or (Length(APageIndices) = 0) then Exit;
  SetLength(Selected, FPageCount);
  N := 0;
  for I := 0 to High(APageIndices) do
    if (APageIndices[I] >= 0) and (APageIndices[I] < FPageCount) and
       not Selected[APageIndices[I]] then
    begin
      Selected[APageIndices[I]] := True;
      Inc(N);
    end;
  if N = 0 then Exit;
  if N >= FPageCount then
    raise EPDFiumViewer.Create('Mindestens eine PDF-Seite muss erhalten bleiben.');
  // Die gespeicherten Markierungen beziehen sich auf die bisherigen Seitenindizes.
  for I := FStrokePages.Count - 1 downto 0 do
  begin
    if Selected[FStrokePages[I]] then
    begin
      FStrokePages.Delete(I);
      FStrokes.Delete(I);
    end
    else
    begin
      J := 0;
      for N := 0 to FStrokePages[I] - 1 do
        if Selected[N] then Inc(J);
      FStrokePages[I] := FStrokePages[I] - J;
    end;
  end;
  for I := High(Selected) downto 0 do
    if Selected[I] then FPDFPage_Delete(FDocument, I);
  FPageCount := FPDF_GetPageCount(FDocument);
  FModified := True;
end;

procedure TFreePDF64PDFiumCore.SaveAs(const AFileName: string);
var
  I, J: Integer;
  P, A: Pointer;
  R: TPDFInkRect;
  S: TPDFInkStroke;
  Points: TArray<TPDFInkPoint>;
  W: TOutputWriter;
  Target: string;
begin
  if FDocument = nil then Exit;
  Target := ExpandFileName(AFileName);
  if SameText(Target, FFileName) then
    raise EPDFiumViewer.Create('Bitte unter einem neuen Dateinamen speichern.');
  for I := 0 to FStrokes.Count - 1 do
  begin
    S := FStrokes[I];
    if S.Count = 0 then Continue;
    SetLength(Points, S.Count);
    for J := 0 to S.Count - 1 do
      Points[J] := S[J];
    P := FPDF_LoadPage(FDocument, FStrokePages[I]);
    if P = nil then raise EPDFiumViewer.Create('Markierungsseite konnte nicht geladen werden.');
    try
      A := FPDFPage_CreateAnnot(P, 15); // PDF_ANNOT_INK
      if A = nil then raise EPDFiumViewer.Create('PDF-Markierung konnte nicht erzeugt werden.');
      try
        if FPDFAnnot_AddInkStroke(A, @Points[0], Length(Points)) < 0 then
          raise EPDFiumViewer.Create('PDF-Markierungsstrich konnte nicht gespeichert werden.');
        FPDFAnnot_SetColor(A, 0,
          GetRValue(ColorToRGB(S.StrokeColor)),
          GetGValue(ColorToRGB(S.StrokeColor)),
          GetBValue(ColorToRGB(S.StrokeColor)), 115);
        FPDFAnnot_SetBorder(A, 0, 0, Max(0.5, S.LineWidth));
        R.Left := S[0].X; R.Right := R.Left;
        R.Bottom := S[0].Y; R.Top := R.Bottom;
        for J := 1 to S.Count - 1 do
        begin
          R.Left := Min(R.Left, S[J].X);
          R.Right := Max(R.Right, S[J].X);
          R.Bottom := Min(R.Bottom, S[J].Y);
          R.Top := Max(R.Top, S[J].Y);
        end;
        R.Left := R.Left - 9; R.Right := R.Right + 9;
        R.Bottom := R.Bottom - 9; R.Top := R.Top + 9;
        FPDFAnnot_SetRect(A, R);
        FPDFAnnot_SetFlags(A, 4);
      finally
        FPDFPage_CloseAnnot(A);
      end;
    finally
      FPDF_ClosePage(P);
    end;
  end;
  FillChar(W, SizeOf(W), 0);
  W.Base.Version := 1;
  W.Base.WriteBlock := PDFWriteBlock;
  W.Stream := TFileStream.Create(Target, fmCreate);
  try
    if FPDF_SaveAsCopy(FDocument, @W.Base, 0) = 0 then
      raise EPDFiumViewer.Create('PDFium konnte die PDF nicht speichern.');
  finally
    W.Stream.Free;
  end;
  FModified := False;
  FStrokes.Clear;
  FStrokePages.Clear;
end;

function TFreePDF64PDFiumCore.PageSize(APageIndex: Integer; out AWidth, AHeight: Single): Boolean;
var P: Pointer;
begin
  AWidth := 0;
  AHeight := 0;
  Result := (FDocument <> nil) and (APageIndex >= 0) and (APageIndex < FPageCount);
  if not Result then Exit;
  P := FPDF_LoadPage(FDocument, APageIndex);
  if P = nil then Exit(False);
  try
    AWidth := FPDF_GetPageWidthF(P);
    AHeight := FPDF_GetPageHeightF(P);
  finally
    FPDF_ClosePage(P);
  end;
end;

function TFreePDF64PDFiumCore.FindTextPage(const AText: string;
  AStartPage: Integer): Integer;
var
  Offset, Index, Count, N: Integer;
  P, TP: Pointer;
  Buffer: TArray<WideChar>;
  Content: string;
begin
  Result := -1;
  if (FDocument = nil) or (FPageCount <= 0) or (Trim(AText) = '') then Exit;
  for Offset := 0 to FPageCount - 1 do
  begin
    Index := (Max(0, AStartPage) + Offset) mod FPageCount;
    P := FPDF_LoadPage(FDocument, Index);
    if P = nil then Continue;
    try
      TP := FPDFText_LoadPage(P);
      if TP = nil then Continue;
      try
        Count := FPDFText_CountChars(TP);
        if Count <= 0 then Continue;
        SetLength(Buffer, Count + 1);
        N := FPDFText_GetText(TP, 0, Count, @Buffer[0]);
        if N <= 0 then Continue;
        Content := string(PWideChar(@Buffer[0]));
        if Pos(UpperCase(AText), UpperCase(Content)) > 0 then
          Exit(Index);
      finally
        FPDFText_ClosePage(TP);
      end;
    finally
      FPDF_ClosePage(P);
    end;
  end;
end;

function TFreePDF64PDFiumCore.MatchCharRects(APage, ACharIndex,
  ACharCount: Integer): TArray<TPDFInkRect>;
var
  P, TP: Pointer;
  I, N: Integer;
  L, R, B, T: Double;
  Box: TPDFInkRect;
begin
  SetLength(Result, 0);
  if (FDocument = nil) or (APage < 0) or (APage >= FPageCount) or
     (ACharIndex < 0) or (ACharCount <= 0) then Exit;
  P := FPDF_LoadPage(FDocument, APage);
  if P = nil then Exit;
  try
    TP := FPDFText_LoadPage(P);
    if TP = nil then Exit;
    try
      // PDFium gruppiert den Treffer nach Textzeilen statt pro Zeichen.
      N := FPDFText_CountRects(TP, ACharIndex, ACharCount);
      for I := 0 to N - 1 do
      begin
        if FPDFText_GetRect(TP, I, L, T, R, B) = 0 then Continue;
        if (R <= L) or (T <= B) then Continue;
        Box.Left := L; Box.Right := R;
        Box.Bottom := B; Box.Top := T;
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := Box;
      end;
    finally
      FPDFText_ClosePage(TP);
    end;
  finally
    FPDF_ClosePage(P);
  end;
end;

function TFreePDF64PDFiumCore.TextCharCount(APage: Integer): Integer;
var P, TP: Pointer;
begin
  Result := 0;
  if (FDocument = nil) or (APage < 0) or (APage >= FPageCount) then Exit;
  P := FPDF_LoadPage(FDocument, APage);
  if P = nil then Exit;
  try
    TP := FPDFText_LoadPage(P);
    if TP = nil then Exit;
    try Result := Max(0, FPDFText_CountChars(TP));
    finally FPDFText_ClosePage(TP); end;
  finally FPDF_ClosePage(P); end;
end;

function TFreePDF64PDFiumCore.TextCharAt(APage: Integer; AX, AY: Double): Integer;
var P, TP: Pointer;
begin
  Result := -1;
  if (FDocument = nil) or (APage < 0) or (APage >= FPageCount) then Exit;
  P := FPDF_LoadPage(FDocument, APage);
  if P = nil then Exit;
  try
    TP := FPDFText_LoadPage(P);
    if TP = nil then Exit;
    try Result := FPDFText_GetCharIndexAtPos(TP, AX, AY, 12, 12);
    finally FPDFText_ClosePage(TP); end;
  finally FPDF_ClosePage(P); end;
end;

function TFreePDF64PDFiumCore.TextRange(APage, AStart, ACount: Integer): string;
var P, TP: Pointer; Buf: TArray<WideChar>; N, Total: Integer;
begin
  Result := '';
  if (FDocument = nil) or (APage < 0) or (APage >= FPageCount) then Exit;
  P := FPDF_LoadPage(FDocument, APage);
  if P = nil then Exit;
  try
    TP := FPDFText_LoadPage(P);
    if TP = nil then Exit;
    try
      Total := FPDFText_CountChars(TP);
      AStart := Max(0, Min(AStart, Total));
      ACount := Max(0, Min(ACount, Total - AStart));
      if ACount = 0 then Exit;
      SetLength(Buf, ACount + 1);
      N := FPDFText_GetText(TP, AStart, ACount, @Buf[0]);
      if N > 1 then SetString(Result, PWideChar(@Buf[0]), N - 1);
    finally FPDFText_ClosePage(TP); end;
  finally FPDF_ClosePage(P); end;
end;

function TFreePDF64PDFiumCore.FindTextMatchesOnPage(
  const AText: string; APage: Integer): TArray<TPDFTextMatch>;
var
  Idx, Cnt, N: Integer;
  P, TP, H: Pointer;
  M: TPDFTextMatch;
begin
  SetLength(Result, 0);
  if (FDocument = nil) or (AText = '') or (APage < 0) or
     (APage >= FPageCount) then Exit;
  P := FPDF_LoadPage(FDocument, APage);
  if P = nil then Exit;
  try
    TP := FPDFText_LoadPage(P);
    if TP = nil then Exit;
    try
      H := FPDFText_FindStart(TP, PWideChar(AText), 0, 0);
      if H = nil then Exit;
      try
        while FPDFText_FindNext(H) <> 0 do
        begin
          Idx := FPDFText_GetSchResultIndex(H);
          Cnt := FPDFText_GetSchCount(H);
          if (Idx < 0) or (Cnt <= 0) then Continue;
          M.PageIndex := APage;
          M.CharIndex := Idx;
          M.CharCount := Cnt;
          N := Length(Result);
          SetLength(Result, N + 1);
          Result[N] := M;
        end;
      finally FPDFText_FindClose(H); end;
    finally FPDFText_ClosePage(TP); end;
  finally FPDF_ClosePage(P); end;
end;

function TFreePDF64PDFiumCore.FindAllTextMatches(
  const AText: string): TArray<TPDFTextMatch>;
var
  Pg, N, I: Integer;
  PageMatches: TArray<TPDFTextMatch>;
begin
  if FSearchCacheValid and (FSearchTerm = AText) then
    Exit(Copy(FSearchCache));
  SetLength(FSearchCache, 0);
  FSearchCacheValid := False;
  if (FDocument = nil) or (Trim(AText) = '') then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  for Pg := 0 to FPageCount - 1 do
  begin
    PageMatches := FindTextMatchesOnPage(AText, Pg);
    N := Length(FSearchCache);
    SetLength(FSearchCache, N + Length(PageMatches));
    for I := 0 to High(PageMatches) do
      FSearchCache[N + I] := PageMatches[I];
  end;
  FSearchTerm := AText;
  FSearchCacheValid := True;
  Result := Copy(FSearchCache);
end;

function TFreePDF64PDFiumCore.FindTextMatch(const AText: string;
  AStartPage, AStartChar, ADirection: Integer;
  out APage, ACharIndex, ACharCount: Integer): Boolean;
var
  Matches: TArray<TPDFTextMatch>;
  I, Selected: Integer;
begin
  Result := False;
  APage := -1;
  ACharIndex := -1;
  ACharCount := 0;
  Matches := FindAllTextMatches(AText);
  if Length(Matches) = 0 then Exit;
  Selected := -1;
  if ADirection >= 0 then
  begin
    for I := 0 to High(Matches) do
      if (Matches[I].PageIndex > AStartPage) or
         ((Matches[I].PageIndex = AStartPage) and
          (Matches[I].CharIndex >= AStartChar)) then
      begin
        Selected := I;
        Break;
      end;
    if Selected < 0 then Selected := 0;
  end
  else
  begin
    for I := High(Matches) downto 0 do
      if (Matches[I].PageIndex < AStartPage) or
         ((Matches[I].PageIndex = AStartPage) and
          (Matches[I].CharIndex <= AStartChar)) then
      begin
        Selected := I;
        Break;
      end;
    if Selected < 0 then Selected := High(Matches);
  end;
  APage := Matches[Selected].PageIndex;
  ACharIndex := Matches[Selected].CharIndex;
  ACharCount := Matches[Selected].CharCount;
  Result := True;
end;

procedure TFreePDF64PDFiumCore.RenderPage(APageIndex: Integer; ABitmap: TBitmap;
  AWidth, AHeight: Integer; ARotation: Integer);
var
  Page, PdfBitmap: Pointer;
  Y: Integer;
  SourceRow: PPixelRow;
begin
  if (FDocument = nil) or (APageIndex < 0) or (APageIndex >= FPageCount) then
    raise EPDFiumViewer.Create('Ungültige PDF-Seite.');
  if (ABitmap = nil) or (AWidth < 1) or (AHeight < 1) then
    raise EPDFiumViewer.Create('Ungültige Bitmap-Abmessungen.');
  Page := FPDF_LoadPage(FDocument, APageIndex);
  if Page = nil then
    raise EPDFiumViewer.Create('PDF-Seite konnte nicht geladen werden.');
  try
    PdfBitmap := FPDFBitmap_Create(AWidth, AHeight, 1);
    if PdfBitmap = nil then
      raise EPDFiumViewer.Create('PDFium-Bitmap konnte nicht angelegt werden.');
    try
      FPDFBitmap_FillRect(PdfBitmap, 0, 0, AWidth, AHeight, $FFFFFFFF);
      FPDF_RenderPageBitmap(PdfBitmap, Page, 0, 0, AWidth, AHeight,
        ((ARotation mod 4) + 4) mod 4, $01 or $02);
      ABitmap.PixelFormat := pf32bit;
      ABitmap.SetSize(AWidth, AHeight);
      // PDFium liefert BGRA. Die VCL-ScanLine-Indizierung wird hier
       // direkt verwendet, damit das Bild nicht vertikal gespiegelt wird.
      for Y := 0 to AHeight - 1 do
      begin
        SourceRow := PPixelRow(NativeUInt(FPDFBitmap_GetBuffer(PdfBitmap)) +
          NativeUInt(Y) * NativeUInt(FPDFBitmap_GetStride(PdfBitmap)));
        Move(SourceRow^, ABitmap.ScanLine[Y]^, AWidth * 4);
      end;
    finally
      FPDFBitmap_Destroy(PdfBitmap);
    end;
  finally
    FPDF_ClosePage(Page);
  end;
end;

end.
