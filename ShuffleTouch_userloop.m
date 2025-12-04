function [C,timingfile,userdefined_trialholder] = ShuffleTouch_userloop(~, TrialRecord)

% 1) Default outputs
C = [];
timingfile = 'ShuffleTouch.m';         % timing file for EVERY trial
userdefined_trialholder = '';  % always empty for normal tasks [web:7]

% 2) Optional: stop after N trials
max_trials = 20;              % or whatever you want
if TrialRecord.CurrentTrialNumber >= max_trials
    TrialRecord.NextBlock = -1; % tell ML to stop after this userloop call [web:7][web:91]
    return
end

% 3) Define possible banana positions (in degrees)
button_locs = [ ...
     0    0;   % center-low
     7    7;   % right-middle
    -7    7;   % left-middle
     7   -7;   % right-lower
    -7   -7];  % left-lower

idx = randi(size(button_locs,1));    % random row index
this_loc = button_locs(idx,:);       % 1×2 [x y]

% 4) Save for analysis if you like
TrialRecord.User.button_loc = this_loc;   % custom field for this trial [web:81]

% 5) Build TaskObjects for this trial
% One object only: banana image as touch button
C = { sprintf('pic(banana,%.f,%.f,300,300)', this_loc(1), this_loc(2)) };
%    TaskObject #1 is banana at this_loc

end
