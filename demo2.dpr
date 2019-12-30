{$APPTYPE CONSOLE}
uses

  crtunit, crtplus, odbc32, windows;

var

  app   : pApplet;
  drv1  : pDriveComboBox;
  lst1  : pListBox;
  ed1   : pEdit;

  henv, hdbc, hstmt     : cardinal;
  dsnname, driver, msg  : string;
  outlen                : cardinal;
  sqltext               : string;
  tnm                   : pchar;

  e                     : cardinal;

function examine( retcode: SQLResult ): boolean;
var
  naterror, natret      : integer;
begin
  result := (retcode = 0) or (retcode = 1);
{  if retcode < 0 then begin
    ret := SQLError( henv, hdbc, hstmt, pchar( sqlstate ), naterror, pchar( msg ), 255, natret );
    msg := pchar( msg );
    sqlstate := pchar( sqlstate );
    writeln( sqlstate + #13#10 + msg );
  end;}
end;

procedure runcommand;
begin

  lst1.clear;
  
  sqltext := ed1.text;
  examine( SQLExecDirect(hstmt, pchar( sqltext ), length( sqltext ) ) );
  getmem( tnm, 129 );
  examine( SQLBindCol( hstmt, 1, SQL_CHAR, tnm, 129, outlen ) );

  while examine( SQLFetch( hstmt ) ) do
    lst1.add( tnm, false );

  examine( SQLFreeStmt( hstmt, SQL_CLOSE ) );
  lst1.paint;

end;

BEGIN

  app := newApplet( 1, 1, 25, 80, 'demo', CKS_ALT, Ord( 'X' ) );

  shortcuts := newShortCut( app );
  shortcuts.add( CKS_ANY, VK_F5, runcommand );

  ed1 := newEdit( app );
  with ed1^ do begin
    left := 1;
    top := 1;
    width := 79;
    height := 1;
    focused := true;
  end;

  lst1 := newListBox( app );
  with lst1^ do
  begin
    left := 1;
    top := 3;
    width := 77;
    height := 20;
  end;

  dsnname := 'DRIVER={SQL Server};SERVER=(local);UID=sa;PWD=;DATABASE=LOGP';
  setlength( msg , 255 );

  examine( SQLSetEnvAttr(SQL_NULL_HANDLE, SQL_ATTR_CONNECTION_POOLING, SQL_CP_ONE_PER_HENV, 0) );
  examine( SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, henv) );
  examine( SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC2, 0) );
  examine( SQLAllocHandle(SQL_HANDLE_DBC, henv, hdbc) );
  examine( SQLDriverConnect(hdbc, GetForeGroundWindow, pchar( dsnname ), length( dsnname ), pchar( msg ), 255, outlen, 0) );
  examine( SQLAllocHandle(SQL_HANDLE_STMT, hdbc, hstmt) );

  run( app );

  examine( SQLFreeHandle(SQL_HANDLE_STMT, hstmt) );
  examine( SQLDisconnect(hdbc) );
  examine( SQLFreeHandle(SQL_HANDLE_DBC, hdbc) );

  fillbuff80x25( 0 );

END.