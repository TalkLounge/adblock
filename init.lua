-- mods/adblock/init.lua
-- =================
-- See README.txt for licensing and other information.

local lastpos = {}
local adusers = {}
local timer = 0

local form = "size[4.1,3.9]" ..
						 "label[0.65,0;YOU PLAY AN UNOFFICIAL GAME]" ..
						 "label[0,1;On this server is only the official game allowed: Minetest]" ..
						 "label[0.35,1.5;MINETEST is FREE & has NO INGAME ADS]" ..
						 "label[0.55,2;If you dont want this message again then:]" ..
						 "label[0.85,2.5;DOWNLOAD MINETEST NOW]"

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 1 then
		timer = 0
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local pos = player:getpos()
			if adusers[name] and adusers[name] == -1 then
				minetest.show_formspec(name, "adblock:main",
					form ..
					"button[1.35,3.5;1.2,0.1;adblock_main;Accept]")
			elseif lastpos[name] and (player:get_player_control().up or player:get_player_control().down or player:get_player_control().right or player:get_player_control().left) and vector.equals(lastpos[name], pos) then
				adusers[name] = adusers[name] and adusers[name] + 1 or 1
				if adusers[name] >= 10 then
					minetest.show_formspec(name, "adblock:main",
						form ..
						"button[1.35,3.5;1.2,0.1;adblock_main;Accept]")
					adusers[name] = -1
				end
			else
				adusers[name] = nil
			end
			lastpos[name] = pos
		end
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "adblock:main" or not fields.adblock_main then
    return
  end
	local name = player:get_player_name()
	adusers[name] = nil
	for i = 0, 10 do
		minetest.after(i, function()
				if i ~= 10 then
					minetest.show_formspec(name, "adblock:".. (10 - i),
					form ..
					"label[0.5,3.5;You can close this message in ".. (10 - i) .." seconds]")
				else
					minetest.show_formspec(name, "adblock:0",
						form ..
						"button_exit[1.35,3.5;1.2,0.1;adblock_close;Close]")
				end
		end)
  end
end)

