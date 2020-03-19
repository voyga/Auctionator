  Okay = true,
  Done = true,
  Close = true
}

function Auctionator.Localize.ApplyToFrame(frame)
  if IsOurFrame(frame) then

    local segments = Auctionator.Utilities.ConcatArrays(
      { frame:GetRegions() },
      { frame:GetChildren() },
    )
    for _, child in ipairs(segments) do

      if type(child.GetText) == "function" then
        local ftext = child:GetText();
        local fname = tostring(child:GetName());

        if ftext ~= nil and
           ftext ~= "" and
           not IGNORE_TEXTS[ftext] and
           not Auctionator.Utilities.StringStartsWith(fname, "AuctionatorEntry") then

          if child:GetObjectType() == "Button" then
            local oldWidth = math.floor(child:GetWidth());
            child:SetText (ZT(ftext));
            local newWidth = math.floor(child:GetTextWidth()) + 15;
            if (newWidth > oldWidth) then
              child:SetWidth (newWidth+20);
            end
          else
            child:SetText (ZT(ftext));
          end
        end
      end

      if (child:GetObjectType() ~= "Button") then
        Auctionator.Localize.ApplyToFrame (child);
      end
    end
  end
end

-----------------------------------------

function Auctionator.Localize.ApplyToAll()
  Auctionator.Debug.Message('Auctionator.Localize.ApplyToAll')

  local frame = EnumerateFrames()

  while frame do
    Auctionator.Localize.AppplyToFrame(frame);
    frame = EnumerateFrames( frame )
  end
end

local function IsOurFrame( frame )
  return IsAuctionatorFrameName(frame:GetName()) 
end

local function IsAuctionatorFrameName( frameName )
  return Auctionator.Utilities.StringStartsWith(
    frameName,
    "Auctionator" 
  )
end
