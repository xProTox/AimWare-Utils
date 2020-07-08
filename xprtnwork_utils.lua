----------------------------------
--	Author: xprtnwork | https://aimware.net/forum/user/225577
----------------------------------

function cycle(current, min, max)
	newValue = current;
	if current <= min then
		aaLBYCycleState = 0;
	elseif current >= max then
		aaLBYCycleState = 1;
	end
	
	newValue = newValue + (aaLBYCycleState == 0 and 1 or -1);
	return newValue;
end

current_ping = 0;
function getPing()
	if entities.FindByClass( "CBasePlayer" )[1] ~= nil then
		current_ping = entities.GetPlayerResources():GetPropInt("m_iPing", client.GetLocalPlayerIndex());
	end
	return current_ping;
end

local current_fps = 0;
function getFPS()
	current_fps = 0.9 * current_fps + (1.0 - 0.9) * globals.AbsoluteFrameTime();
	return math.floor((1.0 / current_fps) + 0.5);
end

function isAlive()
    local_player = entities.GetLocalPlayer();
    if local_player ~= nil then  
        return entities.GetLocalPlayer():IsAlive();
    end
end

function drawOutLine(x, y, width, height, r, g, b, a)
    draw.Color(r, g, b, a);
    draw.Line(x, y, x + width, y);
    draw.Line(x, y, x, y + height);
    draw.Line(x + width, y, x + width, y + height);
    draw.Line(x, y + height, x + width, y + height);
end
function drawRect(x, y, width, height, r, g, b, a)
	draw.Color(r, g, b, a);
    draw.FilledRect(x, y, x + width, y + height);
end

function isHoldingKnife(holding)
	if holding == 59 or holding == 41 or holding == 42
		or holding == 74 or holding == 500 or holding == 503
		or holding == 505 or holding == 506 or holding == 507
		or holding == 508 or holding == 509 or holding == 512
		or holding == 514 or holding == 515 or holding == 516
		or holding == 517 or holding == 518 or holding == 519
		or holding == 520 or holding == 521 or holding == 522
		or holding == 523 or holding == 525 then
		return true;
	else
		return false;
	end
end
