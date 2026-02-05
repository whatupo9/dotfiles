local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local globalkeys = gears.table.join(
  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
  awful.key({ modkey, }, "Escape", awful.tag.history.restore,
    { description = "go back", group = "tag" }),
  awful.key({ modkey, }, "w", function() mymainmenu:show() end,
    { description = "show main menu", group = "awesome" }),

  -- Focusing between windows (super + hjkl)
  awful.key({ modkey, }, "j", function()
      awful.client.focus.global_bydirection("down")
    end,
    { description = "focus down", group = "client" }
  ),
  awful.key({ modkey, }, "k", function()
      awful.client.focus.global_bydirection("up")
    end,
    { description = "focus up", group = "client" }
  ),
  awful.key({ modkey, }, "h", function()
      awful.client.focus.global_bydirection("left")
    end,
    { description = "focus left", group = "client" }
  ),
  awful.key({ modkey, }, "l", function()
      local t = awful.screen.focused().selected_tag
      if not t then return end

      local master = awful.client.getmaster()
      if client.focus == master then
        -- Jump back to last slave
        local slave = last_slave_for_tag[t]
        if slave and slave.valid and slave:isvisible() then
          client.focus = slave
          slave:raise()
        else
          awful.client.focus.global_bydirection("right")
        end
      else
        awful.client.focus.global_bydirection("right")
      end
    end,
    { description = "focus right", group = "client" }
  ),

  -- Layout manipulation (super + arrows)
  awful.key({ modkey, }, "Down", function()
      awful.client.swap.global_bydirection("down")
    end,
    { description = "swap with client on the bottom", group = "client" }),
  awful.key({ modkey, }, "Up", function()
      awful.client.swap.global_bydirection("up")
    end,
    { description = "swap with client on the top", group = "client" }),
  awful.key({ modkey, }, "Left", function()
      awful.client.swap.global_bydirection("left")
    end,
    { description = "swap with client on the left", group = "client" }),
  awful.key({ modkey, }, "Right", function()
      awful.client.swap.global_bydirection("right")
    end,
    { description = "swap with client on the right", group = "client" }),

  --  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
  --    { description = "focus the next screen", group = "screen" }),
  --  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
  --    { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),

  -- Standard program
  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", awesome.quit,
    { description = "quit awesome", group = "awesome" }),
  awful.key({ modkey, altkey }, "l", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey, altkey }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift" }, "a", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Shift" }, "r", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
    { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
    { description = "select previous", group = "layout" }),
  awful.key({ modkey, "Shift" }, "s",
    function()
      take_screenshot()
    end,
    { description = "take screenshot", group = "layout" }),

  awful.key({}, "XF86MonBrightnessDown", function()
    awful.util.spawn("brightnessctl set 5%-")
  end),
  awful.key({}, "XF86MonBrightnessUp", function()
    awful.util.spawn("brightnessctl set 5%+")
  end),

  -- Volume controls
  awful.key({}, "XF86AudioRaiseVolume", function()
    local increment = 5

    awful.spawn.easy_async_with_shell(
      [[pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1]],
      function(stdout)
        local volume = tonumber(stdout)

        if not volume then return end

        local new_volume = volume + increment

        if new_volume > 100 then
          awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ 100%")
          return
        end

        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. new_volume .. "%")
      end)
  end, { description = "volume up", group = "media" }),

  awful.key({}, "XF86AudioLowerVolume", function()
    local increment = -5

    awful.spawn.easy_async_with_shell(
      [[pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1]],
      function(stdout)
        local volume = tonumber(stdout)

        if not volume then return end

        local new_volume = volume + increment

        if new_volume < 0 then
          awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ 0%")
          return
        end

        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. new_volume .. "%")
      end)
  end, { description = "volume down", group = "media" }),

  awful.key({}, "XF86AudioMute", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
  end, { description = "toggle mute", group = "media" }),

  awful.key({ modkey, "Control" }, "n",
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", { raise = true }
        )
      end
    end,
    { description = "restore minimized", group = "client" }),

  -- Prompt
  awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
    { description = "run prompt", group = "launcher" }),

  awful.key({ modkey }, "x",
    function()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    { description = "lua execute prompt", group = "awesome" }),

  -- Menubar
  awful.key({ modkey }, "p", function() menubar.show() end,
    { description = "show the menubar", group = "launcher" })
)
