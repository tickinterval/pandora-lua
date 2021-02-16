ui.add_label("[O] Tickbase controller")
local active = ui.add_checkbox("Enable")

local sv_maxusrcmdprocessticks = cvar.find_var("sv_maxusrcmdprocessticks")

local font = render.create_font("Verdana", 12, 400, font_flags.antialias | font_flags.dropshadow)

local function g_move_handler(cmd)
	if not active:get() then
		return
	end

	if exploits.ready() then
		sv_maxusrcmdprocessticks:set_value_int(18)
	else
		sv_maxusrcmdprocessticks:set_value_int(16)
	end
end

callbacks.register("post_move", g_move_handler)
