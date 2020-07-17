----------------------------------
--	Author: xprtnwork | https://aimware.net/forum/user/225577
----------------------------------
LoadScript("xprtnwork/xprtnwork_utils.lua");
local awMenu							= gui.Reference("Menu");
local xprtnMenu							= gui.XML(file.Read("xprtnwork/xprtnwork_menu.xml"));

----------------------------------
local masterSwitch						= xprtnMenu:Reference("masterSwitch");
----------------------------------
-- Slow Walk
local swRandomize						= xprtnMenu:Reference("sw_random");
local swSpeedMin						= xprtnMenu:Reference("sw_speed_min");
local swSpeedMax						= xprtnMenu:Reference("sw_speed_max");
local swInterval						= xprtnMenu:Reference("sw_random_interval");
local swKey								= xprtnMenu:Reference("sw_key");
----------------------------------
-- Fake Lag
local flKnife							= xprtnMenu:Reference("fl_knife");
local flZeus							= xprtnMenu:Reference("fl_zeus");
local flRevolver						= xprtnMenu:Reference("fl_revolver");
local flScout							= xprtnMenu:Reference("fl_scout");
local flAutoSniper						= xprtnMenu:Reference("fl_asniper");
local flAwp								= xprtnMenu:Reference("fl_awp");
local flSlowWalk						= xprtnMenu:Reference("fl_sw");
----------------------------------
-- Indicator
local infoEnable						= xprtnMenu:Reference("wnd_enable");
local infoLock							= xprtnMenu:Reference("wnd_lock");
local infoBackground 					= xprtnMenu:Reference("wnd_bg");
local infoBackgroundColor 				= infoBackground:Reference("wnd_bg_clr");
local infoOutline 						= xprtnMenu:Reference("wnd_ol");
local infoOutlineColor 					= infoOutline:Reference("wnd_ol_clr");
local infoColoredText 					= xprtnMenu:Reference("wnd_col_txt");
local infoColoredTextColor 				= infoColoredText:Reference("wnd_txt_clr");
local infoTextXPos 						= xprtnMenu:Reference("wnd_txt_x_pos");
local infoFps 							= xprtnMenu:Reference("wnd_items_fps");
local infoPing 							= xprtnMenu:Reference("wnd_items_ping");
local infoSentPackets 					= xprtnMenu:Reference("wnd_items_spackets");
local infoMinDmg 						= xprtnMenu:Reference("wnd_items_mindmg");
----------------------------------
-- Anti Aim
local aaEnable							= xprtnMenu:Reference("aa_enable");
local aaLBYInvertRotation				= xprtnMenu:Reference("aa_flick_rotation_onsent");
local aaFlickInterval					= xprtnMenu:Reference("aa_flick_interval");
local aaLBYMode							= xprtnMenu:Reference("aa_lby_mode");
local aaLBYSetOnBase					= xprtnMenu:Reference("aa_dir_base");
local aaLBYSetOnLeft					= xprtnMenu:Reference("aa_dir_left");
local aaLBYSetOnRight					= xprtnMenu:Reference("aa_dir_right");
local aaLBYMin							= xprtnMenu:Reference("aa_lby_min");
local aaLBYMax							= xprtnMenu:Reference("aa_lby_max");
local aaLBYInterval						= xprtnMenu:Reference("aa_lby_interval");
----------------------------------
-- Min Damage Toggler
local mdEnable							= xprtnMenu:Reference("md_enable");
local mdKeybind							= xprtnMenu:Reference("md_toggle_key");
local mdHeavyPistol						= xprtnMenu:Reference("md_weapon_hpistol");
local mdHeavyPistolMin					= xprtnMenu:Reference("md_mindmg_hpistol");
local mdHeavyPistolMax					= xprtnMenu:Reference("md_maxdmg_hpistol");
local mdScout							= xprtnMenu:Reference("md_weapon_scout");
local mdScoutMin						= xprtnMenu:Reference("md_mindmg_scout");
local mdScoutMax						= xprtnMenu:Reference("md_maxdmg_scout");
local mdAWP								= xprtnMenu:Reference("md_weapon_awp");
local mdAWPMin							= xprtnMenu:Reference("md_mindmg_awp");
local mdAWPMax							= xprtnMenu:Reference("md_maxdmg_awp");
local mdAutoSniper						= xprtnMenu:Reference("md_weapon_asniper");
local mdAutoSniperMin					= xprtnMenu:Reference("md_mindmg_asniper");
local mdAutoSniperMax					= xprtnMenu:Reference("md_maxdmg_asniper");
----------------------------------
-- Quick Peek
local qpEnable					= xprtnMenu:Reference("qp_enable");
local qpKeybind					= xprtnMenu:Reference("qp_key");
----------------------------------
local screenWidth				= 0;
local screenHeight				= 0;
local cmChockeStart				= 0;
local cmIsChocking				= false;
local tickCount					= 0;
local commandNumber				= 0;
----------------------------------
local swLastUpdate				= 0;
local swIsSlowWalking			= false;
local flLastUpdate				= 0;
local text_font					= draw.CreateFont("Tahoma", 18, 1);
local iwIsDragging				= false;
local iwWindowX					= 250;
local iwWindowY					= 250;
local iwWindowWidth				= 200;
local iwWindowHeight			= 30;
local iwWindowHeightOffset		= 20;
local aaLastUpdate				= 0;
local aaLBYOffset				= 0;
local aaLBYCycleState			= 0;
local lbyMode					= 0;
local lbyMin					= 0;
local lbyMax					= 0;
local originalBaseRotation		= 0;
local originalLeftRotation		= 0;
local originalRightRotation		= 0;
local lastFlick					= 0;
local hasFlicked				= false;
local mdState					= false;
----------------------------------


local localPlayer = 0

local qp_active = false
local qp_pos = Vector3(0, 0, 0)
local qp_has_shot = false
local qp_finished = false
local function drawQP() -- Draw Quick Peek
	-- If Keybind is pressed and isQP is false, init new quick peek, if isQP continue old
	if qpKeybind:GetValue() ~= 0 then
		if input.IsButtonDown(qpKeybind:GetValue()) and not qp_finished then
			if not qp_active and input.IsButtonPressed(qpKeybind:GetValue()) then
				qp_pos = localPlayer:GetAbsOrigin()
				qp_active = true
				qp_has_shot = false
				qp_finished = false
			end
			if qp_pos.x ~= nil and not qp_finished and qp_active then
				sX, sY = client.WorldToScreen(qp_pos)
				cX, cY = client.WorldToScreen(localPlayer:GetAbsOrigin())
				if sX == nil then sX = 0 end
				if sY == nil then sY = 0 end
				if sX < 0 then sX = 0 end
				if sY < 0 then sY = 0 end
				if sX >= screenWidth then sX = screenWidth end
				if sY >= screenHeight then sY = screenHeight end
				draw.Color((qp_has_shot and 95 or 155), (qp_has_shot and 155 or 95), 95, 255)
				draw.FilledCircle(sX, sY, 15)
				draw.Color(95, 95, 255, 150)
				draw.FilledCircle(sX, sY, 12)
				draw.Color((qp_has_shot and 95 or 155), (qp_has_shot and 155 or 95), 95, 255)
				draw.Line(sX, sY, cX, cY)
				draw.Line(sX+1, sY, cX, cY)
				draw.Line(sX-1, sY, cX, cY)
			end
		elseif qp_finished then
			qp_active = false
			qp_pos = Vector3(0, 0, 0)
			qp_has_shot = false
			qp_finished = false
		else
			qp_active = false
			qp_pos = Vector3(0, 0, 0)
			qp_has_shot = false
			qp_finished = false
		end
	end
end
local function updateQP(cmd) -- Update Quick Peek
	if qpEnable:GetValue() and qp_active then
		-- if in air, cancel quick peek
		if bit.band(localPlayer:GetPropInt("m_fFlags"), 1) == 0 then
			qp_finished = true
			return
		end
		if qp_has_shot then
			curAngle = EulerAngles()
			curAngle.pitch = engine.GetViewAngles().x
			curAngle.yaw = engine.GetViewAngles().y
			curAngle.roll = engine.GetViewAngles().z
			worldAngle = {vector.Subtract( {qp_pos.x, qp_pos.y, qp_pos.z},  {localPlayer:GetAbsOrigin().x, localPlayer:GetAbsOrigin().y, localPlayer:GetAbsOrigin().z} )}

			moveForward = ((math.sin(math.rad(curAngle.yaw)) * worldAngle[2]) + (math.cos(math.rad(curAngle.yaw)) * worldAngle[1])) * 800
			cmd.forwardmove = moveForward
			moveSide = ((math.cos(math.rad(curAngle.yaw)) * -worldAngle[2]) + (math.sin(math.rad(curAngle.yaw)) * worldAngle[1])) * 800
			cmd.sidemove = moveSide
			
			if vector.Length(worldAngle) <= 10.0 then
				qp_finished = true
			end
		end
	end
end

local function updateSW() -- Update Slow Walk
	if swKey:GetValue() ~= 0 then -- Is Button defined and pressed
		if not input.IsButtonDown(swKey:GetValue()) then
			swIsSlowWalking = false;
			return;
		else
			swIsSlowWalking = true;
		end
	end
	if swLastUpdate + swInterval:GetValue() <= tickCount then -- Update Interval
		swLastUpdate = tickCount;
	else
		return;
	end
	if not swRandomize:GetValue() then -- Set Speed
		gui.SetValue("rbot.accuracy.movement.slowspeed", swSpeedMin:GetValue());
	else
		gui.SetValue("rbot.accuracy.movement.slowspeed", math.random(swSpeedMin:GetValue(), swSpeedMax:GetValue()));
	end
end
----------------------------------


local function updateFL() -- Update Fake Lag
	if flLastUpdate + 10 <= tickCount then -- Update Interval
		flLastUpdate = tickCount;
	else
		return;
	end
	currentWeapon = localPlayer:GetWeaponID();
	if flKnife:GetValue() then -- Disable on Knife
		if isHoldingKnife(currentWeapon) then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	if flZeus:GetValue() then -- Disable on Zeus
		if currentWeapon == 31 then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	if flScout:GetValue() then -- Disable on Scout
		if currentWeapon == 40 then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	if flAutoSniper:GetValue() then -- Disable on Auto Snipfer
		if currentWeapon == 38 or currentWeapon == 11 then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	if flAwp:GetValue() then -- Disable on AWP
		if currentWeapon == 9 then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	if flSlowWalk:GetValue() then -- Disable on Slow Walk
		if swIsSlowWalking then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	if flRevolver:GetValue() then -- Disable on Revolver
		if currentWeapon == 64 then
			gui.SetValue("misc.fakelag.enable", false);
			return;
		end
	end
	gui.SetValue("misc.fakelag.enable", true);
end
----------------------------------

local function drawBorders() -- Draw Borders
	if infoColoredText:GetValue() then draw.Color(infoColoredTextColor:GetValue());
	else draw.Color(155, 155, 155, 190); end
	draw.Text(iwWindowX + (draw.GetTextSize("===================") / 20), iwWindowY + 3, "==================");
	draw.Text(iwWindowX + (draw.GetTextSize("===================") / 20), iwWindowY + iwWindowHeight + iwWindowHeightOffset - 13, "==================");
end

local function GetCurrentWeaponMinDmg()
	-- Get Current Weapon
	if localPlayer ~= nil and localPlayer ~= 0 then
		if isAlive() then
			local curWep = localPlayer:GetWeaponID()
			-- Check if Current Weapon is one of the B1G weps
			if curWep == 11 or curWep == 38 then -- Auto Sniper
				return (mdState == false and mdAutoSniperMin:GetValue() or mdAutoSniperMax:GetValue())
			elseif curWep == 1 or curWep == 64 then -- Revolver / Deagle
				return (mdState == false and mdHeavyPistolMin:GetValue() or mdHeavyPistolMax:GetValue())
			elseif curWep == 40 then -- Scout
				return (mdState == false and mdScoutMin:GetValue() or mdScoutMax:GetValue())
			elseif curWep == 9 then -- AWP
				return (mdState == false and mdAWPMin:GetValue() or mdAWPMax:GetValue())
			else
				return "NORMAL"
			end
		else
			return "NORMAL"
		end
	else
		return "NORMAL"
	end
end

local function drawTextIndicator(type, fps_active, ping_active, cp_active, md_active) -- Draw Indicator Items
	tmp_height_offset = 0;
	item_count = 0;
	indicator_text = "";
	indicator_x_offset = 20 + infoTextXPos:GetValue();
	indicator_y_offset = 20;

	item_count = item_count + (fps_active and 1 or 0) + (ping_active and 1 or 0) + (cp_active and 1 or 0) + (md_active and 1 or 0);
	tmp_height_offset = 20 * item_count;
	iwWindowHeightOffset = tmp_height_offset;

	draw.SetFont(text_font);

	if infoColoredText:GetValue() then draw.Color(infoColoredTextColor:GetValue());
	else draw.Color(155, 155, 155, 190); end

	if type == 0 then -- Draw FPS
		indicator_text = "FPS: " .. getFPS();
	elseif type == 1 then -- Draw Ping
		indicator_text = "Ping: " .. getPing();
		indicator_y_offset = indicator_y_offset + (fps_active == true and 20 or 0);
	elseif type == 2 then -- Draw Chocked Commands
		cp_x = iwWindowX + indicator_x_offset + 60 + 90;
        count_chokedpackets = 0;
        indicator_y_offset = indicator_y_offset + (fps_active and 20 or 0) + (ping_active and 20 or 0);
        if isAlive() and cmIsChocking then count_chokedpackets = tickCount - (cmChockeStart - 1); end
        if infoColoredText:GetValue() then drawRect(iwWindowX + (cp_x < iwWindowX + iwWindowWidth and indicator_x_offset or 47) + 60, iwWindowY + indicator_y_offset, 90, 14, 111, 111, 111, 190);
        else drawRect(iwWindowX + indicator_x_offset + 60, iwWindowY + indicator_y_offset, 90, 14, 155, 155, 155, 190); end
		
		drawRect(iwWindowX + (cp_x < iwWindowX + iwWindowWidth and indicator_x_offset or 47) + 60, iwWindowY + indicator_y_offset, (90 / (commandNumber - tickCount)) * (commandNumber - tickCount) - count_chokedpackets, 14, infoColoredTextColor:GetValue())

		if infoColoredText:GetValue() then draw.Color(infoColoredTextColor:GetValue());
		else draw.Color(155, 155, 155, 190); end
		indicator_text = "Packets: " .. count_chokedpackets;
		
		-- if cp_x is greater then iwWindowX + iwWindowWidth
		if cp_x < iwWindowX + iwWindowWidth then
			draw.Text(iwWindowX + indicator_x_offset, iwWindowY + indicator_y_offset, indicator_text);
		else
			draw.Text(iwWindowX + 47, iwWindowY + indicator_y_offset, indicator_text);
		end
		return
	elseif type == 3 then -- Draw Min Damage
		currentMinDmg = GetCurrentWeaponMinDmg();
		indicator_text = "Min-Dmg: " .. currentMinDmg;
		indicator_y_offset = indicator_y_offset + (fps_active and 20 or 0) + (ping_active and 20 or 0) + (cp_active and 20 or 0);
	end

	draw.Text(iwWindowX + indicator_x_offset, iwWindowY + indicator_y_offset, indicator_text);
end
local function updateIW() -- Update Indicator Window
	if not infoEnable:GetValue() then -- Enable Indicator
		return;
	end
	if input.IsButtonDown(1) and not infoLock:GetValue() then -- Window Lock & Drag
		mouseX, mouseY = input.GetMousePos();
		inWindow = false;
		if mouseX > iwWindowX and mouseX < iwWindowX + iwWindowWidth then inWindow = true; else inWindow = false; end
		if inWindow and mouseY > iwWindowY and mouseY < iwWindowY + iwWindowHeight + iwWindowHeightOffset then inWindow = true; else inWindow = false; end
		if inWindow or iwIsDragging then
			iwIsDragging = true;
			iwWindowX = math.floor(mouseX - iwWindowWidth / 2);
			iwWindowY = math.floor(mouseY - iwWindowHeight + iwWindowHeightOffset / 2);
		end
	else
		iwIsDragging = false;
	end
	if infoOutline:GetValue() then -- Draw Outline
		drawOutLine(iwWindowX, iwWindowY, iwWindowWidth + 1, iwWindowHeight + iwWindowHeightOffset + 1, infoOutlineColor:GetValue());
	end
	if infoBackground:GetValue() then -- Draw Background Rect
		drawRect(iwWindowX, iwWindowY, iwWindowWidth, iwWindowHeight + iwWindowHeightOffset, infoBackgroundColor:GetValue());
	end
	drawBorders(); -- Draw Borders
	if infoFps:GetValue() then -- Draw FPS
		drawTextIndicator(0, true, infoPing:GetValue(), infoSentPackets:GetValue(), infoMinDmg:GetValue());
	end
	if infoPing:GetValue() then -- Draw Ping
		drawTextIndicator(1, infoFps:GetValue(), true, infoSentPackets:GetValue(), infoMinDmg:GetValue());
	end
	if infoSentPackets:GetValue() then -- Draw Sent Packets
		drawTextIndicator(2, infoFps:GetValue(), infoPing:GetValue(), true, infoMinDmg:GetValue());
	end
	if infoMinDmg:GetValue() then -- Draw Min Damage Info
		drawTextIndicator(3, infoFps:GetValue(), infoPing:GetValue(), infoSentPackets:GetValue(), true)
	end
end
----------------------------------

local function updateAA()
	if not aaEnable:GetValue() then -- Enable LBY Changer
		return;
	end
	lbyInterval = aaLBYInterval:GetValue();
	if aaLastUpdate + lbyInterval <= tickCount then -- LBY Update Interval
		aaLastUpdate = tickCount;
	else
		return;
	end
	
	lbyMode = aaLBYMode:GetValue();
	lbyMin = aaLBYMin:GetValue();
	lbyMax = aaLBYMax:GetValue();
	
	lbyBaseCurrent = gui.GetValue("rbot.antiaim.base.lby");
	if lbyMode == 0 then -- Modes | Jitter
		aaLBYOffset = math.random(lbyMin, lbyMax);
	elseif lbyMode == 1 then -- Modes | Cycle
		if aaLBYCycleState == 0 then
			aaLBYOffset = cycle(lbyBaseCurrent,lbyMin,lbyMax);
		elseif aaLBYCycleState == 1 then
			aaLBYOffset = cycle(lbyBaseCurrent,lbyMin,lbyMax);
		end
	else -- Modes | Switch
		if lbyBaseCurrent == lbyMin then
			aaLBYOffset = lbyMax;
		else
			aaLBYOffset = lbyMin;
		end
	end
	if aaLBYSetOnBase:GetValue() then -- Update Base LBY
		gui.SetValue("rbot.antiaim.base.lby", aaLBYOffset);
	end
	if aaLBYSetOnLeft:GetValue() then -- Update Left LBY
		gui.SetValue("rbot.antiaim.left.lby", aaLBYOffset);
	end
	if aaLBYSetOnRight:GetValue() then -- Update Right LBY
		gui.SetValue("rbot.antiaim.right.lby", aaLBYOffset);
	end
end
----------------------------------

local function updateMinDamage()
	if mdEnable:GetValue() then
		if mdKeybind:GetValue() > 0 then
			if input.IsButtonPressed(mdKeybind:GetValue()) then
				if not mdState then
					mdState = true;
				else
					mdState = false;
				end
			end
		end

		if mdHeavyPistol:GetValue() then
			hpMinDmg = mdHeavyPistolMin:GetValue();
			hpMaxDmg = mdHeavyPistolMax:GetValue();
			if not mdState then -- Normal/Max Damage
				gui.SetValue("rbot.accuracy.weapon.hpistol.mindmg", hpMinDmg);
			else -- Min Damage
				gui.SetValue("rbot.accuracy.weapon.hpistol.mindmg", hpMaxDmg);
			end
		end
		if mdScout:GetValue() then
			sMinDmg = mdScoutMin:GetValue();
			sMaxDmg = mdScoutMax:GetValue();
			if not mdState then -- Normal/Max Damage
				gui.SetValue("rbot.accuracy.weapon.scout.mindmg", sMinDmg);
			else -- Min Damage
				gui.SetValue("rbot.accuracy.weapon.scout.mindmg", sMaxDmg);
			end
		end
		if mdAWP:GetValue() then
			awpMinDmg = mdAWPMin:GetValue();
			awpMaxDmg = mdAWPMax:GetValue();
			if not mdState then -- Normal/Max Damage
				gui.SetValue("rbot.accuracy.weapon.sniper.mindmg", awpMinDmg);
			else -- Min Damage
				gui.SetValue("rbot.accuracy.weapon.sniper.mindmg", awpMaxDmg);
			end
		end
		if mdAutoSniper:GetValue() then
			asniperMinDmg = mdAutoSniperMin:GetValue();
			asniperMaxDmg = mdAutoSniperMax:GetValue();
			if not mdState then -- Normal/Max Damage
				gui.SetValue("rbot.accuracy.weapon.asniper.mindmg", asniperMinDmg);
			else -- Min Damage
				gui.SetValue("rbot.accuracy.weapon.asniper.mindmg", asniperMaxDmg);
			end
		end
	end
end
----------------------------------

local awMenuIsOpen = false;
local function dPulse()
	screenWidth, screenHeight = draw.GetScreenSize();

	awMenuIsOpen = awMenu:IsActive(); -- AW Menu Active State
	
	if awMenuIsOpen then
		xprtnMenu:SetInvisible(false); -- Show Menu
	else
		xprtnMenu:SetInvisible(true); -- Hide Menu
	end
	
	if not masterSwitch:GetValue() then
		return
	end
		
	drawQP()
	updateIW()
	updateMinDamage()
end
----------------------------------
local function cmPulse(cmd)
	if not masterSwitch:GetValue() then
		return
	end
	localPlayer = entities.GetLocalPlayer()
	updateQP(cmd)
	updateAA()
	if hasFlicked then
		hasFlicked = false
		if aaLBYSetOnBase:GetValue() then -- Update Base LBY
			originalBaseRotation = gui.GetValue("rbot.antiaim.base.rotation")
			gui.SetValue("rbot.antiaim.base.rotation", originalBaseRotation)
		end
		if aaLBYSetOnLeft:GetValue() then -- Update Left LBY
			originalLeftRotation = gui.GetValue("rbot.antiaim.left.rotation")
			gui.SetValue("rbot.antiaim.left.rotation", originalLeftRotation)
		end
		if aaLBYSetOnRight:GetValue() then -- Update Right LBY
			originalRightRotation = gui.GetValue("rbot.antiaim.right.rotation")
			gui.SetValue("rbot.antiaim.right.rotation", originalRightRotation)
		end
	end
	tickCount = cmd.tick_count;
	commandNumber = cmd.command_number;
	if cmd.sendpacket and lastFlick + aaFlickInterval:GetValue() <= tickCount then
		if aaEnable:GetValue() and aaLBYInvertRotation:GetValue() then
			if aaLBYSetOnBase:GetValue() then -- Update Base LBY
				originalBaseRotation = gui.GetValue("rbot.antiaim.base.rotation");
				gui.SetValue("rbot.antiaim.base.rotation", (originalBaseRotation < 0 and math.abs(originalBaseRotation) or -1*originalBaseRotation));
			end
			if aaLBYSetOnLeft:GetValue() then -- Update Left LBY
				originalLeftRotation = gui.GetValue("rbot.antiaim.left.rotation");
				gui.SetValue("rbot.antiaim.left.rotation", (originalLeftRotation < 0 and math.abs(originalLeftRotation) or -1*originalLeftRotation));
			end
			if aaLBYSetOnRight:GetValue() then -- Update Right LBY
				originalRightRotation = gui.GetValue("rbot.antiaim.right.rotation");
				gui.SetValue("rbot.antiaim.right.rotation", (originalRightRotation < 0 and math.abs(originalRightRotation) or -1*originalRightRotation));
			end
			hasFlicked = true;
			lastFlick = tickCount;
		end
		cmIsChocking = false;
		cmChockeStart = 0;
	else -- Chocking
		if not cmIsChocking then
			cmIsChocking = true;
			cmChockeStart = tickCount;
		end
	end

	updateSW()
	updateFL()
end
----------------------------------

callbacks.Register('Draw', dPulse);
callbacks.Register('CreateMove', cmPulse);

callbacks.Register( "FireGameEvent", function(Event)
	if qpEnable:GetValue() then
        local_index = client.GetLocalPlayerIndex();
        victim_index = client.GetPlayerIndexByUserID( Event:GetInt( "userid" ) );
        attacker_index = client.GetPlayerIndexByUserID( Event:GetInt( "attacker" ) );

        if ( victim_index == local_index and attacker_index ~= local_index ) then
            qp_has_shot = true
        end
	end
end)
