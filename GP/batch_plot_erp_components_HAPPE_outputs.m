%% batch_plot_erp_components.m 
% Plots ERP peaks/averages for multiple files and ROIs
% Fill in inputs in first section to run
% Author: Gerardo Parra

%% inputs
RECALCULATE  = 1;       % 1 = re-process EEG, 0 = use saved data
study        = 'study'; % 'pilot' or 'study'
task         = 'tth';   % 'ath', 'tss', 'tth', 'tss_a'
measure_type = 'peak';  % 'peak' or 'avg'
group        = 'td';   % used for plotting: 'asd', 'spd', or 'td'
save_fig     = 0;       % 1 = save plotted figure, 0 = don't save
save_stat    = 1;       % 1 = save processed data, 0 = don't save
use_abs      = 0;       % 1 = use absolute values for averaging, 0 = normal
ids_to_incl  = 1012:1065;

% for plotting
srate    = 250;  % sampling rate (hz)
x_label  = 'Tap';
y_label  = 'Amplitude (\muV)';
x_tick   = 1:10;
% xt_label = {'Index','Middle','Both'};
% xt_label = {'Tone 1','Tone 2','Tone 3','Tone 4','Tone 5'};
xt_label = split(int2str(1:10),'  ');
xtick    = {x_tick,xt_label};  % markers to impose on x axis
fig_size = [300 20 1000 1500];  % [x y width height]

% load preset variables 
batch_info = load_batch_erp_variables_eeglab(study, group, task);
% batch_info = load_batch_erp_variables(study, group, task, '5tones');

%% get data and process ERPs
if RECALCULATE
    % load data directory      
    n_files  = length(ids_to_incl);
    n_rois   = size(batch_info.rois,2);
    polarity = batch_info.polarity;
    
    % create empty structs: ids, ersp/itcs, suppression fractions
    ids  = cell(n_files,1);
    rois = cell(n_rois,1);  
    locs = cell(n_rois,1);
    
    % calculate component measures
    for i_f=1:n_files
        % load file
        subject = int2str(ids_to_incl(i_f));
        ids{i_f,1} = [subject 'p'];
        
        % get all subject's condition files
        subj_dir = dir(fullfile(batch_info.task_folder,[subject '*_D*.set']));
        if isempty(subj_dir)
            continue
        end
        
        % aggregate files
        disp(['Calculating ERPs for participant ' subject])
        n_subj_files = length(subj_dir);
        subj_eegs = cell(1,n_subj_files);
        for i_sf = 1:n_subj_files
            sfile = subj_dir(i_sf);
            subj_eegs{i_sf} = pop_loadset('filename',fullfile(sfile.folder,sfile.name));
        end

        for i_r=1:n_rois
            n_locs = size(batch_info.peak_locs{1,i_r},2);
            locs{i_r} = cell(1,n_locs);

            % get iteration channels
            chans        = batch_info.rois{1,i_r};
            chan_weights = batch_info.roi_weights{1,i_r};
            rois{i_r,1}  = get_chan_str(chans,[]);

            for i_l=1:n_locs
                % get ERP component info
                peak_loc  = batch_info.peak_locs{1,i_r}(i_l);
                win_size  = batch_info.win_sizes{1,i_r}(i_l);
                peak_name = batch_info.peak_names{1,i_r}{1,i_l};
                locs{i_r,1}{1,i_l} = peak_name;
                
                % call function to calculate averages
                calc_save_erp_comp_eeglab( subj_eegs, peak_loc, win_size, ...
                                    peak_name, use_abs, chans,      ...
                                    chan_weights, save_stat, batch_info.stat_folder, ...
                                    batch_info.stat_fn, measure_type );
            end
        end
        clear eeg_w file_proc_info
    end

    % calculate peak differences
    calc_save_erp_diffs( batch_info.stat_folder, batch_info.stat_fn,    ...
                         measure_type );
end

stat_path = [batch_info.stat_folder filesep batch_info.stat_fn];
load(stat_path)
save(stat_path,'data','ids','rois','locs','polarity');

%% load and plot averages
% disp('Creating plots')
% plot_erp_comps( fig_size,save_fig,batch_info.fig_folder,x_label,xtick,  ...
%                 y_label, batch_info.stat_folder, batch_info.stat_fn,    ...
%                 measure_type, batch_info.ids_to_incl, group );
% disp('Finished')
% close all
% clear