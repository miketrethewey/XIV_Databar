local addon, xb = ...
local _G = _G;
local L = xb.L;

local SpeedModule = xb:NewModule("SpeedModule", 'AceEvent-3.0')
local ticker = nil

function SpeedModule:GetName()
  return "speed";
end

function SpeedModule:OnInitialize()
  self.frame = nil
  self.icon = nil
  self.text = nil
end

function SpeedModule:OnEnable()
  if self.frame == nil then
    self:CreateModuleFrame()
  else
    self:UpdateModuleFrame()
    self.frame:Show()
  end
  ticker = C_Timer.NewTicker(1,function() self:Speed_Update_value() end)
end

function SpeedModule:OnDisable()
  if self.frame then
    self.frame:Hide()
    self.frame = nil
  end
  ticker:Cancel()
end

function SpeedModule:UpdateModuleFrame()
  local relativeAnchorPoint = 'RIGHT'
  local xOffset = xb.db.profile.general.moduleSpacing

  local moduleInfo = {
    -- { "speed", "speedFrame" },
    { "currency", "currencyFrame" },
    { "tradeskill", "tradeskillFrame" },
    { "clock", "clockFrame" },
    { "bar", "bar" }
  }
  local count = 0
  for _ in pairs(moduleInfo) do count = count + 1 end

  local moduleKey = ""
  local lastModuleKey = ""
  local frameName = ""
  local parentFrame = nil

  for i=1,count do
    moduleKey = moduleInfo[i][1]
    frameName = moduleInfo[i][2]
    parentFrame = xb:GetFrame(frameName)
    if (xb.db.profile.modules[lastModuleKey] and xb.db.profile.modules[lastModuleKey].enabled) or parentFrame ~= nil then
      break
    end
    lastModuleKey = moduleKey
  end
  if moduleKey == "bar" then
    relativeAnchorPoint = 'LEFT'
    xOffset = 0
  end

  self.frame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
end

function SpeedModule:CreateModuleFrame()
  self.frame=CreateFrame("BUTTON","speedFrame", xb:GetFrame('bar'))
  xb:RegisterFrame('speedFrame',self.frame)
  self.frame:EnableMouse(true)

  self:UpdateModuleFrame()

  self.icon = self.frame:CreateTexture(nil,"OVERLAY",nil,7)
  self.icon:SetPoint("LEFT")
  -- FIXME: Use a different icon
  self.icon:SetTexture(xb.constants.mediaPath.."datatexts\\sound")
  self.icon:SetVertexColor(xb:GetColor('normal'))

  self.text = self.frame:CreateFontString(nil, "OVERLAY")
  self.text:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
  self.text:SetPoint("RIGHT", self.frame,2,0)
  self.text:SetTextColor(xb:GetColor('inactive'))
  self.text:SetText("Speed")
end

function SpeedModule:GetSpeed()
  local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
  return string.format("%d%%", currentSpeed / BASE_MOVEMENT_SPEED * 100)
end

function SpeedModule:Refresh()
  if not xb.db.profile.modules.speed.enabled then self:Disable(); return; end

  if not self.frame and xb.db.profile.modules.speed.enabled then
    self:Enable()
    return;
  end

  if self.frame then
    self.frame:Hide()
    self:UpdateModuleFrame()
    self.frame:Show()
  end
end

function SpeedModule:Speed_Update_value()
	if self.text and self.frame then
    local speed = self:GetSpeed()
    self.text:SetText(speed)
		self.frame:SetSize(self.text:GetStringWidth()+18, 16)
	end
end

function SpeedModule:GetDefaultOptions()
  return self:GetName(), {
      enabled = false
    }
end

function SpeedModule:GetConfig()
  return {
    name = L['Speed'],
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.speed.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.speed.enabled = val
          if val then
            self:Enable();
          else
            self:Disable();
          end
        end,
        width = "full"
      }
    }
  }
 end
