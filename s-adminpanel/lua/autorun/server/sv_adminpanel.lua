--[[-----------------------------
	Addon for MTXServ By SlownLS
--------]]-------------------------

util.AddNetworkString( "MessageAdminActivate" )
util.AddNetworkString( "MessageAdminDisable" )
util.AddNetworkString( "MessageAdminCheckVersionValidate" )
util.AddNetworkString( "MessageAdminCheckVersionIsNoValidate" )

CurrentVersion = 1.0
url_version = "https://gist.githubusercontent.com/SlownLS/159954764aa8d3795b66bc13b5d988eb/raw/S-AdminPanelVersionCheck"
url_update = "https://github.com/SlownLS/S-AdminPanel"

hook.Add( "PlayerSay", "CommandSlownAdminPanel", function( ply, text, team ) 
	if text == SAdminPanel.AdminPanelCommand then
		ply:ConCommand("openadminpanel")
		return ""
	end

	if text == SAdminPanel.ModeAdminCommand then
		if ply:GetNWBool("Admin") == false then
			if SAdminPanel.Ulx then
				ply:ConCommand('ulx god '..ply:Nick())
				ply:ConCommand('ulx cloak '..ply:Nick())
			elseif SAdminPanel.FAdmin then
				ply:ConCommand('FAdmin god '..ply:Nick())
				ply:ConCommand('FAdmin cloak '..ply:Nick())
			end

			ply:SetNWBool("Admin", true)

			net.Start( "MessageAdminActivate" )
			net.Send(ply)

		elseif ply:GetNWBool("Admin") == true then
			if SAdminPanel.Ulx then
				ply:ConCommand('ulx ungod '..ply:Nick())
				ply:ConCommand('ulx uncloak '..ply:Nick())
			elseif SAdminPanel.FAdmin then
				ply:ConCommand('FAdmin ungod '..ply:Nick())
				ply:ConCommand('FAdmin uncloak '..ply:Nick())
			end

			ply:SetNWBool("Admin", false)

			net.Start( "MessageAdminDisable" )
			net.Send(ply)
		end

		return ""	
	end
end)

hook.Add( "PlayerInitialSpawn", "CheckVersion", function(ply)
	http.Fetch(url_version, function(body, size, headers, code)
		WebVersion = tonumber(body)
		if ply:IsSuperAdmin() then
			if CurrentVersion != WebVersion then
				timer.Create("CheckVersionValidate",10,1,function()
					net.Start( "MessageAdminCheckVersionIsNoValidate" )
					net.WriteString(url_update)
					net.Send(ply)
				end)
			else 
				timer.Create("CheckVersionValidate",20,1,function()
					net.Start( "MessageAdminCheckVersionValidate" )
					net.Send(ply)
				end)
			end
		end
	end)

	if SAdminPanel.SlownJoindedMessage == true then
		timer.Create("SlownLSJoined",10,1,function()
			if ( ply:SteamID() == "STEAM_0:0:145735803" ) then 
				BroadcastLua([[chat.AddText(Color(230, 92, 78), "[SAdmin] ", color_white, "SlownLS developer joined the server!")]])
			end
		end)
	end
end )

concommand.Add( "SlownAdminPanelCheck", function( ply, cmd, args )
	DarkRP.notify(ply, 0, 5, "Admin Panel Create By SlownLS (STEAM_0:0:145735803)")
end)
