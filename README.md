This is a custom timer designed for obs studio.
I designed it because this has control over the time so that it doesn't automaticaly start like other browser timers. 
You can easily start/stop the timer and as easily reset the timer with 2 hotkey that can be configured.

How to use it:

Open OBS.

Add a Text (GDI+) source in your scene, name it for example: Timer.

Go to Tools → Scripts → + → add this Lua file.

In script settings, set Text Source Name = Timer, Duration = 900 (15 minutes), and Countdown mode enabled.

Go to Settings → Hotkeys and assign keys for:

Timer Start/Stop

Timer Reset

Now you can start, pause, and reset the timer while streaming/recording.
