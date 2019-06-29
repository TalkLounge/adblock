-- mods/adblock/init.lua
-- =================
-- See README.md for licensing and other information.

local adusers = {}

local function form()
	return "size[4.1,3.9]" ..
				 "label[0.65,0;YOU PLAY AN UNOFFICIAL GAME]" ..
				 "label[0,1;On this server is only the official game allowed: Minetest]" ..
				 "label[0.35,1.5;MINETEST is FREE & has NO INGAME ADS]" ..
				 "label[0.75,2;If you don't want to see this again:]" ..
				 "label[0.55,2.5;DOWNLOAD & PLAY MINETEST NOW]"
end

local function isAttached(name)
	return (default and default.player_attached and default.player_attached[name]) or (player_api and player_api.player_attached and player_api.player_attached[name])
end

local function adcheck()
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:getpos()
		local control = player:get_player_control()
		local controlBit = player:get_player_control_bits()
		if adusers[name] and vector.equals(adusers[name].pos, pos) and adusers[name].controlBit == controlBit and (control.up or control.down or control.right or control.left) and not isAttached(name) then
			adusers[name].counter = (adusers[name].counter or 1) + 1
			if adusers[name].counter >= 10 then
				adusers[name].active = true
			end
		elseif adusers[name] and adusers[name].active then
			if adusers[name].active == true then
				minetest.show_formspec(name, "adblock:main", form() .."button[1.35,3.5;1.2,0.1;adblock_main;Accept]")
			else
				if adusers[name].active >= 1 then
					minetest.show_formspec(name, "adblock:main", form() .."label[0.5,3.5;You can close this message in ".. adusers[name].active .." seconds]")
				else
					minetest.show_formspec(name, "adblock:main", form() .."button_exit[1.35,3.5;1.2,0.1;adblock_close;Close]")
				end
				adusers[name].active = adusers[name].active - 1
				if adusers[name].active <= -1 then
					adusers[name].active = nil
				end
			end
		elseif adusers[name] then
			adusers[name].counter = nil
		else
			adusers[name] = {}
		end
		adusers[name].pos = pos
		adusers[name].controlBit = controlBit
	end
	return minetest.after(1, adcheck)
end

adcheck()

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "adblock:main" or not fields.adblock_main then
    return
  end
	local name = player:get_player_name()
	minetest.log(string.format("AdBlock: %s seen an ad for %s seconds", name, adusers[name].counter))
	adusers[name].active = 10
	adusers[name].counter = nil
end)

minetest.register_on_leaveplayer(function(player)
		adusers[player:get_player_name()] = nil
end)

