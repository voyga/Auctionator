AuctionatorConfigNotLIFOFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigNotLIFOFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigNotLIFOFrameMixin:OnLoad()")

  self.name = self:IndentationForSubSection() .. "Gear/Pets"
  self.parent = "Selling"

  self:SetupPanel()

  self.ItemSalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigNotLIFOFrameMixin:OnShow()
  self.currentItemDuration = Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION)
  self.currentItemSalesPreference = Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_SALES_PREFERENCE)

  self.ItemDurationGroup:SetSelectedValue(self.currentItemDuration)
  self.ItemSalesPreference:SetSelectedValue(self.currentItemSalesPreference)

  self:OnSalesPreferenceChange(self.currentItemSalesPreference)

  self.ItemUndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_UNDERCUT_PERCENTAGE))
  self.ItemUndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_UNDERCUT_STATIC_VALUE))
end

function AuctionatorConfigNotLIFOFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentItemSalesPreference = selectedValue

  if self.currentItemSalesPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.ItemUndercutPercentage:Show()
    self.ItemUndercutValue:Hide()
  else
    self.ItemUndercutValue:Show()
    self.ItemUndercutPercentage:Hide()
  end
end

function AuctionatorConfigNotLIFOFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigNotLIFOFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION, self.ItemDurationGroup:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.NOT_LIFO_AUCTION_SALES_PREFERENCE, self.ItemSalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.NOT_LIFO_UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.ItemUndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.NOT_LIFO_UNDERCUT_STATIC_VALUE, tonumber(self.ItemUndercutValue:GetAmount()))
end

function AuctionatorConfigNotLIFOFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigNotLIFOFrameMixin:Cancel()")
end
