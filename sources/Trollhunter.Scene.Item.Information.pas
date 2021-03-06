﻿unit Trollhunter.Scene.Item.Information;

interface

uses
  Trollhunter.Types,
  Trollhunter.Scenes;

type
  TSceneItemInfo = class(TScene)
  private
    FShowInfo: Boolean;
    procedure RenderInformation;
  public
    procedure Render; override;
    procedure Update(var Key: UInt); override;
    constructor Create;
  end;

implementation

{ TSceneItemInfo }

uses
  SysUtils,
  BearLibTerminal,
  uBearLibItemsCommon,
  uBearLibItemsInventory,
  Trollhunter.UI,
  Trollhunter.UI.Log,
  Trollhunter.Player,
  Trollhunter.Item,
  Trollhunter.Language,
  Trollhunter.Game,
  Trollhunter.Helpers,
  Trollhunter.Item.Types,
  Trollhunter.Item.Base,
  Trollhunter.Terminal;

var
  CurItem: Item;

constructor TSceneItemInfo.Create;
begin
  FShowInfo := False;
end;

procedure TSceneItemInfo.Render;
begin
  inherited;
  Y := 1;
  if FShowInfo then
  begin
    // Info
    Title(Items.GetName(CurItem));
    RenderInformation;
  end
  else
  begin
    UI.Title(_('Выберите предмет, о котором вы хотите узнать больше'), 1, clDarkestRed);

    UI.FromAToZ;
    Items.RenderInventory;
    MsgLog.Render(2, True);

    AddKey('A-Z', _('Show information about item'));
  end;
  AddKey('Esc', _('Close'), True);
end;

procedure TSceneItemInfo.RenderInformation;
var
  ItemType: TItemType;
begin
  ItemType := ItemBase.GetItem(CurItem).ItemType;
  if (ItemType in CoinTypeItems) then
    Self.Add(_('Type'), _('Coins'));
  if (ItemType in TorchTypeItems) then
    Self.Add(_('Type'), _('Light sources'));
  if (ItemType in FoodTypeItems) then
    Self.Add(_('Type'), _('Foods'));
  if (CurItem.Amount > 1) then
    Add(_('Amount'), Format('%dx', [CurItem.Amount]));
end;

procedure TSceneItemInfo.Update(var Key: UInt);
var
  Index: UInt;
begin
  case Key of
    TK_ESCAPE: // Close
      if FShowInfo then
      begin
        FShowInfo := False;
        Self.Render;
      end
      else
        Scenes.GoBack;
    TK_A .. TK_Z: // Info
      if not FShowInfo then
      begin
        Index := Key - TK_A;
        if (Player.IsDead) or (Items.InvCount = 0) or (Index > Items.InvCount - 1) then
          Exit;
        CurItem := Items_Inventory_GetItem(Index);
        FShowInfo := True;
      end
      else
        Game.Timer := UIntMax;
  end;

end;

end.
