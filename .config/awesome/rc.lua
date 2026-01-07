-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local battery_widget = require("widgets.custom.battery")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err)
    })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

naughty.config.defaults['icon_size'] = 100

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
  { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
  { "manual",      terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart",     awesome.restart },
  { "quit",        function() awesome.quit() end },
}

local mymainmenu = awful.menu({
  items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "open terminal", terminal }
  }
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Manage Volume
local current_volume_notif = nil

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget {
  format = "%H:%M  %a %d ",
  widget = wibox.widget.textclock,
  font = "JetBrains Mono 16",
  margin = { 8, 8, 4, 4 }
}
mytextclock = wibox.container.margin(mytextclock, 8, 8, 4, 4) -- padding

local volume_widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = "JetBrains Mono 16"
}

-- Update volume for widget text at startup
local utils = require("utils")
utils.update_volume(false, awful, volume_widget)

local function take_screenshot(fullscreen)
  local screenshotDir = os.getenv("HOME") .. "/Pictures/Screenshots/"
  awful.spawn.with_shell("mkdir -p " .. screenshotDir)

  local filename = os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
  local filepath = screenshotDir .. filename

  local command = "scrot -e 'xclip -selection clipboard -t image/png -i $f' "
  if not fullscreen then
    command = command .. "-s "
  end

  awful.spawn.easy_async_with_shell(command .. filepath, function(_, _, _, exitcode)
    if exitcode == 0 then
      -- Send notification with thumbnail
      naughty.notify({
        title = "Screenshot Taken",
        text = "Saved to " .. filepath,
        timeout = 2.5,
      })
    else
      naughty.notify({
        title = "Screenshot Failed",
        text = "scrot exited with code " .. exitcode,
        preset = naughty.config.presets.critical,
        timeout = 5,
      })
    end
  end)
end

-- Subscribe to volume updates
awful.spawn.with_line_callback("pactl subscribe", {
  stdout = function(line)
    if line:match("Event 'change' on sink") then
      utils.update_volume(true, awful, volume_widget)
    end
  end
})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end) --,
--Mouse wheel scrolls through tags when over wibar
--awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
--awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({}, 1, function() awful.layout.inc(1) end),
    awful.button({}, 3, function() awful.layout.inc(-1) end),
    awful.button({}, 4, function() awful.layout.inc(1) end),
    awful.button({}, 5, function() awful.layout.inc(-1) end)))

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons
  }

  -- Create a tasklist widget
  --  s.mytasklist = awful.widget.tasklist {
  --    screen  = s,
  --    filter  = awful.widget.tasklist.filter.currenttags,
  --    buttons = tasklist_buttons
  --  }

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", height = 30, screen = s })

  -- Add widgets to the wibox
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist,
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    {             -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      mytextclock,
      wibox.widget.systray(),
      battery_widget
      {
        ac = "AC",
        ac_prefix = " ⚡ ",
        adapter = "BAT0",
        battery_prefix = " ",
        percent_colors = {
          { 25,  "red" },
          { 50,  "orange" },
          { 999, "green" },
        },
        listen = true,
        timeout = 10,
        widget_text = "${AC_BAT}${color_on}${percent}%${color_off} ",
        widget_font = "JetBrains Mono 16",
        tooltip_text = "Battery ${state}${time_est}\nCapacity: ${capacity_percent}%",
        alert_threshold = 5,
        alert_timeout = 10,
        alert_title = "Low battery !",
        alert_text = "${time_est}",
      },
      volume_widget,
      s.mylayoutbox,
    },
  }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
  awful.button({}, 3, function() mymainmenu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

local last_slave_for_tag = {}

client.connect_signal("focus", function(c)
  local t = c.first_tag
  if not t then return end

  local layout = t.layout
  if layout == awful.layout.suit.tile then
    local master = awful.client.getmaster()
    if master and c ~= master then
      last_slave_for_tag[t] = c
    end
  end
end)

-- {{{ Key bindings
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
      take_screenshot(false)
    end,
    { description = "take selective screenshot", group = "layout" }),
  awful.key({ altkey, }, "s",
    function()
      take_screenshot(true)
    end,
    { description = "take screenshot", group = "layout" }),

  awful.key({}, "XF86MonBrightnessDown", function()
      awful.util.spawn("brightnessctl set 5%-")
    end,
    { description = "brightness down", group = "media" }),
  awful.key({}, "XF86MonBrightnessUp", function()
      awful.util.spawn("brightnessctl set 5%+")
    end,
    { description = "brightness up", group = "media" }),

  awful.key({ modkey, "Shift" }, "l", function()
      awful.util.spawn("slock")
    end,
    { description = "lock screen", group = "awesome" }),

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

local clientkeys = gears.table.join(
  awful.key({ modkey, }, "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
    { description = "close", group = "client" }),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
    { description = "toggle floating", group = "client" }),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    { description = "move to master", group = "client" }),
  awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
    { description = "move to screen", group = "client" }),
  awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
    { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey, }, "n",
    function(c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    { description = "(un)maximize", group = "client" }),
  awful.key({ modkey, "Control" }, "m",
    function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end,
    { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Shift" }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end,
    { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

local clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },

  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA",   -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin",  -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer" },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow",   -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = { floating = true }
  },

  -- Add titlebars to normal clients and dialogs
  {
    rule_any = { type = { "normal", "dialog" }
    },
    properties = { titlebars_enabled = true }
  },
  -- Force Opera to open in the second tag
  {
    rule = { class = "Opera" },
    properties = { tag = "2" }
  },
  -- Force Discord to open in the third tag
  {
    rule = { class = "discord" },
    properties = { tag = "3" }
  },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  else
    awful.client.setslave(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c):setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    {   -- Middle
      { -- Title
        align  = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
