%% batch_plot_erp_components.m 
% Plots ERP peaks/averages for multiple files and ROIs
% Fill in inputs in first section to run
% Author: Gerardo Parra- Yael Braverman edits

%% inputs
RECALCULATE  = 1;       % 1 = re-process EEG, 0 = use saved data
study        = 'study'; % 'pilot' or 'study'
task         = 'ath';   % 'ath', 'tss', 'tth', 'tss_a'
measure_type = 'peak';  % 'peak' or 'avg'
group        = 'td';   % used for plotting: 'asd', 'spd', or 'td'
save_fig     = 0;       % 1 = save plotted figure, 0 = don't save
save_stat    = 1;       % 1 = save processed data, 0 = don't save
use_abs      = 0;       % 1 = use absolute values for averaging, 0 = normal
addpath(genpath( 'Z:\Groups\SPA\02_Data_Processing\02_Misc_Scripts_Functions\functions'));

% for plotting
srate    = 250;  % sampling rate (hz)
x_label  = 'Tap';
y_label  = 'Amplitude (\muV)';
run_tag = 'seg_.1_100';
x_tick   = 1:10;
% xt_label = {'Index','Middle','Both'};
% xt_label = {'Tone 1','Tone 2','Tone 3','Tone 4','Tone 5'};
xt_label = split(int2str(1:10),'  ');
xtick    = {x_tick,xt_label};  % markers to impose on x axis
fig_size = [300 20 1000 1500];  % [x y width height]

% load preset variables 
batch_info = load_batch_erp_variables_happe_er(study, group, task);
 batch_info = batch_erp_load_params_v5(task,study,'test10_18','pc',run_tag);

%% get data and process ERPs
if RECALCULATE
    % load data directory
    eeg_dir  = dir( [batch_info.path_task filesep 'HAPPE_V3_'                   ...
                  run_tag filesep '*.mat'] );        
    n_files  = size(eeg_dir,1);
    n_rois   = size(batch_info.roi_1020,2);
    polarity = batch_info.peak_polarity;
    
    % create empty structs: ids, ersp/itcs, suppression fractions
    ids  = cell(n_files,1);
    rois = cell(n_rois,1);  
    locs = cell(n_rois,1);
    
    % get segmentation window from batch beapp output file
    load( [batch_info.path_task filesep 'out' strcat('_',run_tag) filesep    ...
          'Run_Report_Variables_and_settings'  strcat('_',run_tag)    ...
          '.mat'], 'grp_proc_info' )
    seg_win = [ grp_proc_info.evt_seg_win_start                    ...
                grp_proc_info.evt_seg_win_end ] * 1000;
    clear grp_proc_info
    
    % calculate component measures
    for i_f=1:n_files
        % load file
        file = eeg_dir(i_f);
        load([file.folder filesep file.name]);
        
        if strcmp(task,'sl')
            if batch_info.flip_avg
                new_eeg = cell(8,1);
                for i_c = 1:8
                    new_eeg{i_c,1} = cat(3,eeg_w{i_c,1},eeg_w{17-i_c});
                end
                eeg_w = new_eeg;
                clear new_eeg
            end
        end
        
        subject    = file.name(1:4);
        ids{i_f,1} = [file.name(1:4) 'p'];
        disp(['Calculating ERPs for participant ' subject])
        
        for i_r=1:n_rois
            n_locs = size(batch_info.peak_time{1,i_r},2);
            locs{i_r} = cell(1,n_locs);

            % get iteration channels
            chan_1020    = batch_info.roi_1020{1,i_r};
            chan_other   = batch_info.roi_other{1,i_r};
            chan_weights = batch_info.roi_weight{1,i_r};
            rois{i_r,1}  = get_chan_str(chan_1020,chan_other);

            for i_l=1:n_locs
                % get ERP component info
                peak_loc  = batch_info.peak_time{1,i_r}(i_l);
                win_size  = batch_info.peak_win_size{1,i_r}(i_l);
                peak_name = batch_info.peak_name{1,i_r}{1,i_l};
                locs{i_r,1}{1,i_l} = peak_name;
                
                % call function to calculate averages
%                 calc_save_erp_comp( eeg_w, subject, peak_loc, win_size, ...
%                                    peak_name, use_abs, chan_1020,      ...
%                                     chan_other, chan_weights, seg_win,  ...
%                                     srate, save_stat,                   ...
%                                     batch_info.stat_folder,             ...
%                                     batch_info.stat_fn, measure_type );
%                                     %YB commented and adjusted inputs to
%                                     be more relevant
batch_info.use_abs = 0;
batch_info.method = 'conds';
calculate_erps( eeg_w, subject, batch_info, i_r, i_l )
                               % calc_save_erp_comp(eeg_w,subject,batch_info,i_r,i_l,use_abs,seg_win,srate,save_stat,measure_type,0)
            end
        end
        clear eeg_w file_proc_info
    end

    % calculate peak differences
  %  calc_save_erp_diffs( batch_info.stat_folder, batch_info.stat_fn,    ...
                      %   measure_type );
end

stat_path = [batch_info.path_task_erp filesep batch_info.stat_fn];
addpath(genpath(stat_path))
load(stat_path)
save(stat_path,'data','ids','rois','locs','polarity');
%save(stat_path,'data','ids','rois','locs','polarity');

%% load and plot averages
disp('Creating plots')
 plot_erp_comps( fig_size,save_fig,batch_info.fig_folder,x_label,xtick,  ...
                 y_label, batch_info.stat_folder, batch_info.stat_fn,    ...
                 measure_type, batch_info.ids_to_incl, group );
 disp('Finished')
% close all
% clear