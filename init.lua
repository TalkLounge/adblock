-- mods/adblock/init.lua
-- =================
-- See README.md for licensing and other information.

local timeout_message = tonumber(minetest.settings:get("adblock_timeout_message") or 6)

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
		if adusers[name] and not adusers[name].active and vector.equals(adusers[name].pos, pos) and adusers[name].controlBit == controlBit and (control.up or control.down or control.right or control.left) and not isAttached(name) then
			adusers[name].counter = (adusers[name].counter or 1) + 1
		elseif adusers[name] and adusers[name].counter and adusers[name].counter >= timeout_message then
			if not adusers[name].active or adusers[name].active == true then
				adusers[name].active = true
				minetest.show_formspec(name, "adblock:main", form() .."button[1.35,3.5;1.2,0.1;adblock_main;Accept]")
			else
				if adusers[name].active >= 1 then
					minetest.show_formspec(name, "adblock:main", form() .."label[0.5,3.5;You can close this message in ".. adusers[name].active .." seconds]")
					adusers[name].active = adusers[name].active - 1
				else
					minetest.show_formspec(name, "adblock:main", form() .."button_exit[1.35,3.5;1.2,0.1;adblock_close;Close]")
					adusers[name].active = nil
					adusers[name].counter = nil
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
	local name = player:get_player_name()
  if formname ~= "adblock:main" or not fields.adblock_main or adusers[name].active ~= true then
    return
  end
	minetest.log(string.format("AdBlock: %s seen an ad for %s seconds", name, adusers[name].counter))
	adusers[name].active = timeout_message
end)

minetest.register_on_leaveplayer(function(player)
		adusers[player:get_player_name()] = nil
end)

