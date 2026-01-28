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

% Editable timing parameters only [web:15]
editable('fix_window','fix_wait','fix_hold','reward','iti', ...
         'max_trials_edit');

fix_window      = 4.5;      % deg
fix_wait        = 5000;   % ms
fix_hold        = 50;     % ms
reward          = 150;    % ms
iti             = 2500;   % ms
max_trials_edit = 500;

% Event codes
BUTTON = 10;
REWARD = 90;
bhv_code(BUTTON,'Button',REWARD,'Reward');

% Scene: touch & hold banana (TaskObject #1)
fix1 = SingleTarget(tracker);
fix1.Target    = 1;
fix1.Threshold = fix_window;

wth1 = FreeThenHold(fix1);
wth1.WaitTime = fix_wait;
wth1.HoldTime = fix_hold;

scene1 = create_scene(wth1, 1);

% Run trial
error_type = 0;
rt_touch   = NaN;

idle(500);
run_scene(scene1, BUTTON);

rt_touch = wth1.RT;
rt       = rt_touch;

if wth1.Success
    error_type = 0;
else
    if isnan(rt_touch) || rt_touch <= 0
        error_type = 1;
    else
        error_type = 3;
    end
end

if error_type == 0
    run_scene(sndscene_cor1);
    goodmonkey(reward, 'numreward', 1, 'eventmarker', REWARD);
else
    run_scene(sndscene_err1);
end

idle(iti);

trialerror(error_type);
bhv_variable('button_loc', TrialRecord.User.button_loc);
bhv_variable('touch_rt',   rt_touch);
bhv_variable('reward_ms',  reward);
