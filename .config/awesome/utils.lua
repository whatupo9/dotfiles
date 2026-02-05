local utils = {}

function utils.pad_percent(percent)
  -- Convert number to string with leading zero if < 10
  return string.format("%02d", percent)
end

local volume_muted = false;

function utils.update_volume(notify, awful, volume_widget)
  awful.spawn.easy_async_with_shell(
    [[pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1]],
    function(stdout)
      local volume = tonumber(stdout)
      if volume then
        -- Check mute state after getting volume
        awful.spawn.easy_async_with_shell(
          [[pactl get-sink-mute @DEFAULT_SINK@]],
          function(mute_stdout)
            volume_muted = mute_stdout:match("yes") ~= nil

            local text = utils.pad_percent(volume) .. "%"

            if volume_muted then
              text = "<s>" .. text .. "</s>"
            end
            volume_widget.markup = text .. " "
          end
        )
      end
    end
  )
end

return utils
