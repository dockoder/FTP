object Form4: TForm4
  Left = 233
  Top = 106
  Width = 696
  Height = 480
  Caption = 'Form4'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 242
    Width = 688
    Height = 12
    Cursor = crVSplit
    Align = alBottom
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 7697781
    TabOrder = 0
    object Label1: TLabel
      Left = 7
      Top = 15
      Width = 17
      Height = 13
      Caption = 'IP:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16512
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 191
      Top = 15
      Width = 5
      Height = 13
      Caption = ':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16512
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 471
      Top = 7
      Width = 54
      Height = 13
      Caption = 'Seus IP'#39's'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16512
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object txtIP: TEdit
      Left = 25
      Top = 12
      Width = 160
      Height = 21
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object cmdConectar: TBitBtn
      Left = 264
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Conectar'
      TabOrder = 1
      OnClick = cmdConectarClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000333300
        0000377777FFFF7777770FFFF099990FFFF07FFFF777777FFFF7000000333300
        00007777773333777777307703333330770337FF7F333337FF7F300003333330
        0003377773333337777333993333333399333F7FFFF3333FF7FF000000333300
        0000777777F3337777770FFFF033330FFFF07FFFF7F3337FFFF7000000333300
        00007777773333777777307703333330770337FF7F333337FF7F300003333330
        0003377773FFFFF777733393300000033933337F3777777F37F3339990FFFF09
        99333373F7FFFF7FF73333399000000993333337777777777333333333077033
        33333333337FF7F3333333333300003333333333337777333333}
      NumGlyphs = 2
    end
    object Button1: TButton
      Left = 728
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Transferir'
      TabOrder = 2
      Visible = False
    end
    object txtPorta: TSpinEdit
      Left = 200
      Top = 12
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 50000
    end
    object cmbIPs: TComboBox
      Left = 472
      Top = 24
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = 'cmbIPs'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 254
    Width = 688
    Height = 161
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'painel'
    TabOrder = 1
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 688
      Height = 145
      ActivePage = TabSheet2
      Align = alTop
      TabOrder = 0
      object TabSheet2: TTabSheet
        Caption = 'Liga'#231#245'es'
        object lvConns: TListView
          Left = 0
          Top = 0
          Width = 680
          Height = 117
          Align = alClient
          Color = 7697781
          Columns = <
            item
              Caption = 'IP'
              Width = 80
            end
            item
              Caption = 'Nick'
              Width = 80
            end
            item
              Caption = 'Status'
              Width = 150
            end
            item
              Caption = 'Porta'
              Width = 80
            end
            item
              Caption = 'Activo'
            end
            item
              Caption = 'email'
              Width = 120
            end
            item
              Alignment = taRightJustify
              Caption = 'partilha'
              Width = 80
            end>
          ReadOnly = True
          PopupMenu = popmenu
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Transfer'#234'ncias'
        ImageIndex = 1
        object lvTrans: TListView
          Left = 0
          Top = 0
          Width = 680
          Height = 117
          Align = alClient
          Color = 15329769
          Columns = <
            item
              Caption = 'Fonte'
              Width = 80
            end
            item
              Caption = 'Tarefa'
              Width = 80
            end
            item
              Alignment = taCenter
              Caption = 'Transfer'#234'ncia'
              MaxWidth = 100
              MinWidth = 100
              Width = 100
            end
            item
              Caption = 'Arquivo'
              Width = 80
            end
            item
              Alignment = taCenter
              Caption = 'Tempo'
              MaxWidth = 80
              MinWidth = 80
              Width = 80
            end
            item
              Caption = 'Tamanho'
              Width = 80
            end
            item
              Alignment = taRightJustify
              Caption = 'Velocidade'
              Width = 90
            end>
          PopupMenu = popmenu
          TabOrder = 0
          ViewStyle = vsReport
          OnCustomDrawItem = lvTransCustomDrawItem
        end
      end
    end
  end
  object page: TPageControl
    Left = 0
    Top = 65
    Width = 688
    Height = 177
    ActivePage = Status
    Align = alClient
    TabOrder = 2
    TabPosition = tpBottom
    object Status: TTabSheet
      Caption = 'Mensagens'
      object Splitter3: TSplitter
        Left = 457
        Top = 0
        Height = 151
      end
      object lvOutros: TListView
        Left = 460
        Top = 0
        Width = 220
        Height = 151
        Align = alClient
        Columns = <
          item
            Caption = 'nick'
            Width = 80
          end
          item
            Alignment = taCenter
            Caption = 'ip'
            Width = 80
          end
          item
            Caption = 'email'
            Width = 80
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
      object memo: TRichEdit
        Left = 0
        Top = 0
        Width = 457
        Height = 151
        Align = alLeft
        Color = clBlack
        Font.Charset = OEM_CHARSET
        Font.Color = clLime
        Font.Height = -8
        Font.Name = 'Courier'
        Font.Style = []
        Lines.Strings = (
          'Server')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Lista de downloads'
      ImageIndex = 2
      object ListView2: TListView
        Left = 0
        Top = 0
        Width = 680
        Height = 151
        Align = alClient
        Columns = <
          item
            Caption = 'Arquivo/Ficheiro'
            Width = 150
          end
          item
            Alignment = taCenter
            Caption = 'Estatus/Status'
            Width = 90
          end
          item
            Alignment = taRightJustify
            Caption = 'Tamanho'
            Width = 60
          end
          item
            Caption = 'Prioridade'
            Width = 100
          end
          item
            Caption = 'Fonte'
          end
          item
            Caption = 'Caminho'
            Width = 180
          end
          item
            Caption = 'Erros'
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Lista de arquivos de ???'
      ImageIndex = 2
      object Splitter2: TSplitter
        Left = 233
        Top = 0
        Width = 4
        Height = 151
      end
      object lvArquivos: TListView
        Left = 237
        Top = 0
        Width = 443
        Height = 151
        Align = alClient
        Columns = <
          item
            Caption = 'Arquivo/Ficheiro'
            Width = 150
          end
          item
            Caption = 'Tipo'
          end
          item
            Alignment = taRightJustify
            Caption = 'Tamanho'
            Width = 80
          end>
        RowSelect = True
        PopupMenu = popArquivos
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = lvArquivosSelectItem
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 233
        Height = 151
        Align = alLeft
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = 'Panel3'
        TabOrder = 1
        object Label4: TLabel
          Left = 0
          Top = 0
          Width = 229
          Height = 13
          Align = alTop
          Caption = ' Direct'#243'rios'
          Color = clBackground
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object TreeView: TTreeView
          Left = 0
          Top = 13
          Width = 229
          Height = 115
          Align = alClient
          BorderStyle = bsNone
          Color = clWhite
          Indent = 19
          TabOrder = 0
          OnChange = TreeViewChange
        end
        object statusbarArquivos: TStatusBar
          Left = 0
          Top = 128
          Width = 229
          Height = 19
          Panels = <
            item
              Bevel = pbRaised
              Text = 'partilhando:'
              Width = 60
            end
            item
              Width = 50
            end>
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 415
    Width = 688
    Height = 19
    Panels = <
      item
        Width = 350
      end
      item
        Text = 'Total:'
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object dlg: TOpenDialog
    Left = 320
    Top = 80
  end
  object MainMenu1: TMainMenu
    Left = 288
    Top = 80
    object aRQUIVOS1: TMenuItem
      Caption = 'Arquivos/Ficheiros'
      object mnuiniciar: TMenuItem
        Caption = 'Iniciar'
        OnClick = mnuiniciarClick
      end
      object mnureiniciar: TMenuItem
        Caption = 'Reiniciar servidores'
        OnClick = mnureiniciarClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuAbrirDirPadrao: TMenuItem
        Caption = 'Abrir direct'#243'rio padr'#227'o...'
        OnClick = mnuAbrirDirPadraoClick
      end
    end
    object mnuferramentas: TMenuItem
      Caption = 'Ferramentas'
      object mnuopcoes: TMenuItem
        Caption = 'Op'#231#245'es'
        OnClick = mnuopcoesClick
      end
    end
  end
  object popmenu: TPopupMenu
    Left = 8
    Top = 320
    object mnureconectar: TMenuItem
      Caption = 'Reconectar'
    end
    object mnudesconectar: TMenuItem
      Caption = 'Desconectar'
      OnClick = mnudesconectarClick
    end
  end
  object popArquivos: TPopupMenu
    Left = 376
    Top = 104
    object mnuDownArquivo: TMenuItem
      Caption = 'Download'
      OnClick = mnuDownArquivoClick
    end
    object mnuDownArquivoPara: TMenuItem
      Caption = 'Download para...'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnuDownAgenda: TMenuItem
      Caption = 'Agenda...'
    end
  end
  object server: TTcpServer
    LocalPort = '50001'
    OnAccept = serverAccept
    OnCreateHandle = serverCreateHandle
    Left = 368
    Top = 8
  end
  object client: TTcpClient
    RemotePort = '50001'
    Left = 408
    Top = 8
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 336
    Top = 224
  end
end
