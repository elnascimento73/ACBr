{******************************************************************************}
{ Projeto: Componente ACBrCTe                                                  }
{  Biblioteca multiplataforma de componentes Delphi para emiss�o de Conhecimen-}
{ to de Transporte eletr�nico - CTe - http://www.cte.fazenda.gov.br            }
{                                                                              }
{ Direitos Autorais Reservados (c) 2008 Wemerson Souto                         }
{                                       Wiliam Zacarias da Silva Rosa          }
{                                       Daniel Simoes de Almeida               }
{                                       Andr� Ferreira de Moraes               }
{                                                                              }
{ Desenvolvimento                                                              }
{         de Cte: Wiliam Zacarias da Silva Rosa                                }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{$I ACBr.inc}

unit ACBrCTe;

interface

uses
  Classes, Sysutils,
  ACBrDFe, ACBrDFeConfiguracoes,
  ACBrCTeConfiguracoes, ACBrCTeWebServices, ACBrCTeConhecimentos,
  ACBrCTeDACTEClass, ACBrDFeException,
  pcteCTe, pcnConversao, pcteConversaoCTe,
  pcteEnvEventoCTe, pcteInutCTe, pcteRetDistDFeInt,
  ACBrDFeUtil, ACBrUtil;

const
  ACBRCTE_VERSAO = '2.0.0a';
  ACBRCTE_NAMESPACE = 'http://www.portalfiscal.inf.br/cte';
  ACBRCTE_CErroAmbDiferente = 'Ambiente do XML (tpAmb) � diferente do '+
     'configurado no Componente (Configuracoes.WebServices.Ambiente)';

type
  EACBrCTeException = class(EACBrDFeException);

  { TACBrCTe }

  TACBrCTe = class(TACBrDFe)
  private
    FDACTe: TACBrCTeDACTEClass;
    FConhecimentos: TConhecimentos;
    FEventoCTe: TEventoCTe;
    FInutCTe: TInutCTe;
    FRetDistDFeInt: TRetDistDFeInt;
    FStatus: TStatusACBrCTe;
    FWebServices: TWebServices;

    function GetConfiguracoes: TConfiguracoesCTe;
    function Distribuicao(AcUFAutor: integer; ACNPJCPF, AultNSU, ANSU,
      chCTe: String): Boolean;

    procedure SetConfiguracoes(AValue: TConfiguracoesCTe);
  	procedure SetDACTE(const Value: TACBrCTeDACTEClass);

  protected
    function CreateConfiguracoes: TConfiguracoes; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetAbout: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetNomeModeloDFe: String; override;
    function GetNameSpaceURI: String; override;

    function cStatConfirmado(AValue: Integer): Boolean;
    function cStatProcessado(AValue: Integer): Boolean;
    function cStatCancelado(AValue: integer): Boolean;

    function NomeServicoToNomeSchema(const NomeServico: String): String; override;
    procedure LerServicoDeParams(LayOutServico: TLayOutCTe; var Versao: Double;
      var URL: String); reintroduce; overload;
    function LerVersaoDeParams(LayOutServico: TLayOutCTe): String; reintroduce; overload;

    function IdentificaSchema(const AXML: String): TSchemaCTe;
    function IdentificaSchemaModal(const AXML: String): TSchemaCTe;
    function IdentificaSchemaEvento(const AXML: String): TSchemaCTe;

    function GerarNomeArqSchema(const ALayOut: TLayOutCTe; VersaoServico: Double): String;
    function GerarNomeArqSchemaModal(const AXML: String; VersaoServico: Double): String;
    function GerarNomeArqSchemaEvento(ASchemaEventoCTe: TSchemaCTe; VersaoServico: Double): String;

    function GerarChaveContingencia(FCTe: TCTe): String;

    procedure SetStatus(const stNewStatus: TStatusACBrCTe);

    function Enviar(ALote: Integer; Imprimir: Boolean = True): Boolean;  overload;
    function Enviar(ALote: String; Imprimir: Boolean = True): Boolean;  overload;

    function Consultar( AChave: String = ''): Boolean;
    function Cancelamento(AJustificativa: String; ALote: Integer = 0): Boolean;
    function EnviarEvento(idLote: Integer): Boolean;
    function Inutilizar(ACNPJ, AJustificativa: String;
      AAno, ASerie, ANumInicial, ANumFinal: Integer): Boolean;
    function DistribuicaoDFePorUltNSU(AcUFAutor: integer;
      ACNPJCPF, AultNSU: String): Boolean;
    function DistribuicaoDFePorNSU(AcUFAutor: integer;
      ACNPJCPF, ANSU: String): Boolean;
    (*
    function DistribuicaoDFePorChaveCTe(AcUFAutor: integer;
      ACNPJCPF, AchCTe: String): Boolean;
    *)
    procedure EnviarEmail(sPara, sAssunto: String;
      sMensagem: TStrings = nil; sCC: TStrings = nil; Anexos: TStrings = nil;
      StreamCTe: TStream = nil; NomeArq: String = ''; sReplyTo: TStrings = nil); override;

    procedure EnviarEmailEvento(sPara, sAssunto: String;
      sMensagem: TStrings = nil; sCC: TStrings = nil; Anexos: TStrings = nil;
      sReplyTo: TStrings = nil);

    procedure ImprimirEvento;
    procedure ImprimirEventoPDF;
    procedure ImprimirInutilizacao;
    procedure ImprimirInutilizacaoPDF;

    property WebServices: TWebServices     read FWebServices   write FWebServices;
    property Conhecimentos: TConhecimentos read FConhecimentos write FConhecimentos;
    property EventoCTe: TEventoCTe         read FEventoCTe     write FEventoCTe;
    property InutCTe: TInutCTe             read FInutCTe       write FInutCTe;
    property RetDistDFeInt: TRetDistDFeInt read FRetDistDFeInt write FRetDistDFeInt;
    property Status: TStatusACBrCTe        read FStatus;

  published
    property Configuracoes: TConfiguracoesCTe read GetConfiguracoes write SetConfiguracoes;
  	property DACTE: TACBrCTeDACTEClass        read FDACTE           write SetDACTE;
  end;

implementation

uses
  strutils, dateutils,
  pcnAuxiliar, synacode;

{$IFDEF FPC}
 {$IFDEF CPU64}
  {$R ACBrCTeServicos.res}  // Dificuldades de compilar Recurso em 64 bits
 {$ELSE}
  {$R ACBrCTeServicos.rc}
 {$ENDIF}
{$ELSE}
 {$R ACBrCTeServicos.res}
{$ENDIF}

{ TACBrCTe }

constructor TACBrCTe.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FConhecimentos := TConhecimentos.Create(Self, Conhecimento);
  FEventoCTe := TEventoCTe.Create;
  FInutCTe := TInutCTe.Create;
  FRetDistDFeInt := TRetDistDFeInt.Create;
  FWebServices := TWebServices.Create(Self);
end;

destructor TACBrCTe.Destroy;
begin
  FConhecimentos.Free;
  FEventoCTe.Free;
  FInutCTe.Free;
  FRetDistDFeInt.Free;
  FWebServices.Free;

  inherited;
end;

function TACBrCTe.GetConfiguracoes: TConfiguracoesCTe;
begin
  Result := TConfiguracoesCTe(FPConfiguracoes);
end;

procedure TACBrCTe.SetConfiguracoes(AValue: TConfiguracoesCTe);
begin
  FPConfiguracoes := AValue;
end;

procedure TACBrCTe.SetDACTE(const Value: TACBrCTeDACTEClass);
var
  OldValue: TACBrCTeDACTEClass;
begin
  if Value <> FDACTE then
  begin
     if Assigned(FDACTE) then
        FDACTE.RemoveFreeNotification(Self);

     OldValue := FDACTE;   // Usa outra variavel para evitar Loop Infinito
     FDACTE   := Value;    // na remo��o da associa��o dos componentes

     if Assigned(OldValue) then
        if Assigned(OldValue.ACBrCTe) then
           OldValue.ACBrCTe := nil;

     if Value <> nil then
     begin
        Value.FreeNotification(self);
        Value.ACBrCTe := self;
     end;
  end;
end;

function TACBrCTe.CreateConfiguracoes: TConfiguracoes;
begin
  Result := TConfiguracoesCTe.Create(Self);
end;

procedure TACBrCTe.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (FDACTE <> nil) and
     (AComponent is TACBrCTeDACTEClass) then
    FDACTE := nil;
end;

function TACBrCTe.GetAbout: String;
begin
  Result := 'ACBrCTe Ver: ' + ACBRCTE_VERSAO;
end;

function TACBrCTe.GetNomeModeloDFe: String;
begin
  Result := ModeloCTeToPrefixo( Configuracoes.Geral.ModeloDF );
end;

function TACBrCTe.GetNameSpaceURI: String;
begin
  Result := ACBRCTE_NAMESPACE;
end;

function TACBrCTe.cStatConfirmado(AValue: Integer): Boolean;
begin
  case AValue of
    100, 150: Result := True;
    else
      Result := False;
  end;
end;

function TACBrCTe.cStatProcessado(AValue: Integer): Boolean;
begin
  case AValue of
    100, 110, 150, 301, 302: Result := True;
    else
      Result := False;
  end;
end;

function TACBrCTe.cStatCancelado(AValue: integer): Boolean;
begin
  case AValue of
    101, 151, 155: Result := True;
    else
      Result := False;
  end;
end;

function TACBrCTe.NomeServicoToNomeSchema(const NomeServico: String): String;
Var
  ok: Boolean;
  ALayout: TLayOutCTe;
begin
  ALayout := ServicoToLayOut(ok, NomeServico);
  if ok then
    Result := SchemaCTeToStr( LayOutToSchema( ALayout ) )
  else
    Result := '';
end;

procedure TACBrCTe.LerServicoDeParams(LayOutServico: TLayOutCTe;
  var Versao: Double; var URL: String);
var
  AUF: String;
begin
  case Configuracoes.Geral.FormaEmissao of
    teNormal: AUF := Configuracoes.WebServices.UF;
    teDPEC: begin
              case Configuracoes.WebServices.UFCodigo of
                11, // Rond�nia
                12, // Acre
                13, // Amazonas
                14, // Roraima
                15, // Par�
                16, // Amap�
                17, // Tocantins
                21, // Maranh�o
                22, // Piau�
                23, // Cear�
                24, // Rio Grande do Norte
                25, // Paraib�
                27, // Alagoas
                28, // Sergipe
                29, // Bahia
                31, // Minas Gerais
                32, // Espirito Santo
                33, // Rio de Janeiro
                41, // Paran�
                42, // Santa Catarina
                43, // Rio Grande do Sul
                52, // Goi�s
                53: // Distrito Federal
                    AUF := 'SVC-SP';
                26, // Pernanbuco
                35, // S�o Paulo
                50, // Mato Grosso do Sul
                51: // Mato Grosso
                    AUF := 'SVC-RS';
              end;
            end;
    teSVCAN: AUF := 'SVC-AN';
    teSVCRS: AUF := 'SVC-RS';
    teSVCSP: AUF := 'SVC-SP';
  else
    AUF := Configuracoes.WebServices.UF;
  end;

  Versao := VersaoCTeToDbl(Configuracoes.Geral.VersaoDF);
  URL := '';
  LerServicoDeParams(GetNomeModeloDFe, AUF,
    Configuracoes.WebServices.Ambiente, LayOutToServico(LayOutServico),
    Versao, URL);
end;

function TACBrCTe.LerVersaoDeParams(LayOutServico: TLayOutCTe): String;
var
  Versao: Double;
begin
  Versao := LerVersaoDeParams(GetNomeModeloDFe, Configuracoes.WebServices.UF,
    Configuracoes.WebServices.Ambiente, LayOutToServico(LayOutServico),
    VersaoCTeToDbl(Configuracoes.Geral.VersaoDF));

  Result := FloatToString(Versao, '.', '0.00');
end;

function TACBrCTe.IdentificaSchema(const AXML: String): TSchemaCTe;
var
 lTipoEvento: TpcnTpEvento;
 I: Integer;
 Ok: Boolean;
begin
  if Configuracoes.Geral.ModeloDF = moCTe then
    Result := schCTe
  else
    Result := schCTeOS;

  I := pos('<infCte', AXML);
  if I = 0  then
  begin
    I := pos('<infInut', AXML);
    if I > 0 then
      Result := schInutCTe
    else begin
      I := pos('<infEvento', AXML);
      if I > 0 then
      begin
        lTipoEvento := StrToTpEvento(Ok, Trim(RetornarConteudoEntre(AXML, '<tpEvento>', '</tpEvento>')));

        case lTipoEvento of
          teCCe:          Result := schEventoCTe;
          teCancelamento: Result := schEventoCTe;
          teEPEC:         Result := schEventoCTe;
          teMultiModal:   Result := schEventoCTe;
          else            Result := schErro;
        end;
      end
      else
        Result := schErro;
    end;
  end;
end;

function TACBrCTe.IdentificaSchemaModal(const AXML: String): TSchemaCTe;
var
  XML: String;
  I: Integer;
begin
  XML := Trim(RetornarConteudoEntre(AXML, '<infModal', '</infModal>'));

  Result := schcteModalRodoviario;

  I := pos( '<rodo>', XML);
  if I = 0 then
  begin
    I := pos( '<rodoOS>', XML);
    if I > 0 then
      Result := schcteModalRodoviarioOS
    else begin
      I := pos( '<aereo>', XML);
      if I > 0 then
        Result := schcteModalAereo
      else begin
        I := pos( '<aquav>', XML);
        if I > 0 then
          Result := schcteModalAquaviario
        else begin
          I := pos( '<duto>', XML);
          if I > 0 then
            Result := schcteModalDutoviario
          else begin
            I := pos( '<ferrov>', XML);
            if I > 0 then
              Result := schcteModalFerroviario
            else begin
              I := pos( '<multimodal>', XML);
              if I > 0 then
                Result := schcteMultiModal
              else
                Result := schErro;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TACBrCTe.IdentificaSchemaEvento(const AXML: String): TSchemaCTe;
begin
  // Implementar
  Result := schErro;
end;

function TACBrCTe.GerarNomeArqSchema(const ALayOut: TLayOutCTe;
  VersaoServico: Double): String;
var
  NomeServico, NomeSchema, ArqSchema: String;
  Versao: Double;
begin
  // Procura por Vers�o na pasta de Schemas //
  NomeServico := LayOutToServico(ALayOut);
  NomeSchema := NomeServicoToNomeSchema(NomeServico);
  ArqSchema := '';
  if NaoEstaVazio(NomeSchema) then
  begin
    Versao := VersaoServico;
    AchaArquivoSchema( NomeSchema, Versao, ArqSchema );
  end;

  Result := ArqSchema;
end;

function TACBrCTe.GerarNomeArqSchemaModal(const AXML: String;
  VersaoServico: Double): String;
begin
  if VersaoServico = 0.0 then
    Result := ''
  else
    Result := PathWithDelim( Configuracoes.Arquivos.PathSchemas ) +
              SchemaCTeToStr(IdentificaSchemaModal(AXML)) + '_v' +
              FloatToString(VersaoServico, '.', '0.00') + '.xsd';
end;

function TACBrCTe.GerarNomeArqSchemaEvento(ASchemaEventoCTe: TSchemaCTe;
  VersaoServico: Double): String;
begin
  if VersaoServico = 0.0 then
    Result := ''
  else
    Result := PathWithDelim( Configuracoes.Arquivos.PathSchemas ) +
              SchemaCTeToStr(ASchemaEventoCTe) + '_v' +
              FloatToString(VersaoServico, '.', '0.00') + '.xsd';
end;

function TACBrCTe.GerarChaveContingencia(FCTe:TCTe): String;

  function GerarDigito_Contingencia(out Digito: Integer; chave: String): Boolean;
  var
    i, j: Integer;
  const
    PESO = '43298765432987654329876543298765432';
  begin
    chave  := OnlyNumber(chave);
    j      := 0;
    Digito := 0;
    result := True;
    try
      for i := 1 to 35 do
        j := j + StrToInt(copy(chave, i, 1)) * StrToInt(copy(PESO, i, 1));
      Digito := 11 - (j mod 11);
      if (j mod 11) < 2 then
        Digito := 0;
    except
      result := False;
    end;
    if length(chave) <> 35 then
      result := False;
  end;

var
  wchave: String;
  wicms_s, wicms_p: String;
  wd,wm,wa: word;
  Digito: Integer;
begin
  if FCTe.Ide.toma4.CNPJCPF <> '' then
  begin
    if FCTe.Ide.toma4.enderToma.UF = 'EX' then
      wchave := '99' //exterior
    else
      wchave := copy(inttostr(FCTe.Ide.toma4.enderToma.cMun),1,2);
  end
  else begin
    case FCTe.Ide.toma03.Toma of
     tmRemetente: if FCTe.Rem.enderReme.UF = 'EX' then
                    wchave := '99' //exterior
                  else
                    wchave := copy(inttostr(FCTe.Rem.enderReme.cMun), 1, 2);
     tmExpedidor: if FCTe.Exped.enderExped.UF = 'EX' then
                    wchave := '99' //exterior
                  else
                    wchave := copy(inttostr(FCTe.Exped.enderExped.cMun), 1, 2);
     tmRecebedor: if FCTe.Receb.enderReceb.UF = 'EX' then
                    wchave := '99' //exterior
                  else
                    wchave := copy(inttostr(FCTe.Receb.enderReceb.cMun), 1, 2);
     tmDestinatario: if FCTe.Dest.EnderDest.UF = 'EX' then
                       wchave := '99' //exterior
                     else
                       wchave := copy(inttostr(FCTe.Dest.EnderDest.cMun), 1, 2);
    end;
  end;

  case FCTe.Ide.tpEmis of
   teDPEC,
   teContingencia: wchave := wchave + '2';
   teFSDA:         wchave := wchave + '5';
   else            wchave := wchave + '0'; //este valor caracteriza ERRO, valor tem q ser  2 ou 5
  end;

  if FCTe.Ide.toma4.CNPJCPF <> '' then
  begin
    if FCTe.Ide.toma4.enderToma.UF = 'EX' then
      wchave := wchave + Poem_Zeros('0', 14)
    else
      wchave := wchave + Poem_Zeros(FCTe.Ide.toma4.CNPJCPF, 14);
  end
  else begin
    case FCTe.Ide.toma03.Toma of
     tmRemetente: if (FCTe.Rem.enderReme.UF='EX') then
                    wchave := wchave + Poem_Zeros('0', 14)
                  else
                    wchave := wchave + Poem_Zeros(FCTe.Rem.CNPJCPF, 14);
     tmExpedidor: if (FCTe.Exped.enderExped.UF='EX') then
                    wchave := wchave + Poem_Zeros('0', 14)
                  else
                    wchave := wchave + Poem_Zeros(FCTe.Exped.CNPJCPF, 14);
     tmRecebedor: if (FCTe.Receb.enderReceb.UF='EX') then
                    wchave := wchave + Poem_Zeros('0', 14)
                  else
                    wchave := wchave + Poem_Zeros(FCTe.Receb.CNPJCPF, 14);
     tmDestinatario: if (FCTe.Dest.EnderDest.UF='EX') then
                       wchave := wchave + Poem_Zeros('0', 14)
                     else
                       wchave := wchave + Poem_Zeros(FCTe.Dest.CNPJCPF, 14);
    end;
  end;

  //VALOR DA CT-e
  wchave := wchave + Poem_Zeros(OnlyNumber(FloatToStrf(FCTe.vPrest.vTPrest, ffFixed, 18, 2)), 14);

  //DESTAQUE ICMS PROPRIO E ST
  wicms_p := '2';
  wicms_s := '2';

  // Checar esse trecho

{$IFDEF PL_103}
  if (NaoEstaZerado(FCTe.Imp.ICMS.CST00.vICMS)) then
    wicms_p := '1';
  if (NaoEstaZerado(FCTe.Imp.ICMS.CST80.vICMS)) then
    wicms_s := '1';
{$ELSE}
  if (NaoEstaZerado(FCTe.Imp.ICMS.ICMS00.vICMS)) then
    wicms_p := '1';
  if (NaoEstaZerado(FCTe.Imp.ICMS.ICMSOutraUF.vICMSOutraUF)) then
    wicms_s := '1';
{$ENDIF}

  wchave := wchave + wicms_p + wicms_s;

  //DIA DA EMISSAO
  decodedate(FCTe.Ide.dhEmi, wa, wm, wd);
  wchave := wchave + Poem_Zeros(inttostr(wd), 2);

  //DIGITO VERIFICADOR
  GerarDigito_Contingencia(Digito, wchave);
  wchave := wchave + inttostr(digito);

  //RETORNA A CHAVE DE CONTINGENCIA
  result := wchave;
end;

procedure TACBrCTe.SetStatus(const stNewStatus: TStatusACBrCTe);
begin
  if (stNewStatus <> FStatus) then
  begin
    FStatus := stNewStatus;
    if Assigned(OnStatusChange) then
      OnStatusChange(Self);
  end;
end;

function TACBrCTe.Enviar(ALote: Integer; Imprimir: Boolean = True): Boolean;
begin
  Result := Enviar(IntToStr(ALote), Imprimir);
end;

function TACBrCTe.Enviar(ALote: String; Imprimir: Boolean): Boolean;
var
  i: Integer;
begin
  if Conhecimentos.Count <= 0 then
    GerarException(ACBrStr('ERRO: Nenhum CT-e adicionado ao Lote'));

  if Conhecimentos.Count > 50 then
    GerarException(ACBrStr('ERRO: Conjunto de CT-e transmitidos (m�ximo de 50 CT-e)' +
      ' excedido. Quantidade atual: ' + IntToStr(Conhecimentos.Count)));

  Conhecimentos.Assinar;
  Conhecimentos.Validar;

  Result := WebServices.Envia(ALote);

  if DACTE <> nil then
  begin
     for i := 0 to Conhecimentos.Count-1 do
     begin
       if Conhecimentos.Items[i].Confirmado and Imprimir then
       begin
         Conhecimentos.Items[i].Imprimir;
       end;
     end;
  end;
end;

function TACBrCTe.Consultar(AChave: String): Boolean;
var
  i: Integer;
begin
  if (Conhecimentos.Count = 0) and EstaVazio(AChave) then
    GerarException(ACBrStr('ERRO: Nenhum CT-e ou Chave Informada!'));

  if NaoEstaVazio(AChave) then
  begin
    Conhecimentos.Clear;
    WebServices.Consulta.CTeChave := AChave;
    WebServices.Consulta.Executar;
  end
  else
  begin
    for i := 0 to Conhecimentos.Count - 1 do
    begin
      WebServices.Consulta.CTeChave := Conhecimentos.Items[i].NumID;
      WebServices.Consulta.Executar;
    end;
  end;

  Result := True;
end;

function TACBrCTe.Cancelamento(AJustificativa: String; ALote: Integer): Boolean;
var
  i: Integer;
begin
  if Conhecimentos.Count = 0 then
    GerarException(ACBrStr('ERRO: Nenhum CT-e Informado!'));

  for i := 0 to Conhecimentos.Count - 1 do
  begin
    WebServices.Consulta.CTeChave := Conhecimentos.Items[i].NumID;

    if not WebServices.Consulta.Executar then
      raise Exception.Create(WebServices.Consulta.Msg);

    EventoCTe.Evento.Clear;
    with EventoCTe.Evento.Add do
    begin
      infEvento.CNPJ := copy(OnlyNumber(WebServices.Consulta.CTeChave), 7, 14);
      infEvento.cOrgao := StrToIntDef(copy(OnlyNumber(WebServices.Consulta.CTeChave), 1, 2), 0);
      infEvento.dhEvento := now;
      infEvento.tpEvento := teCancelamento;
      infEvento.chCTe := WebServices.Consulta.CTeChave;
      infEvento.detEvento.nProt := WebServices.Consulta.Protocolo;
      infEvento.detEvento.xJust := AJustificativa;
    end;

    try
      EnviarEvento(ALote);
    except
      raise Exception.Create(WebServices.EnvEvento.EventoRetorno.xMotivo);
    end;
  end;

  Result := True;
end;

function TACBrCTe.EnviarEvento(idLote: Integer): Boolean;
var
  i, j: Integer;
  chCTe: String;
begin
  if EventoCTe.Evento.Count <= 0 then
    GerarException(ACBrStr('ERRO: Nenhum Evento adicionado ao Lote'));

  if EventoCTe.Evento.Count > 20 then
    GerarException(ACBrStr('ERRO: Conjunto de Eventos transmitidos (m�ximo de 20) ' +
      'excedido. Quantidade atual: ' + IntToStr(EventoCTe.Evento.Count)));

  WebServices.EnvEvento.idLote := idLote;

  {Atribuir nSeqEvento, CNPJ, Chave e/ou Protocolo quando n�o especificar}
  for i := 0 to EventoCTe.Evento.Count -1 do
  begin
    if EventoCTe.Evento.Items[i].InfEvento.nSeqEvento = 0 then
      EventoCTe.Evento.Items[i].infEvento.nSeqEvento := 1;

    FEventoCTe.Evento.Items[i].InfEvento.tpAmb := Configuracoes.WebServices.Ambiente;

    if Conhecimentos.Count > 0 then
    begin
      chCTe := OnlyNumber(EventoCTe.Evento.Items[i].InfEvento.chCTe);

      // Se tem a chave do CTe no Evento, procure por ela nos conhecimentos carregados //
      if NaoEstaVazio(chCTe) then
      begin
        for j := 0 to Conhecimentos.Count - 1 do
        begin
          if chCTe = Conhecimentos.Items[j].NumID then
            Break;
        end;

        if j = Conhecimentos.Count then
          GerarException( ACBrStr('N�o existe CTe com a chave ['+chCTe+'] carregado') );
      end
      else
        j := 0;

      if trim(EventoCTe.Evento.Items[i].InfEvento.CNPJ) = '' then
        EventoCTe.Evento.Items[i].InfEvento.CNPJ := Conhecimentos.Items[j].CTe.Emit.CNPJ;

      if chCTe = '' then
        EventoCTe.Evento.Items[i].InfEvento.chCTe := Conhecimentos.Items[j].NumID;

      if trim(EventoCTe.Evento.Items[i].infEvento.detEvento.nProt) = '' then
      begin
        if EventoCTe.Evento.Items[i].infEvento.tpEvento = teCancelamento then
        begin
          EventoCTe.Evento.Items[i].infEvento.detEvento.nProt := Conhecimentos.Items[j].CTe.procCTe.nProt;

          if trim(EventoCTe.Evento.Items[i].infEvento.detEvento.nProt) = '' then
          begin
            WebServices.Consulta.CTeChave := EventoCTe.Evento.Items[i].InfEvento.chCTe;

            if not WebServices.Consulta.Executar then
              GerarException(WebServices.Consulta.Msg);

            EventoCTe.Evento.Items[i].infEvento.detEvento.nProt := WebServices.Consulta.Protocolo;
          end;
        end;
      end;
    end;
  end;

  Result := WebServices.EnvEvento.Executar;

  if not Result then
    GerarException( WebServices.EnvEvento.Msg );
end;

function TACBrCTe.Inutilizar(ACNPJ, AJustificativa: String; AAno, ASerie,
  ANumInicial, ANumFinal: Integer): Boolean;
begin
  Result := True;
  WebServices.Inutiliza(ACNPJ, AJustificativa, AAno, 57,
                        ASerie, ANumInicial, ANumFinal);
end;

function TACBrCTe.Distribuicao(AcUFAutor: integer; ACNPJCPF, AultNSU, ANSU,
  chCTe: String): Boolean;
begin
  WebServices.DistribuicaoDFe.cUFAutor := AcUFAutor;
  WebServices.DistribuicaoDFe.CNPJCPF := ACNPJCPF;
  WebServices.DistribuicaoDFe.ultNSU := AultNSU;
  WebServices.DistribuicaoDFe.NSU := ANSU;
//  WebServices.DistribuicaoDFe.chCTe := AchCTe;

  Result := WebServices.DistribuicaoDFe.Executar;

  if not Result then
    GerarException( WebServices.DistribuicaoDFe.Msg );
end;

function TACBrCTe.DistribuicaoDFePorUltNSU(AcUFAutor: integer; ACNPJCPF,
  AultNSU: String): Boolean;
begin
  Result := Distribuicao(AcUFAutor, ACNPJCPF, AultNSU, '', '');
end;

function TACBrCTe.DistribuicaoDFePorNSU(AcUFAutor: integer; ACNPJCPF,
  ANSU: String): Boolean;
begin
  Result := Distribuicao(AcUFAutor, ACNPJCPF, '', ANSU, '');
end;
(*
function TACBrCTe.DistribuicaoDFePorChaveCTe(AcUFAutor: integer; ACNPJCPF,
  AchCTe: String): Boolean;
begin
  Result := Distribuicao(AcUFAutor, ACNPJCPF, '', '', AchCTe);
end;
*)
procedure TACBrCTe.EnviarEmail(sPara, sAssunto: String; sMensagem: TStrings;
  sCC: TStrings; Anexos: TStrings; StreamCTe: TStream; NomeArq: String;
  sReplyTo: TStrings);
begin
  SetStatus( stCTeEmail );

  try
    inherited EnviarEmail(sPara, sAssunto, sMensagem, sCC, Anexos, StreamCTe, NomeArq,
     sReplyTo);
  finally
    SetStatus( stCTeIdle );
  end;
end;

procedure TACBrCTe.EnviarEmailEvento(sPara, sAssunto: String;
  sMensagem: TStrings; sCC: TStrings; Anexos: TStrings; sReplyTo: TStrings);
var
  NomeArq: String;
  AnexosEmail: TStrings;
begin
  AnexosEmail := TStringList.Create;
  try
    AnexosEmail.Clear;

    if Anexos <> nil then
      AnexosEmail.Text := Anexos.Text;

    ImprimirEventoPDF;
    NomeArq := OnlyNumber(EventoCTe.Evento[0].InfEvento.Id);
    NomeArq := PathWithDelim(DACTE.PathPDF) + NomeArq + '-procEventoCTe.pdf';
    AnexosEmail.Add(NomeArq);

    EnviarEmail(sPara, sAssunto, sMensagem, sCC, AnexosEmail, nil, '', sReplyTo);
  finally
    AnexosEmail.Free;
  end;
end;

procedure TACBrCTe.ImprimirEvento;
begin
  if not Assigned(DACTE) then
    raise EACBrCTeException.Create('Componente DACTE n�o associado.')
  else
    DACTE.ImprimirEVENTO(nil);
end;

procedure TACBrCTe.ImprimirEventoPDF;
begin
  if not Assigned(DACTE) then
    raise EACBrCTeException.Create('Componente DACTE n�o associado.')
  else
    DACTE.ImprimirEVENTOPDF(nil);
end;

procedure TACBrCTe.ImprimirInutilizacao;
begin
  if not Assigned(DACTE) then
    raise EACBrCTeException.Create('Componente DACTE n�o associado.')
  else
    DACTE.ImprimirINUTILIZACAO(nil);
end;

procedure TACBrCTe.ImprimirInutilizacaoPDF;
begin
  if not Assigned(DACTE) then
    raise EACBrCTeException.Create('Componente DACTE n�o associado.')
  else
    DACTE.ImprimirINUTILIZACAOPDF(nil);
end;

end.
