#include "hbqtgui.ch"
#include "hbqtsql.ch"

REQUEST HB_CODEPAGE_RU1251

STATIC s_db, s_oBrowser

PROC main()
   LOCAL oMainWindow, oELoop, lExit := .F.//, oApp
   LOCAL oStrModel, oStrList//, db
   LOCAL oBox
   CLS
   
   hbqt_errorSys()
   hb_setTermCP("RU1251","RU1251")
   hb_cdpSelect("RU1251")//???????? ??????? ???????? ??????????

s_qApp := QApplication()
   oMainWindow := QMainWindow()
   oMainWindow:setAttribute( Qt_WA_DeleteOnClose, .F. )

   oMainWindow:setWindowTitle("Qt SQL Browser")
   s_oBrowser = hbqtui_browserwidget(oMainWindow)
   
   oMainWindow:setCentralWidget(s_oBrowser:oWidget)
   
   oMainWindow:connect( QEvent_Close   , {|| lExit := .T. } )
  
   s_db = QSqlDatabase():addDatabase("QODBC")
*   s_db:setHostName("localhost")
   s_db:setDatabaseName("DRIVER={SQL Server};Server=127.0.0.1;Database=test2;Trusted_Connection=yes;")
   
   IF .NOT. s_db:open()
      oBox := QMessageBox()
      oBox:setInformativeText( " Not Connected! " )
      oBox:exec()
      ?"Not Connected!"
      RETURN
   ENDIF

   oStrList :=s_db:tables()
   oStrModel := QStringListModel( oStrList, s_oBrowser:listView )
   s_oBrowser:listView:setModel( oStrModel )
   s_oBrowser:listView:connect( "clicked(QModelIndex)", { |d| showTable(d) } )

   oMainWindow:show()
s_qApp:exec()

   RETURN
   
PROCEDURE showTable(d)
   LOCAL cTName
   LOCAL model
   cTName := s_oBrowser:listView:model():data(d, 0):ToString()
   cTName := s_db:driver:escapeIdentifier(cTName, 1/*QSqlDriver():IdentifierType:TableName*/)

    model := QSqlTableModel(s_oBrowser:table, s_db)
    model:setTable(cTName)
    if (model:lastError():type() != 0)
       ?model:lastError():text()
    endif
    model:select()
    if (model:lastError():type() != 0)
       ??model:lastError():text()
    endif
    s_oBrowser:table:setModel(model)
//    s_oBrowser:table:setEditTriggers(QAbstractItemView_DoubleClicked+QAbstractItemView_EditKeyPressed)
   RETURN