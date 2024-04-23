module("ddterra.brushes",package.seeall)
ContextPanel = ContextPanel
local tool

local function EnsureMenu()
	if IsValid(ContextPanel) then return end
	print("Creating Panel")
	ContextPanel = vgui.Create("ddterra.brushmenu")
end

//hook.Add("InitPostEntity","ddterra.createmenu",EnsureMenu)

concommand.Add("ddterra.reloadcontextmenu",function()
	if IsValid(ContextPanel) then
		ContextPanel:Remove()
	end

	EnsureMenu()
end)

function ToggleMenu()
	if IsValid(ContextPanel) and ContextPanel:IsVisible() then
		ContextPanel:Close()
	else
		EnsureMenu()
		ContextPanel:Open()
	end
end

function SetMenuBrush(brush)
	EnsureMenu()
	ContextPanel.CurrentBrush = brush
	ContextPanel:UpdateBrush()
end

function UpdateMenuProperties()
	ContextPanel:UpdateBrush()
end

do
	local PANEL = {
		BrushSettings = {}
	}

	function PANEL:Init()
		//local prop = vgui.Create("DPropertySheet",self,"PropMenu")
		//local contextMenu = g_ContextMenu
		//if IsValid(contextMenu) then
		//	self:SetParent(contextMenu)
		//end
		local h = ScrH()
		self:Close()
		self:SetSize(h*.7,h*.8)
		self:Center()
		do
			local propPanel = vgui.Create("DPanel",self)
			propPanel:Dock(RIGHT)
			propPanel:SetSize(h*.2,0)
			propPanel:SetKeyboardInputEnabled(true)
			propPanel:SetMouseInputEnabled(true)
			local commit = vgui.Create("DButton",propPanel)
			commit:Dock(TOP)
			commit:SetText("Commit")
			commit.OnMousePressed = function(s)
				self:CommitSettings()
			end
			local proprties = vgui.Create("DProperties",propPanel)
			proprties:Dock(FILL)
			self.PropPanel = proprties
		end

		local scroll = vgui.Create("DScrollPanel", self)
		scroll:Dock(FILL)
		local entrySize = ScrH()*.15
		local layout = vgui.Create("DTileLayout", scroll)
		layout:SetBaseSize(entrySize+2)
		layout:Dock(FILL)

		layout:SetPaintBackground(true)
		layout:SetBackgroundColor(Color(0, 0, 0,32))

		layout:MakeDroppable("unique_name")

		local buttonCallback = function(slf)
			ddterra.RequestBrushChange(slf.brush)
		end

		for k,v in pairs(Brushes) do
			local button = vgui.Create("DButton",self)
			button:SetText(v.Name or v.ClassName)
			button:SetSize(entrySize,entrySize)
			button.brush = v.ClassName
			button.OnMousePressed = buttonCallback
			layout:Add(button)
		end

		//local layout = vgui.Create("DTileLayout", self)
		//layout:SetBaseSize(32)
		//layout:Dock(FILL)

		////Draw a background so we can see what it's doing
		//layout:SetPaintBackground(true)
		//layout:SetBackgroundColor(Color(0, 100, 100))

		//for k,v in ipairs(Brushes) do
		//	local button = vgui.Create("DButton")
		//	button:SetText(v.Name)
		//	button.brush = v
		//	layout:Add(button)
		//end
	end

	function PANEL:UpdateBrush()
		local brush = self.CurrentBrush
		local props = self.PropPanel
		local meta = getmetatable(brush)
		props:Clear()
		print("Updating Properties")
		for _, prop in ipairs(meta.Properties) do
			local propname = prop[1]
			local setting = props:CreateRow( "Brush Settings", propname )
			setting:Setup( "Int" , prop)
			setting:SetValue(brush[propname] or prop[3])
			setting.DataChanged = function( s, val )
				self.BrushSettings[propname] = val
			end
		end
	end

	function PANEL:CommitSettings()
		ddterra.RequestBrushSettingsChange(self.BrushSettings)
	end

	function PANEL:Open()
		if self:IsVisible() then return end
		self:MakePopup()
		self:SetVisible(true)
		self:SetKeyboardInputEnabled(true)
		self:SetMouseInputEnabled(true)
		self:InvalidateLayout(true)
	end

	function PANEL:Close()
		self:SetKeyboardInputEnabled(false)
		self:SetMouseInputEnabled(false)
		self:SetVisible(false)
		//self:CommitSettings()
	end

	vgui.Register("ddterra.brushmenu",PANEL,"DFrame")
end