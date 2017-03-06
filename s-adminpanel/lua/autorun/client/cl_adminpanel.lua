--[[-----------------------------
	Addon for MTXServ By SlownLS
--------]]-------------------------

AddCSLuaFile()

AWarn.playerinfo = {} 

local SAdminChatColor = Color(230, 92, 78)

local LocalPlayer = LocalPlayer
local Color = Color
local ScrW = ScrW
local ScrH = ScrH
local concommand = concommand
local draw = draw
local vgui = vgui

surface.CreateFont("SlownAdminPanelFont", {
  font = "Roboto",
  size = 25,
  weight = 1000,
  antialias = true
})

surface.CreateFont("SlownAdminPanelTitleFont", {
  font = "Roboto",
  size = 22,
  weight = 1000,
  antialias = true
})

function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end

function OpenBanPanel()

	local Base = vgui.Create( "DFrame" )
	Base:SetSize( 300, 250 )
	Base:SetTitle( "" )
	Base:Center()
	Base:ShowCloseButton( true )
	Base:SetDraggable( false )
	Base:MakePopup()

	local label = vgui.Create( "DLabel", Base )
	label:SetPos( 60, 25 )
	label:SetSize( Base:GetWide() - 25, 30 )
	label:SetWrap( true )
	label:SetText( "Time of the ban? (0 = permanent)" )
	
	local label2 = vgui.Create( "DLabel", Base )
	label2:SetPos( 100, 25 )
	label2:SetSize( Base:GetWide() - 100, 300 )
	label2:SetWrap( true )
	label2:SetText( "Reason for the ban?" )

	local Text2 = vgui.Create("DTextEntry", Base)
	Text2:SetText("")
	Text2:SetPos( Base:GetWide() / 2 - 100, Base:GetTall() - 60 )
	Text2:SetSize( 200, 20 )

	local Text = vgui.Create("DTextEntry", Base)
	Text:SetText("0")
	Text:SetPos( Base:GetWide() / 2 - 100, Base:GetTall() - 200 )
	Text:SetSize( 200, 20	)
	Text:SetNumeric( true )

	local Send = vgui.Create( "DButton", Base )
	Send:SetSize( 80, 35 )
	Send:SetPos( Base:GetWide() / 2 - 40, Base:GetTall() - 150 )
	Send:SetText( "Send" )
	Send.DoClick = function()
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == ListPlayers:GetLine(ListPlayers:GetSelectedLine()):GetValue(1) then
				if SAdminPanel.Ulx then
					RunConsoleCommand("ulx", "banid", v:SteamID() , Text:GetValue(), Text2:GetValue())
				elseif SAdminPanel.FAdmin then
					RunConsoleCommand("FAdmin", "ban", "$" .. v:SteamID() , Text:GetValue(), Text2:GetValue())
				end
			end
		end
		Base:Close()
	end		
end				

concommand.Add( "OpenAdminPanel", function( ply, cmd, args )
	if table.HasValue( SAdminPanel.GroupAccess, ply:GetNWString( "usergroup" ) ) then
		local Base = vgui.Create("DFrame")
	    Base:SetSize(500, 350)
	    Base:SetPos(ScrW() / 2 - 400, ScrH() / 2 - 225)
	    Base:SetTitle("")
	    Base:ShowCloseButton(false)
	    Base:SetVisible(true)
	    Base:MakePopup()
	    Base:Center()
	    Base.Paint = function(self,w,h)
	        draw.RoundedBox(6, 0, 0, w, h, SAdminPanel.BackgroundColor1)
	        draw.RoundedBox(6, 0, 0, w, h - 5, SAdminPanel.BackgroundColor2)

	        draw.DrawText("SAdmin | Admin Menu", "SlownAdminPanelTitleFont", 5, 3, color_white)
	    end

	    local Close = vgui.Create("DButton", Base)
	    Close:SetSize(40, 15)
	    Close:SetPos(452, 8)
	    Close:SetText("X")
	    Close:SetTooltip("Fermer")
	    Close:SetTextColor(Color(0,0,0,255))
	    Close.Paint = function(self,w,h)
	        draw.RoundedBox(3, 0, 0, w, h, SAdminPanel.Color )
	    end
	    Close.DoClick = function()
	        Base:Close()
	    end

		ListPlayers = vgui.Create( "DListView", Base)
		ListPlayers:SetPos( 5, 30 )
		ListPlayers:SetSize( 490, 310 )
		ListPlayers:SetMultiSelect( false )
		ListPlayers:AddColumn( "Name" )
		ListPlayers:AddColumn( "Job" )
		ListPlayers:AddColumn( "Rank" )
		for k,v in pairs(player.GetAll()) do
			ListPlayers:AddLine(v:Nick(), v:getDarkRPVar("job"), v:GetUserGroup())
		end
		ListPlayers.OnRowSelected = function( PlayerList, line )
			net.Start("awarn_fetchwarnings")
			net.WriteString( tostring(ListPlayers:GetLine(ListPlayers:GetSelectedLine()):GetValue(1) ) ) 
			net.SendToServer()
			AWarn.lastselected = tostring(ListPlayers:GetLine(ListPlayers:GetSelectedLine()):GetValue(1))
		end
		ListPlayers.OnRowRightClick = function( row, line )
			for k,v in pairs(player.GetAll()) do
				if v:Nick() == ListPlayers:GetLine(line):GetValue(1) then
					local func = DermaMenu()
						local Admin = func:AddOption("AdminPage", function() AdminPage() surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/shield.png")
						local CopySteamID = func:AddOption("Copy SteamID", function() SetClipboardText(v:SteamID()) chat.AddText( SAdminChatColor, "[SAdmin] ", color_white,v:Nick().."'s SteamID was copied!") surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/table_edit.png")
						if SAdminPanel.AWarn2  then
							local WarnInfos = func:AddOption("View Warn", function() WarnInfos() surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/exclamation.png")
						end
					func:Open()
				end
			end
		end
	else
		chat.AddText(SAdminChatColor, "[SAdmin] ", color_white, "You do not have access to the admin panel!")
	end
end)

function AdminPage()
	local Base = vgui.Create("DFrame")
    Base:SetSize(500, 350)
    Base:SetPos(ScrW() / 2 - 400, ScrH() / 2 - 225)
    Base:SetTitle("")
    Base:ShowCloseButton(false)
    Base:SetVisible(true)
    Base:MakePopup()
    Base:Center()
    Base.Paint = function(self,w,h)
        draw.RoundedBox(6, 0, 0, w, h, SAdminPanel.BackgroundColor1)
        draw.RoundedBox(6, 0, 0, w, h - 5, SAdminPanel.BackgroundColor2)

        draw.DrawText("SAdmin | Admin Menu", "SlownAdminPanelTitleFont", 5, 3, color_white)
    end

    local Close = vgui.Create("DButton", Base)
    Close:SetSize(40, 15)
    Close:SetPos(452, 8)
    Close:SetText("X")
    Close:SetTooltip("Fermer")
    Close:SetTextColor(Color(0,0,0,255))
    Close.Paint = function(self,w,h)
        draw.RoundedBox(3, 0, 0, w, h, SAdminPanel.Color )
    end
    Close.DoClick = function()
        Base:Close()
    end

	for k,v in pairs(player.GetAll()) do
		if v:Nick() == ListPlayers:GetLine(ListPlayers:GetSelectedLine()):GetValue(1) then
			local Avatar = vgui.Create( "AvatarImage", Base )
			Avatar:SetSize( 128, 128 )
			Avatar:SetPos( 5, 45 )
			Avatar:SetPlayer( v, 96 )

			local Name = vgui.Create("DLabel", Base)
			Name:SetPos(125+15,50)
			Name:SetText("Name: "..v:Nick())
			Name:SetFont("SlownAdminPanelFont")
			Name:SizeToContents()
			Name:SetTooltip("Click to copy "..v:Nick().." to clipboard")
            Name:SetMouseInputEnabled(true)
            function Name:OnMousePressed(mcode)
                self:SetTooltip(v:Nick().." copied to clipboard!")
                ChangeTooltip(self)
                SetClipboardText(v:Nick())
                self:SetTooltip("Click to copy "..v:Nick().." to clipboard")
            end

			local SteamID = vgui.Create("DLabel", Base)
			SteamID:SetPos(125+15,50+30)
			SteamID:SetText("SteamID: "..v:SteamID())
			SteamID:SetFont("SlownAdminPanelFont")
			SteamID:SizeToContents()
			SteamID:SetTooltip("Click to copy "..v:SteamID().." to clipboard")
            SteamID:SetMouseInputEnabled(true)
            function SteamID:OnMousePressed(mcode)
                self:SetTooltip(v:SteamID().." copied to clipboard!")
                ChangeTooltip(self)
                SetClipboardText(v:SteamID())
                self:SetTooltip("Click to copy "..v:SteamID().." to clipboard")
            end

        	local SteamName = vgui.Create("DLabel", Base)
			SteamName:SetPos(125+15,50+60)
			SteamName:SetText("Steam: "..steamworks.GetPlayerName( v:SteamID64() ))
			SteamName:SetFont("SlownAdminPanelFont")
			SteamName:SizeToContents()

			local Money = vgui.Create("DLabel", Base)
			Money:SetPos(125+15,50+90)
			Money:SetText("Money: $"..formatNumber( v:getDarkRPVar("money") ))
			Money:SetFont("SlownAdminPanelFont")
			Money:SizeToContents()


			ListButton = vgui.Create( "DPanelList", Base )
			ListButton:SetPos(5, 180)
			ListButton:SetSize(490, 165)
			ListButton:SetSpacing( 5 )
			ListButton:SetPadding( 6 )
			ListButton:EnableHorizontal( true )
			ListButton:EnableVerticalScrollbar( true )

			local Teleport = vgui.Create("DButton", Base)
		    Teleport:SetSize(465, 45)
		    Teleport:SetPos(5, 180)
		    Teleport:SetText("")
			Teleport.OnCursorEntered = function(self)
				surface.PlaySound("UI/buttonrollover.wav")
				self.hover = true
			end
			Teleport.OnCursorExited = function(self)
				self.hover = false
			end
			Teleport.Paint = function(self, w,h)
				local col = Color(100, 100, 100, 255)
		 
				draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
		 
				if self.hover then
				  col = SAdminPanel.Color 
				  draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				else
				 draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
				end
		 
				draw.DrawText("Teleport", "SlownAdminPanelFont", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)
			end
			Teleport.DoClick = function()
				Base:Remove()

				if SAdminPanel.Ulx then
					RunConsoleCommand("ulx", "teleport", "$" .. v:SteamID())
				elseif SAdminPanel.FAdmin then
					RunConsoleCommand("FAdmin", "teleport", "$" .. v:SteamID())
				end
			end
			ListButton:AddItem( Teleport )

			local Goto = vgui.Create("DButton", Base)
		    Goto:SetSize(465, 45)
		    Goto:SetPos(5, 230)
		    Goto:SetText("")
			Goto.OnCursorEntered = function(self)
				surface.PlaySound("UI/buttonrollover.wav")
				self.hover = true
			end
			Goto.OnCursorExited = function(self)
				self.hover = false
			end
			Goto.Paint = function(self, w,h)
				local col = Color(100, 100, 100, 255)
		 
				draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
		 
				if self.hover then
				  col = SAdminPanel.Color 
				  draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				else
				 draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
				end
		 
				draw.DrawText("Goto", "SlownAdminPanelFont", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)
			end
			Goto.DoClick = function()
				Base:Remove()
				
				if SAdminPanel.Ulx then
					RunConsoleCommand("ulx", "goto", "$" .. v:SteamID())
				elseif SAdminPanel.FAdmin then
					RunConsoleCommand("FAdmin", "goto", "$" .. v:SteamID())
				end
			end
			ListButton:AddItem( Goto )

			local Kick = vgui.Create("DButton", Base)
		    Kick:SetSize(465, 45)
		    Kick:SetPos(5, 230)
		    Kick:SetText("")
			Kick.OnCursorEntered = function(self)
				surface.PlaySound("UI/buttonrollover.wav")
				self.hover = true
			end
			Kick.OnCursorExited = function(self)
				self.hover = false
			end
			Kick.Paint = function(self, w,h)
				local col = Color(100, 100, 100, 255)
		 
				draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
		 
				if self.hover then
				  col = SAdminPanel.Color 
				  draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				else
				 draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
				end
		 
				draw.DrawText("Kick", "SlownAdminPanelFont", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)
			end
			Kick.DoClick = function()
				Base:Remove()
				
				if SAdminPanel.Ulx then
					Derma_StringRequest("Kick", "What is the reason?", "", function(text) RunConsoleCommand("ulx", "kick", "$" .. v:SteamID(), text) end) 
				elseif SAdminPanel.FAdmin then
					Derma_StringRequest("Kick", "What is the reason?", "", function(text) RunConsoleCommand("FAdmin", "kick", "$" .. v:SteamID(), text) end) 
				end
			end
			ListButton:AddItem( Kick )

			local Ban = vgui.Create("DButton", Base)
		    Ban:SetSize(465, 45)
		    Ban:SetPos(5, 230)
		    Ban:SetText("")
			Ban.OnCursorEntered = function(self)
				surface.PlaySound("UI/buttonrollover.wav")
				self.hover = true
			end
			Ban.OnCursorExited = function(self)
				self.hover = false
			end
			Ban.Paint = function(self, w,h)
				local col = Color(100, 100, 100, 255)
		 
				draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
		 
				if self.hover then
				  col = SAdminPanel.Color 
				  draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
				else
				 draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
				end
		 
				draw.DrawText("Ban", "SlownAdminPanelFont", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)
			end
			Ban.DoClick = function()
				Base:Remove()

				OpenBanPanel()
			end
			ListButton:AddItem( Ban )
		end
	end
end

function WarnInfos()
	local Base = vgui.Create("DFrame")
    Base:SetSize(610, 350)
    Base:SetPos(ScrW() / 2 - 400, ScrH() / 2 - 225)
    Base:SetTitle("")
    Base:ShowCloseButton(false)
    Base:SetVisible(true)
    Base:MakePopup()
    Base:Center()
    Base.Paint = function(self,w,h)
        draw.RoundedBox(6, 0, 0, w, h, SAdminPanel.BackgroundColor1)
        draw.RoundedBox(6, 0, 0, w, h - 5, SAdminPanel.BackgroundColor2)

        draw.DrawText("SAdmin | Admin Menu", "SlownAdminPanelTitleFont", 5, 3, color_white)
    end

    local Close = vgui.Create("DButton", Base)
    Close:SetSize(40, 15)
    Close:SetPos(562, 8)
    Close:SetText("X")
    Close:SetTooltip("Fermer")
    Close:SetTextColor(Color(0,0,0,255))
    Close.Paint = function(self,w,h)
        draw.RoundedBox(3, 0, 0, w, h, SAdminPanel.Color )
    end
    Close.DoClick = function()
        Base:Close()
    end

	ListWarn = vgui.Create( "DListView", Base)
	ListWarn:SetPos( 5, 30 )
	ListWarn:SetSize( 600, 310 )
	ListWarn:SetMultiSelect(false)
	ListWarn:AddColumn("ID"):SetFixedWidth( 40 )
	ListWarn:AddColumn("Warning Admin"):SetFixedWidth( 200 )
	ListWarn:AddColumn("Reason")
	ListWarn:AddColumn("Server"):SetFixedWidth( 120 )
	ListWarn:AddColumn("Date/Time"):SetFixedWidth( 120 )
	for k, v in pairs(AWarn.playerinfo) do
		if v.server == "NULL" then v.server = "UNKNOWN" end
		ListWarn:AddLine(v.pid, v.admin, v.reason, v.server, v.date)
	end
	ListWarn.OnRowRightClick = function( PlayerList, line )
		local DropDown = DermaMenu()
		DropDown:AddOption("Delete Warning", function()
			warning = ListWarn:GetLine( line ):GetValue( 1 )
			net.Start("awarn_deletesinglewarn")
			net.WriteInt( warning, 16 )
			net.SendToServer()
			
			ListWarn:Clear()
			net.Start("awarn_fetchwarnings")
			net.WriteString( AWarn.lastselected )
			net.SendToServer()
		end )
		DropDown:AddOption("Copy To Clipboard", function()
			SetClipboardText( ListWarn:GetLine( line ):GetValue( 3 ) )
		end )
		DropDown:Open()
	end
end

net.Receive("MessageAdminCheckVersionIsNoValidate", function(len,ply)

	UrlUpdate = net.ReadString()

	local Base = vgui.Create("DFrame")
    Base:SetSize(500, 90+55)
    Base:SetPos(ScrW() / 2 - 400, ScrH() / 2 - 225)
    Base:SetTitle("")
    Base:ShowCloseButton(false)
    Base:SetVisible(true)
    Base:MakePopup()
    Base:Center()
    Base.Paint = function(self,w,h)
        draw.RoundedBox(6, 0, 0, w, h, SAdminPanel.BackgroundColor1)
        draw.RoundedBox(6, 0, 0, w, h - 5, SAdminPanel.BackgroundColor2)

        draw.DrawText("SAdmin | Admin Menu", "SlownAdminPanelTitleFont", 5, 3, color_white)

        draw.DrawText("Your addon is not up to date!", "SlownAdminPanelTitleFont", 130, 50, color_white)
    end

    local Close = vgui.Create("DButton", Base)
    Close:SetSize(40, 15)
    Close:SetPos(452, 8)
    Close:SetText("X")
    Close:SetTooltip("Fermer")
    Close:SetTextColor(Color(0,0,0,255))
    Close.Paint = function(self, w,h)
        draw.RoundedBox(3, 0, 0, w, h, SAdminPanel.Color )
    end
  	Close.DoClick = function()
        Base:Close()
    end

	local DownloadNewVersion = vgui.Create("DButton", Base)
    DownloadNewVersion:SetSize(490, 45)
    DownloadNewVersion:SetPos(5, 90)
    DownloadNewVersion:SetText("")
	DownloadNewVersion.OnCursorEntered = function(self)
		surface.PlaySound("UI/buttonrollover.wav")
		self.hover = true
	end
	DownloadNewVersion.OnCursorExited = function(self)
		self.hover = false
	end
	DownloadNewVersion.Paint = function(self, w,h)
		local col = Color(100, 100, 100, 255)
 
		draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
		draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
 
		if self.hover then
		  col = SAdminPanel.Color 
		  draw.RoundedBox(6, 0, 0, w, h, Color(36, 39, 44, 255))
		else
		 draw.RoundedBox(6, 0, 0, w, h, Color(26, 29, 34, 255))
		end
 
		draw.DrawText("Click here to download the new version!", "SlownAdminPanelFont", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)
	end
	DownloadNewVersion.DoClick = function()
		gui.OpenURL( UrlUpdate )
	end
end)

net.Receive("MessageAdmin", function(len,ply)
	local ply = LocalPlayer()

	if ply:GetNWBool("Admin") == false then
		chat.AddText(SAdminChatColor, "[SAdmin] ", color_white, "Admin Mod is Activate!")
	elseif ply:GetNWBool("Admin") == true then
		chat.AddText(SAdminChatColor, "[SAdmin] ", color_white, "Admin Mod is Disable!")
	end
end)

net.Receive("MessageAdminCheckVersionValidate", function(len,ply)
	chat.AddText(SAdminChatColor, "[SAdmin] ", color_white, "Your addon is up to date!")
end)
