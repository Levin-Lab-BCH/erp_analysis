function batch = batch_erp_load_params_v5(task, phase, batch_tag, computer, run_tag)
%% BATCH_ERP_LOAD_PARAMS: loads preset processing information into struct
% Inputs:
%   - task      - char | SPA task to calculate ERPs for
%                 'tth', 'tss', 'sl', 'ath', 'tss_a', 'rl1', or 'rl2'
%   - phase     - char | phase of SPA data to use | 'study' or 'pilot'
%   - batch_tag - char | '' or tag to apaknd to batch filename
%   - computer  - char | 'pc' or 'mac', for filepaths
%   - run_tag   - char | tag for that run of beapp, optional input
% Outputs:
%   - batch - struct containing batch parameters such as:
%       - roi_1020      - cells containing ROIs defined by 10-20 chans 
%       - roi_other     - arrays containing ROIs defined by chan numbers
%       - roi_weight    - arrays containing weights to apply to each ROI
%       - peak_time     - arrays of times in ms with ERP peaks (per ROI)
%       - peak_win_size - arrays of temporal window width in ms for ERP
%       - peak_name     - name to label ERP plots with (per time plotted)
% Author: Gerardo Parra, 2022-07-28
%% check inputs 
if nargin<5
    run_tag = '';
end
%% set data locations
% path on server to general data folder
data_path = fullfile('Groups','SPA','01_Data_Raw_Summary_Processed');
switch computer
    case 'mac', data_path = fullfile('Volumes','neuro-levin',data_path);
    case 'pc',  data_path = fullfile('X:',data_path);
end
% path to folder with EEG data
switch phase
    case 'study'
        eeg_path = fullfile( data_path, 'EEG', 'Participant_Data',      ...
                             '03_Processed_Data' );
    otherwise
        error(['Information not set up for ' phase ' data'])
end
batch.avg_rise_decay = 0;
batch.task_folder = get_task_path(task);

switch task
    case 'ath'
        %% Auditory Temporal Habituation
        % analysis specifications
        % Ceponiene et al. 1998: P100 (98+/-24ms[3SD]), N250 (243+/-36ms)
        % Bruneau et al. 1999: N1c/Tb (160-199ms); Wunderlich et al 2006:
        % P2 (240-355ms)
        batch.beapp_tag = '_HAPPE_V3';
        batch.roi_1020 = { ...
                                     {'Fz'},                            ...
                                     {'T3'},                            ...
                                   };
        batch.roi_other    = {                                          ...
                                     [],                                ...
                                     []                                 ...
                                   };
        batch.roi_weight   = {                                          ...
                                     [],                                ...
                                     []                                 ...
                                   };
        batch.peak_time     = {                                         ...
                                     [98  243], ...% NaN NaN ],                        ...
                                     [180 297]% NaN NaN ]   ,...
                                    
                                   };
        batch.peak_win_size     = {                                     ...
                                     [24  36], ... % NaN NaN ],                         ...
                                     [24  58]% NaN NaN ]     %was 40 58                     ...
                                   };
        batch.peak_name    = {                                          ...
                                     {'P100','N250'},...%,'AutoP','AutoN'},                   ...
                                     {'N1c','P2'}%,'AutoP','AutoN'}                       ...
                                   };
        batch.peak_polarity      = {                                    ...
                                     [1 0], ...% 1 0],                             ...
                                     [0 1]% 1 0]                              ...
                                   };


    case 'sl'
        %% Stepwise Loudness
        % analysis specifications
        % analysis specifications
        % Peak sources: Shafer et al. 2015 (using +/- 3 SD from mean)
        %Peak sources: Fujita et al. 2022 for Fz  (P50):30�80,(N100):80�150, and 200 (P200) 150�280 ms
        batch.avg_rise_decay = 0;
        batch.beapp_tag = '_30hz';
        batch.roi_1020 = { ...
                                     {'Fz'},                            ...
                                     {'P7','P8'},                       ...
                                     {'T7'},                            ...
                                     {'T8'}                             ...
                                   };
        batch.roi_other    = {                                          ...
                                     [],                                ...
                                     [],                                ...
                                     [],                                ...
                                     []                                 ...
                                   };
        batch.roi_weight   = {                                          ...
                                     [],                                ...
                                     [],                                ...
                                     [],                                ...
                                     []                                 ...
                                   };
        batch.peak_time     = {                                         ...
                                     [141 253 324 55 35 215],                     ...
                                     [139 297],                         ...
                                     [139 297],                         ...
                                     [138 297]                          ...
                                   };
        batch.peak_win_size     = {                                     ...
                                     [30  51  75 25 115 65]                    ...
                                     [45  116],                         ...
                                     [45  116],                         ...
                                     [33  116]                          ...
                                   };
        batch.peak_name    = {                                          ...
                                     {'P1','N2','P2', 'P50','N100','P2_ldaep'},                  ...
                                     {'Na','P2'},                       ...
                                     {'Na','P2'},                       ...
                                     {'Na','P2'}                        ...
                                   };
        batch.peak_polarity      = {                                    ...
                                     [1 0 1 1 0 1],                           ...
                                     [0 1],                             ...
                                     [0 1],                             ...
                                     [0 1]                              ...
                                   };
        

    case 'rl1'
        %% Stepwise Loudness
        % analysis specifications
        batch.beapp_tag = '_seg';
        batch.roi_1020 = { ...
                                     {'Fz'},                            ...
                                     {'F4'},                            ...
                                     {'T8'},                            ...
                                     {'T7'}                             ...
                                   };
        batch.roi_other    = {                                          ...
                                     [],                                ...
                                     [],                                ...
                                     [],                                ...
                                     []                                 ...
                                   };
        batch.roi_weight   = {                                          ...
                                     [],                                ...
                                     [],                                ...
                                     [],                                ...
                                     []                                 ...
                                   };
        batch.peak_time     = {                                         ...
                                     [140 240],                         ...
                                     [140 240],                         ...
                                     [65  130 200],                     ...
                                     [65  130 200]                      ...
                                   };
        batch.peak_win_size     = {                                     ...
                                     [25  25 ],                         ...
                                     [25  25 ],                         ...
                                     [25  30  50 ],                     ...
                                     [25  30  50 ]                      ...
                                   };
        batch.peak_name    = {                                          ...
                                     {'P1','N2'},                       ...
                                     {'P1','N2'},                       ...
                                     {'P50','Na','Tb'},                 ...
                                     {'P50','Na','Tb'},                 ...
                                   };
        batch.peak_polarity      = {                                    ...
                                     [1 0],                             ...
                                     [1 0],                             ...
                                     [1 0 1],                           ...
                                     [1 0 1]                            ...
                                   };
     
    
    case 'tth'
        %% Tactile Temporal Habituation
        % analysis specifications
        % Espenhahn et al 2021: P50 (30�55  ms), N80 (55�80 ms), and P100
        % (80�125 ms), N140 (150�210  ms), P300 (270�300  ms)
        batch.beapp_tag     = '_seg';
        batch.roi_1020 =           {                                    ...
                                     {'C3'},                            ...
                                     {'F3'}                             ...     
                                   };
        batch.roi_other    = {                                          ...
                                 [],                                    ...
                                 []                                     ...
                             };
        batch.roi_weight = {                                            ...
                                 [],                                    ...
                                 []                                     ...
                            };
        batch.peak_time = {                                             ...
                             [33  57  95  170 275 1000],                ...
                             [33  57  95  170 275 1000]                 ...
                           };
        batch.peak_win_size     = {                                     ...
                                     [13  13  25  40  25  900],         ...
                                     [13  13  25  40  25  900]          ...
                                   };
        batch.peak_name = {                                             ...
                             {'P50','N80','P100','N140','P300','whole'},...
                             {'P50','N80','P100','N140','P300','whole'} ...
                          };
        batch.peak_polarity = {                                         ...
                                 [1 0 1 0 1 1],                         ...
                                 [1 0 1 0 1 1]                          ...
                               };
     
    
    case 'tss'
        %% Tactile Spatial Suppression
        % analysis specifications inspired by:
        % - Espenhahn et al 2021: P50 (30�55  ms), N80 (55�80 ms), and P100
        %   (80�125 ms), N140 (150�210  ms), P300 (270�300  ms), N190
        %   (150-240 ms), N300 (280-400 ms)
        % chosen windows:
        % - P100 (50-125 ms), N140 (150-210 ms), P300 (225-300 ms), 
        %   P4 (300-425 ms), P190 (140-240 ms), N300 (280-425 ms)
        batch.beapp_tag = '_25hzLP_32hzNF';
        batch.roi_1020  = {                                     ...
                             {'C3','C4'},                       ...
                             {'C3'},                            ...
                             {},                                ...
                             {'Fz'}                             ...
                           };
        batch.roi_other    = {                                      ...
                                 [],                                ...
                                 [],                                ...
                                 [30 36 41],                           ...
                                 []                                 ...
                               };
        batch.roi_weight   = {                                      ...
                                 [1 -1],                            ...
                                 [],                                ...
                                 [],                                ...
                                 []                                 ...
                               };
        batch.peak_time     = {                                     ...
                                 [ 45.0 87.5 180.0 262.5 362.5],    ...
                                 [ 45.0 87.5 180.0 262.5 362.5],    ...
                                 [ 45.0 87.5 180.0 262.5 362.5],    ...
                                 [190.0 352.5]                      ...
                               };
        batch.peak_win_size  = {                                    ...
                                 [ 10.0 37.5  30.0  37.5  62.5],    ...
                                 [ 10.0 37.5  30.0  37.5  62.5],    ...
                                 [ 10.0 37.5  30.0  37.5  62.5],    ...
                                 [ 50.0  72.5]                      ...
                               };
        batch.peak_name = {                                             ...
                             {'P50','P100','N140','P300','P4'},         ...
                             {'P50','P100','N140','P300','P4'},         ...
                             {'P50','P100','N140','P300','P4'},         ...
                             {'P190','N300'}                            ...
                          };
        batch.peak_polarity = {                                         ...
                                 [1 1 0 1 1],                           ...
                                 [1 1 0 1 1],                           ...
                                 [1 1 0 1 1],                           ...
                                 [1 0]                                  ...
                               };
        

    case 'tss_a'
        %% Tactile Spatial Suppression
        % analysis specifications
        % Espenhahn et al 2021: P50 (30�55  ms), N80 (55�80 ms), and P100
        % (80�125 ms), N140 (150�210  ms), P300 (270�300  ms)
        batch.beapp_tag     = '_03_22_23';%happe+er_rereftest';
        batch.roi_1020  = {                                     ...
                             {'C3','C4'},                       ...
                             {'C3'},                            ...
                             {'F3','F4'},                       ...
                             {'F3'}                             ...     
                           };
        batch.roi_other    = {                                      ...
                                 [],                                ...
                                 [],                                ...
                                 [],                                ...
                                 []                                 ...
                               };
        batch.roi_weight   = {                                      ...
                                 [1 -1],                            ...
                                 [],                                ...
                                 [1 -1],                            ...
                                 []                                 ...
                               };
        batch.peak_time     = {                                     ...
                                 [33  57  95  170 275 1000],        ...
                                 [33  57  95  170 275 1000],        ...
                                 [33  57  95  170 275 1000],        ...
                                 [33  57  95  170 275 1000]         ...
                               };
        batch.peak_win_size  = {                                    ...
                                 [13  13  25  40  25  900],         ...
                                 [13  13  25  40  25  900],         ...
                                 [13  13  25  40  25  900],         ...
                                 [13  13  25  40  25  900]          ...
                               };
        batch.peak_name = {                                             ...
                             {'P50','N80','P100','N140','P300','whole'},...
                             {'P50','N80','P100','N140','P300','whole'},...
                             {'P50','N80','P100','N140','P300','whole'},...
                             {'P50','N80','P100','N140','P300','whole'} ...
                          };
        batch.peak_polarity = {                                         ...
                                 [1 0 1 0 1 1],                         ...
                                 [1 0 1 0 1 1],                         ...
                                 [1 0 1 0 1 1],                         ...
                                 [1 0 1 0 1 1]                          ...
                               };

end

%% get and save subject group information
% get group assignments table
grps_path  = fullfile(eeg_path,'01_Subject_Info_For_Processing');
grps_fname = fullfile(grps_path,'Group_Assignments.mat');
load(grps_fname,'groups')
batch.groups.table = groups;

% get ids for each group
group_names = {'TD','ASD','SPC'};
for i_g = 1:3
    group    = group_names{i_g};
    grp_idxs = groups.group == i_g;
    batch.groups.(group).table_idxs  = grp_idxs;
    batch.groups.(group).subject_ids = groups.id(grp_idxs);
    batch.groups.(group).N = 0;
end

%% get and save relevant filepaths
% save data filepaths 
task_path = fullfile(eeg_path,batch.task_folder);
batch.task = task;
batch.path_task = task_path;
batch.path_task_eeg  = fullfile(task_path,['segment' strcat('_',run_tag)]);
batch.path_task_erp  = fullfile(task_path,'erp');
batch.path_task_figs = fullfile(task_path,'figures','erp');

% load beapp group_proc_info, save path, and get batch segmentation window
if nargin <5
    run_tag = batch.beapp_tag;
end
gpi_folder = fullfile(task_path,['out' strcat('_',run_tag)]);
gpi_fname  = ['Run_Report_Variables_and_settings' strcat('_',run_tag) '.mat'];
gpi_path   = fullfile(gpi_folder,gpi_fname);
load(gpi_path,'grp_proc_info'); gpi = grp_proc_info; clear grp_proc_info;
batch.seg_win = [ gpi.evt_seg_win_start gpi.evt_seg_win_end ] * 1000;
batch.path_task_gpi = gpi_path;
batch.srate = gpi.beapp_rsamp_srate;

% get batch time
t = get_date_str();
batch.batch_time = t;

% get batch filename
switch phase
    case 'study'
        % get filename to save batch to
        batch.batch_fname   = ['erp' batch.beapp_tag '_' t '_' batch_tag];
        if strcmp(task,'sl')
            if batch.avg_rise_decay
                batch.batch_fname = [batch.batch_fname '_rise-decay_avg'];
            end
        end
        batch.batch_fname = [batch.batch_fname '.mat'];

    otherwise
        error(['Information not set up for ' phase ' data'])
end

end