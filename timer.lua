-- Simple controllable timer for OBS
-- Shows a countdown or stopwatch in a text source

obs = obslua

source_name = ""      -- name of your text source
duration = 900        -- default duration in seconds (15 minutes)
current_time = 0
running = false
countdown = true      -- true = countdown, false = stopwatch
hotkey_start_stop = obs.OBS_INVALID_HOTKEY_ID
hotkey_reset = obs.OBS_INVALID_HOTKEY_ID

-----------------------------------
-- Update text source
-----------------------------------
function update_text()
    local text = ""
    local t = current_time
    local hours = math.floor(t / 3600)
    local mins = math.floor((t % 3600) / 60)
    local secs = math.floor(t % 60)
    if hours > 0 then
        text = string.format("%02d:%02d:%02d", hours, mins, secs)
    else
        text = string.format("%02d:%02d", mins, secs)
    end

    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", text)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

-----------------------------------
-- Timer tick
-----------------------------------
function tick()
    if not running then return end
    if countdown then
        current_time = current_time - 1
        if current_time <= 0 then
            current_time = 0
            running = false
        end
    else
        current_time = current_time + 1
    end
    update_text()
end

-----------------------------------
-- Hotkeys
-----------------------------------
function start_stop(pressed)
    if pressed then
        running = not running
    end
end

function reset(pressed)
    if pressed then
        if countdown then
            current_time = duration
        else
            current_time = 0
        end
        update_text()
    end
end

-----------------------------------
-- Script settings
-----------------------------------
function script_description()
    return "A controllable timer for OBS.\n" ..
           "Bind hotkeys in OBS → Settings → Hotkeys to Start/Stop and Reset."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_int(props, "duration", "Duration (seconds)", 1, 86400, 1)
    obs.obs_properties_add_bool(props, "countdown", "Countdown mode")
    obs.obs_properties_add_text(props, "source_name", "Text Source", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_update(settings)
    duration = obs.obs_data_get_int(settings, "duration")
    countdown = obs.obs_data_get_bool(settings, "countdown")
    source_name = obs.obs_data_get_string(settings, "source_name")

    if countdown then
        current_time = duration
    else
        current_time = 0
    end
    update_text()
end

function script_load(settings)
    hotkey_start_stop = obs.obs_hotkey_register_frontend("timer_start_stop", "Timer Start/Stop", start_stop)
    local hotkey_save_array = obs.obs_data_get_array(settings, "timer_start_stop")
    obs.obs_hotkey_load(hotkey_start_stop, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)

    hotkey_reset = obs.obs_hotkey_register_frontend("timer_reset", "Timer Reset", reset)
    local hotkey_save_array2 = obs.obs_data_get_array(settings, "timer_reset")
    obs.obs_hotkey_load(hotkey_reset, hotkey_save_array2)
    obs.obs_data_array_release(hotkey_save_array2)

    obs.timer_add(tick, 1000) -- run every second
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_start_stop)
    obs.obs_data_set_array(settings, "timer_start_stop", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)

    local hotkey_save_array2 = obs.obs_hotkey_save(hotkey_reset)
    obs.obs_data_set_array(settings, "timer_reset", hotkey_save_array2)
    obs.obs_data_array_release(hotkey_save_array2)
end
