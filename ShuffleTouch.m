showcursor('off');
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

tracker = touch_;

% Sounds
snd_cor1 = AudioSound(null_);
snd_err1 = AudioSound(null_);
snd_cor1.List = 'load_waveform({''sin'', .1, 800})';
snd_err1.List = 'load_waveform({''sin'', .2, 200})';
sndscene_cor1 = create_scene(snd_cor1);
sndscene_err1 = create_scene(snd_err1);

% Editable parameters
editable('fix_window','fix_wait','fix_hold','reward','iti');
fix_window = 6;     % acceptance radius (deg) around banana
fix_wait   = 5000;  % ms to start touching
fix_hold   = 50;    % ms to hold
reward     = 150;   % solenoid open (ms)
iti        = 1500;  % ms

% Event codes
BUTTON = 10;
REWARD = 90;
bhv_code(BUTTON,'Button',REWARD,'Reward');

% Scene: touch & hold banana (TaskObject #1)
fix1 = SingleTarget(tracker);    % adapter
fix1.Target    = 1;              % TaskObject #1 is banana
fix1.Threshold = fix_window;     % circular window radius [web:16][web:22]

wth1 = WaitThenHold(fix1);       % adapter
wth1.WaitTime = fix_wait;        % ms to acquire
wth1.HoldTime = fix_hold;        % ms to hold

scene1 = create_scene(wth1, 1);  % draw TaskObject #1 [web:22]

% Run trial
error_type = 0;
rt_touch = NaN;

idle(500);                       % blank

run_scene(scene1, BUTTON);       % show banana, run adapters
rt_touch = wth1.AcquiredTime;    % time to first touch
rt = rt_touch;    % ML uses "rt" for the default reaction time display [web:89]


if ~wth1.Success
    error_type = 3;              % treat as touch break / no touch
end

% Reward / error
if error_type == 0
    run_scene(sndscene_cor1);
    goodmonkey(reward, 'numreward', 1, 'eventmarker', REWARD);
else
    run_scene(sndscene_err1);
end

idle(iti);

% Log
trialerror(error_type);
bhv_variable('button_loc', TrialRecord.User.button_loc);  % [x y]
bhv_variable('touch_rt',   rt_touch);
bhv_variable('reward_ms',  reward);
