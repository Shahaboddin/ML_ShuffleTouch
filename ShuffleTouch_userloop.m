function [C,timingfile,userdefined_trialholder] = ShuffleTouch_userloop(~, TrialRecord)

% 1) Default outputs
C = [];
timingfile = 'ShuffleTouch.m';
userdefined_trialholder = '';

% 2) Max trials (from timing file if available)
max_trials = 500;
if isfield(TrialRecord,'Editable') && isfield(TrialRecord.Editable,'max_trials_edit')
max_trials = TrialRecord.Editable.max_trials_edit;
end

% 3) Stop after N trials
if TrialRecord.CurrentTrialNumber >= max_trials
TrialRecord.NextBlock = -1;
return;
end

% 4) Define positions (EDIT THESE TO MOVE TARGETS)
cx = 0; cy = -12; % center
rx = 7; ry = -14; % right
lx = -7; ly = -14; % left

all_button_locs = [ ...
cx cy; ...
rx ry; ...
lx ly];

button_locs = all_button_locs;
n_pos = size(button_locs,1);

% 5) Choose position: random, no immediate repeats
if TrialRecord.CurrentTrialNumber == 0
last_idx_global = [];
else
if isfield(TrialRecord.User,'last_idx_global')
last_idx_global = TrialRecord.User.last_idx_global;
else
last_idx_global = [];
end
end

if isempty(last_idx_global)
idx_global = randi(n_pos);
else
candidates = setdiff(1:n_pos, last_idx_global);
if isempty(candidates), candidates = 1:n_pos; end
idx_global = candidates(randi(numel(candidates)));
end

this_loc = button_locs(idx_global,:); % [x y] in deg

% 6) Which images can be used (EDIT THIS LIST)
image_names = { ...
'banana.png' , ...
'apple.png', ...
'orange.png' ...
};
% Example:
% image_names = { 'banana.png', 'apple.png' }; % banana + apple only
% image_names = { 'banana.png' }; % banana only

% 7) Pick a random image for this trial
n_img = numel(image_names);
img_idx = randi(n_img);
this_img = image_names{img_idx};

% 8) Save for analysis (position and index)
TrialRecord.User.button_loc = this_loc;
TrialRecord.User.last_idx_global = idx_global;
TrialRecord.User.all_button_locs = all_button_locs;
TrialRecord.User.image_index = img_idx;

% 9) Build TaskObjects at this_loc:
% #1 = normal size, #2 = enlarged (highlight) version
normal_size = 120; % your current size
highlight_size = round(1.4 * normal_size); % ~1.4× bigger

C = { ...
sprintf('pic(%s,%.1f,%.1f,%d,%d)', this_img, this_loc(1), this_loc(2), normal_size, normal_size), ...
sprintf('pic(%s,%.1f,%.1f,%d,%d)', this_img, this_loc(1), this_loc(2), highlight_size, highlight_size) ...
};
% TaskObject #1 = normal, #2 = enlarged

end
