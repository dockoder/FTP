object Service2: TService2
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'Service2'
  Left = 192
  Top = 122
  Height = 150
  Width = 215
  object FTP: TIdFTPServer
    Bindings = <>
    CommandHandlers = <
      item
        CmdDelimiter = ' '
        Disconnect = False
        Name = 'TIdCommandHandler0'
        ParamDelimiter = ' '
        ReplyExceptionCode = 0
        ReplyNormal.NumericCode = 0
        Tag = 0
      end>
    DefaultPort = 21
    Greeting.NumericCode = 220
    Greeting.Text.Strings = (
      'Servidor de FTP.')
    Greeting.TextCode = '220'
    MaxConnectionReply.NumericCode = 421
    MaxConnectionReply.Text.Strings = (
      'Mano, a casa caiu pro c'#234' !!! Tchau !!!')
    MaxConnectionReply.TextCode = '421'
    MaxConnections = 10
    ReplyExceptionCode = 0
    ReplyTexts = <
      item
        NumericCode = 0
      end
      item
        NumericCode = 0
      end>
    ReplyUnknownCommand.NumericCode = 500
    ReplyUnknownCommand.Text.Strings = (
      'Syntax error, command unrecognized.')
    ReplyUnknownCommand.TextCode = '500'
    ThreadMgr = ThreadManager
    AnonymousAccounts.Strings = (
      'anonymous'
      'ftp'
      'guest')
    HelpReply.Strings = (
      'Aqui n'#227'o tem help n'#227'o meu irm'#227'o.'
      'Quer help ??? Chama o batman !!!')
    UserAccounts = UserManager
    SystemType = 'WIN32'
    OnAfterUserLogin = FTPAfterUserLogin
    OnChangeDirectory = FTPChangeDirectory
    OnGetFileSize = FTPGetFileSize
    OnUserLogin = FTPUserLogin
    OnListDirectory = FTPListDirectory
    OnRenameFile = FTPRenameFile
    OnDeleteFile = FTPDeleteFile
    OnRetrieveFile = FTPRetrieveFile
    OnStoreFile = FTPStoreFile
    OnMakeDirectory = FTPMakeDirectory
    OnRemoveDirectory = FTPRemoveDirectory
    Left = 48
    Top = 16
  end
  object UserManager: TIdUserManager
    Accounts = <
      item
      end>
    CaseSensitiveUsernames = False
    CaseSensitivePasswords = False
    Left = 96
    Top = 16
  end
  object ThreadManager: TIdThreadMgrDefault
    Left = 80
    Top = 72
  end
end
