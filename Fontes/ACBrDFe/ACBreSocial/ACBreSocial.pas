{******************************************************************************}
{ Projeto: Componente ACBreSocial                                              }
{  Biblioteca multiplataforma de componentes Delphi para envio dos eventos do  }
{ eSocial - http://www.esocial.gov.br/                                         }
{                                                                              }
{ Direitos Autorais Reservados (c) 2008 Wemerson Souto                         }
{                                       Daniel Simoes de Almeida               }
{                                       Andr� Ferreira de Moraes               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
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

{******************************************************************************
|* Historico
|*
|* 27/10/2015: Jean Carlo Cantu, Tiago Ravache
|*  - Doa��o do componente para o Projeto ACBr
|* 28/08/2017: Leivio Fontenele - leivio@yahoo.com.br
|*  - Implementa��o comunica��o, envelope, status e retorno do componente com webservice.
******************************************************************************}
{$I ACBr.inc}

unit ACBreSocial;

interface

uses
  Classes, SysUtils, ACBrUtil,
  ACBrDFe, ACBrDFeException, ACBrDFeConfiguracoes,
  ACBreSocialConfiguracoes, ACBreSocialWebServices, ACBreSocialEventos,
  pcnConversao, pcesConversaoeSocial;

resourcestring
  ACBRESOCIAL_CErroAmbienteDiferente = 'Ambiente do XML (tpAmb) � diferente do configurado no Componente (Configuracoes.WebServices.Ambiente)';
  ACBRESOCIAL_CErroSignLib = 'Necess�rio DigestMethod Algorithm SHA256. use xsXmlSec ou xsLibXml2 na propriedade SSLXmlSignLib.';
  ACBRESOCIAL_CErroCryptLib = 'Necess�rio DigestMethod Algorithm SHA256. use cryOpenSSL ou cryWinCrypt na propriedade SSLCryptLib.';

const
  ACBRESOCIAL_NAMESPACE = ' http://www.esocial.gov.br/servicos/empregador/lote/eventos/envio/v1_1_0';
  ACBRESOCIAL_NAMESPACE_CON = 'http://www.esocial.gov.br/schema/lote/eventos/envio/consulta/retornoProcessamento/v1_0_0';
  ACBRESOCIAL_NAMESPACE_RETEVT = 'http://www.esocial.gov.br/schema/consulta/identificadoreseventos/empregador/v1_0_0';
  ACBRESOCIAL_NAMESPACE_DOWEVTID = 'http://www.esocial.gov.br/schema/download/solicitacao/id/v1_0_0';
  ACBRESOCIAL_NAMESPACE_DOWEVTREC = 'http://www.esocial.gov.br/schema/download/solicitacao/nrRecibo/v1_0_0';
  ACBRESOCIAL_NAMESPACE_URI = 'http://www.esocial.gov.br/schema/evt/';
  ACBRESOCIAL_MODELODF = 'eSocial';

type

  EACBreSocialException = class(EACBrDFeException);
  TNotifyEventoseSocial = procedure(const AXML: AnsiString; ATipo: TeSocialEventos) of object;

  { TACBreSocial }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF RTL230_UP}
  TACBreSocial = class(TACBrDFe)
  private
    FEventos: TEventos;
    FStatus : TStatusACBreSocial;
    FWebServices: TWebServices;

    FOnTransmissaoEventos: TNotifyEventoseSocial;

    function GetConfiguracoes: TConfiguracoeseSocial;
    procedure SetConfiguracoes(AValue: TConfiguracoeseSocial);
  protected
    function CreateConfiguracoes: TConfiguracoes; override;
    function NomeServicoToNomeSchema(const NomeServico: String): String; override;
    function VersaoSchemaDoubleToString(AVersao: Double): String; virtual;
    function VersaoSchemaStringToDouble(AVersao: String): Double; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AssinarEventos;
    procedure LerServicoDeParams(LayOutServico: TLayOut; var Versao: Double; var URL: String); overload;
    procedure SetStatus(const stNewStatus: TStatusACBreSocial);

    function GetNomeModeloDFe: string; override;
    function GetNameSpaceURI: string; override;
    function LerVersaoDeParams(LayOutServico: TLayOut): String; reintroduce; overload;

    function Enviar(AGrupo: TeSocialGrupo): boolean;
    function Consultar(const AProtocolo: string): boolean;
    function ConsultaIdentificadoresEventosEmpregador(const CnpjEstab: String;
        tpEvt: TTipoEvento; PerApur: TDateTime): boolean;

    function DownloadEventos(const CnpjEmpr, PorID, PorNrRecibo: String): boolean;

    property Eventos: TEventos read FEventos write FEventos;
    property Status: TStatusACBreSocial read FStatus;
    property WebServices: TWebServices read FWebServices write FWebServices;

  published
    property Configuracoes: TConfiguracoeseSocial read GetConfiguracoes write SetConfiguracoes;
    property OnTransmissaoEventos: TNotifyEventoseSocial read FOnTransmissaoEventos write FOnTransmissaoEventos;

  end;

implementation

{$IFDEF FPC}
 {$IFDEF CPU64}
  {$R ACBreSocialServicos.res}  // Dificuldades de compilar Recurso em 64 bits
 {$ELSE}
  {$R ACBreSocialServicos.rc}
 {$ENDIF}
{$ELSE}
 {$R ACBreSocialServicos.res}
{$ENDIF}

{ TACBreSocial }

uses
  ACBrDFeSSL;

constructor TACBreSocial.Create(AOwner: TComponent);
begin
  inherited;

  SSL.SSLDgst := dgstSHA256;
  FEventos := TEventos.Create(Self);
  FWebServices := TWebServices.Create(Self);
end;

destructor TACBreSocial.Destroy;
begin
  FEventos.Free;
  FWebServices.Free;

  inherited;
end;

function TACBreSocial.GetConfiguracoes: TConfiguracoeseSocial;
begin
  Result := TConfiguracoeseSocial(FPConfiguracoes);
end;

procedure TACBreSocial.SetConfiguracoes(AValue: TConfiguracoeseSocial);
begin
  FPConfiguracoes := AValue;
end;

function TACBreSocial.CreateConfiguracoes: TConfiguracoes;
begin
  Result := TConfiguracoeseSocial.Create(Self);
end;

function TACBreSocial.Enviar(AGrupo: TeSocialGrupo): boolean;
begin
  WebServices.EnvioLote.Clear;

  result := WebServices.Envia(AGrupo);
end;

function TACBreSocial.Consultar(const AProtocolo: string): boolean;
begin
  Result := WebServices.Consultar(AProtocolo);
end;

function TACBreSocial.ConsultaIdentificadoresEventosEmpregador(const CnpjEstab: String;
  tpEvt: TTipoEvento; PerApur: TDateTime): boolean;
begin
  Result := WebServices.ConsultaIdentificadoresEventosEmpregador(CnpjEstab, tpEvt, PerApur);
end;

function TACBreSocial.DownloadEventos(const CnpjEmpr, PorID,
  PorNrRecibo: String): boolean;
begin
  Result := WebServices.DownloadEvento(CnpjEmpr, PorID, PorNrRecibo);
end;

procedure TACBreSocial.AssinarEventos;
begin
  Eventos.GerarXMLs;
  if Configuracoes.Geral.Salvar then
    Eventos.SaveToFiles;
end;

function TACBreSocial.NomeServicoToNomeSchema(const NomeServico: String): String;
var
  ok: Boolean;
  ALayout: TLayOut;
begin
  ALayout := ServicoToLayOut(ok, NomeServico);
  if ok then
    Result := SchemaESocialToStr( LayOutToSchema( ALayout ) )
  else
    Result := '';
end;

function TACBreSocial.VersaoSchemaDoubleToString(AVersao: Double): String;
var
  StrVer: String;
begin
  Result := '';

  if (AVersao > 0) then
  begin
    StrVer := FloatToString(AVersao, '.', '0.00');
    StrVer := StringReplace(StrVer,'.','',[rfReplaceAll]);
    Result := StrVer[1] + '_' + StrVer[2] + '_' + StrVer[3];
  end;
end;

function TACBreSocial.VersaoSchemaStringToDouble(AVersao: String): Double;
var
  StrVer: String;
begin
  Result := 0;
  if (AVersao <> '') then
  begin
    StrVer := StringReplace(AVersao,'_','',[rfReplaceAll]);
    StrVer := PadRight(StrVer, 3, '0');
    Result := StringToFloatDef(StrVer[1]+'.'+StrVer[2]+StrVer[3], 0);
  end;
end;

procedure TACBreSocial.LerServicoDeParams(LayOutServico: TLayOut; var Versao: Double; var URL: String);
Var
  Sessao: string;
begin
  if Configuracoes.WebServices.Ambiente = taHomologacao then
    Sessao := 'eSocial_H'
  else
    Sessao := 'eSocial_P';

  LerServicoChaveDeParams(Sessao, LayOuteSocialToServico(LayOutServico), Versao, URL);
  Versao := VersaoeSocialToDbl(Configuracoes.Geral.VersaoDF);
end;

function TACBreSocial.LerVersaoDeParams(LayOutServico: TLayOut): String;
var
  Versao: Double;
begin
  Versao := LerVersaoDeParams(GetNomeModeloDFe, Configuracoes.WebServices.UF,
    Configuracoes.WebServices.Ambiente, LayOuteSocialToServico(LayOutServico),
    VersaoeSocialToDbl(Configuracoes.Geral.VersaoDF));

  Result := FloatToString(Versao, '.', '0.00');
end;

procedure TACBreSocial.SetStatus(const stNewStatus: TStatusACBreSocial);
begin
  if stNewStatus <> FStatus then
  begin
    FStatus := stNewStatus;
    if Assigned(OnStatusChange) then
      OnStatusChange(Self);
  end;
end;

function TACBreSocial.GetNomeModeloDFe: string;
begin
  Result := 'eSocial';
end;

function TACBreSocial.GetNameSpaceURI: string;
begin
  Result := ACBRESOCIAL_NAMESPACE;
end;

end.
