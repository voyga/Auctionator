AuctionatorFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorFullScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:OnLoad")

  -- Updates to self.state should store in the SAVED_VARIABLE
  self.state = Auctionator.FullScan.State
  self.prices = {}
  self.startTime = nil
end

function AuctionatorFullScanFrameMixin:InitiateScan()
  if self:CanInitiate() then
    self.state.TimeOfLastScan = time()
    self.inProgress = true

    self:RegisterForEvents()
    Auctionator.Utilities.Message("Starting a full scan.")
    C_AuctionHouse.ReplicateItems()
  else
    Auctionator.Utilities.Message(self:NextScanMessage())
  end
end

function AuctionatorFullScanFrameMixin:CanInitiate()
  return
   ( self.state.TimeOfLastScan ~= nil and
     time() - self.state.TimeOfLastScan > 60 * 15 and
     not self.inProgress
   ) or self.state.TimeOfLastScan == nil
end

function AuctionatorFullScanFrameMixin:NextScanMessage()
  local timeSinceLastScan = time() - self.state.TimeOfLastScan
  local minutesUntilNextScan = 15 - math.floor(timeSinceLastScan / 60) - 1
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return
    "A full scan may be started in " ..
    minutesUntilNextScan ..
    " minutes and " ..
    secondsUntilNextScan ..
    " seconds."
end

function AuctionatorFullScanFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionatorFullScanFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionatorFullScanFrameMixin:OnEvent(event, ...)
  if event == "REPLICATE_ITEM_LIST_UPDATE" then
    Auctionator.Debug.Message("REPLICATE_ITEM_LIST_UPDATE")

    FrameUtil.UnregisterFrameForEvents(self, { "REPLICATE_ITEM_LIST_UPDATE" })
    self:BeginProcessing()
  elseif event =="AUCTION_HOUSE_CLOSED" then
    self:UnregisterForEvents()

    if self.inProgress then
      self.inProgress = false
      self.prices = {}

      Auctionator.Utilities.Message(
        "Full scan failed to complete. " ..
        self:NextScanMessage()
      )
    end
  end
end

local function GetReplicateInfo(index)
  local replicateItemInfo = { C_AuctionHouse.GetReplicateItemInfo(index) }

  local count = replicateItemInfo[3]
  local buyoutPrice = replicateItemInfo[10]
  local effectivePrice = buyoutPrice / count

  local itemKey = Auctionator.Utilities.ItemKeyFromReplicateResult(replicateItemInfo)

  return itemKey, effectivePrice
end

function AuctionatorFullScanFrameMixin:BeginProcessing()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:BeginProcessing()")

  self.processingComplete = false

  self.startTime = debugprofilestop()
  self:ProcessBatch(0, 2000, C_AuctionHouse.GetNumReplicateItems())
end

function AuctionatorFullScanFrameMixin:EndProcessing()
  Auctionator.Debug.Message("BeginProcessing() completed in " .. tostring(debugprofilestop() - self.startTime))

  local count = Auctionator.Database.ProcessScan(self.prices)
  Auctionator.Utilities.Message("Finished processing " .. count .. " items.")

  self.processingComplete = true
  self.inProgress = false
  self.startTime = nil
  self.prices = {}

  self:UnregisterForEvents()
end

function AuctionatorFullScanFrameMixin:ProcessBatch(startIndex, stepSize, totalCount)
  if not self.inProgress then
    Auctionator.Utilities.Message("Stopped processing at " .. startIndex .. " out of " .. totalCount .. ".")
    self:EndProcessing()
    return
  end

  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:ProcessBatch()", startIndex, stepSize, totalCount)

  local index = startIndex
  local itemKey, effectivePrice

  while index < startIndex + stepSize and index < totalCount do
    itemKey, effectivePrice = GetReplicateInfo(index)

    if itemKey~=nil then
      if self.prices[itemKey] == nil then
        self.prices[itemKey] = { effectivePrice }
      else
        table.insert(self.prices[itemKey], effectivePrice)
      end
    end

    index = index + 1
  end

  if index < totalCount then
    C_Timer.After(0.2, function()
      self:ProcessBatch(index, stepSize, totalCount)
    end)
  else
    self:EndProcessing()
  end
end
