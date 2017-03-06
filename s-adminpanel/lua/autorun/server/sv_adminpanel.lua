--[[-----------------------------
	Addon for MTXServ By SlownLS
--------]]-------------------------

util.AddNetworkString( "MessageAdmin" )
util.AddNetworkString( "MessageAdminCheckVersionValidate" )
util.AddNetworkString( "MessageAdminCheckVersionIsNoValidate" )

CurrentVersion = 1.0
url_version = "https://gist.githubusercontent.com/SlownLS/159954764aa8d3795b66bc13b5d988eb/raw/S-AdminPanelVersionCheck"
url_update = "https://github.com/SlownLS/S-AdminPanel"

hook.Add( "PlayerSay", "CommandSlownAdminPanel", function( ply, text, team ) 
	if text == SAdminPanel.AdminPanelCommand then
		ply:ConCommand("OpenAdminPanel")
		return ""
	end

	if text == SAdminPanel.ModeAdminCommand then
		if ply:GetNWBool("Admin") == false then
			if SAdminPanel.Ulx then
				RunConsoleCommand("ulx", "god", "$" .. v:SteamID())
				RunConsoleCommand("ulx", "cloak", "$" .. v:SteamID())
			elseif SAdminPanel.FAdmin then
				RunConsoleCommand("FAdmin", "god", "$" .. v:SteamID())
				RunConsoleCommand("FAdmin", "cloak", "$" .. v:SteamID())
			end

			net.Start( "MessageAdmin" )
			net.Send(ply)

			ply:SetNWBool("Admin", true)

		elseif ply:GetNWBool("Admin") == true then
			if SAdminPanel.Ulx then
				RunConsoleCommand("ulx", "ungod", "$" .. v:SteamID())
				RunConsoleCommand("ulx", "uncloak", "$" .. v:SteamID())
			elseif SAdminPanel.FAdmin then
				RunConsoleCommand("FAdmin", "ungod", "$" .. v:SteamID())
				RunConsoleCommand("FAdmin", "uncloak", "$" .. v:SteamID())
			end

			net.Start( "MessageAdmin" )
			net.Send(ply)

			ply:SetNWBool("Admin", false)
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
end)
