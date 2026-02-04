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

% Editable timing parameters only
editable('fix_window','fix_wait','fix_hold','reward','iti', ...
         'max_trials_edit');

fix_window      = 3;      % deg
fix_wait        = 5000;   % ms to acquire
fix_hold        = 500;    % ms to hold during enlarged phase
reward          = 100;    % ms
iti             = 4000;   % ms
max_trials_edit = 500;

% Event codes
BUTTON = 10;
REWARD = 90;
bhv_code(BUTTON,'Button',REWARD,'Reward');

% -------------------------------------------------------------------------
% Scene 1: acquire touch on normal object (TaskObject #1)
% -------------------------------------------------------------------------
fix_acq = SingleTarget(tracker);
fix_acq.Target    = 1;          % normal-size object
fix_acq.Threshold = fix_window;

wth_acq = WaitThenHold(fix_acq);
wth_acq.WaitTime = fix_wait;    % time to find the object
wth_acq.HoldTime = 50;          % minimal contact to count as acquisition

scene_acq = create_scene(wth_acq, 1);   % draw TaskObject #1

% -------------------------------------------------------------------------
% Scene 2: enlarged object (TaskObject #2) with retries allowed
% -------------------------------------------------------------------------
fix_hold2 = SingleTarget(tracker);
fix_hold2.Target    = 2;        % enlarged object
fix_hold2.Threshold = fix_window;

% Use FreeThenHold instead of WaitThenHold here
fth_hold2 = FreeThenHold(fix_hold2);
fth_hold2.WaitTime = fix_wait;  % total time window for attempts in this phase
fth_hold2.HoldTime = fix_hold;  % must hold continuously for this long

scene_hold = create_scene(fth_hold2, 2); % draw TaskObject #2

% -------------------------------------------------------------------------
% Run trial
% -------------------------------------------------------------------------
error_type = 0;
rt_touch   = NaN;

idle(500);

% --- Scene 1: acquire touch on normal object ---
run_scene(scene_acq, BUTTON);
rt_touch = wth_acq.RT;
rt       = rt_touch;

if ~wth_acq.Success
    % no acquisition: treat as no touch / timeout or early break
    if isnan(rt_touch) || rt_touch <= 0
        error_type = 1;   % no response
    else
        error_type = 3;   % break / sloppy early contact
    end
else
    % --- Scene 2: enlarged object with FreeThenHold (retries allowed) ---
    run_scene(scene_hold);  % no event marker needed here

    if ~fth_hold2.Success
        error_type = 3;   % never completed a full fix_hold before WaitTime up
    else
        error_type = 0;   % correct: eventually held through enlarged phase
    end
end

% Reward / error
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
