d1 = datetime;
%% USER INPUTS

%________________________________________________________________________________________________________________________________________________________________________
%root_folder =       '/Volumes/lcn-faja/Public/IDEA Study/Anxiety SEED/Participant Data/xProcessedERPFaces/Compiled Outputs/Waveform_csvs/IndividualAverages';
root_folder = 'Z:\Groups\SPA\01_Data_Raw_Summary_Processed\EEG\Participant_Data\03_Processed_Data\06_Auditory_Temporal_Habituation\HAPPE_V3_seg';%ERN/1. Raw Exports/2 yr T3/test';
root_folder =     'Z:\Groups\SPA\01_Data_Raw_Summary_Processed\EEG\Pilot_Data\02_Raw_Data\Aurora_2hz_Arm\segment_pull_matlab_time'
root_folder =     'C:\Users\ch220650\aurora\segment_third_pass_offsets_no_firma_blcorr_detrend';
root_folder = 'Z:\Groups\SPA\01_Data_Raw_Summary_Processed\EEG\Participant_Data\03_Processed_Data\09_Aurora';
folder_suffix = '3_16_23_notch_filt_100msbl_jointprob_notrialalign';
layout_num = 128; %How many channels in the net you want a montage of? All channels besides 128 not currenlty supported
save_fig = 1; %1 or 0: 1 will save the figures in a results folder with the suffix from folder_suffix; 0 will show you the figures but not save them
%%
reseg = 0;

intensities  = {'2','5','10','20','40','50','75'};%'100','130'};
% input information for finding data
%data_path = fullfile( 'Z:','Groups','SPA','01_Data_Raw_Summary_Processed', ...
          %            'EEG','Participant_Data','03_Processed_Data' );
task      = '09_Aurora';%Aurora_2hz_Arm';%06_Auditory_Temporal_Habituation';
beapp_tag   ='_3_16_23_notch_filt_100msbl_jointprob_notrialalign';% '_ERP_filters_notch_no_linenoise_54_taps_nobc';%'_200ms_wins_ERP_filters_arm_notch_no_linenoise_QC_33'; %'_ERP_filters_arm_notch_no_linenoise';%
server_path = fullfile('Z:','Groups','SPA','01_Data_Raw_Summary_Processed','EEG');
data_path   = fullfile(server_path,'Participant_Data','03_Processed_Data');
group_path = fullfile(server_path,'Participant_Data/03_Processed_Data')
fig_path  = fullfile(data_path,task,'figures');

%task        = 'Aurora_2hz_Arm';
% input channel(s) and other parameters to create plot
trial_thresh = 10;
save_fig     = true;  % save figures?
use_happe    = false;  % load data from HAPPE+ER path (vs. segment folder)  
use_median   = false;  % use median (rather than mean) to create plot
norm_data    = true;  % normalize subject data before averaging
% input time range and other parameters for plot format
group_names   = {'TD','ASD'};
% colors        = {[0 0 0],[0.25 0.25 0.25],[0.5 0.5 0.5],[0.75 0.75 0.75]};
% colors        = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250]};
colors        = {[0 0.4470 0.7410],[0.1961 0.6588 0.3216]};
% colors        = flip(colors);
time_range    = [-100 500];  % time range to show on plot
times_to_plot = [-100:50:500];  % times to label on plot
fig_size      = [150 150 800 350];  % [x y width height]
ylims   = [-10 10];
x_label = 'Time (ms)';
y_label = 'Amplitude (\muV)';
%% DO NOT EDIT BELOW __________________________________________________________________________________________________________________________________________________________________
%% Building Relevant Paths/Loading Data

results_path = fullfile(root_folder,sprintf('montages_%s',folder_suffix));
layout_path = ['C:\Users\ch220650\Documents\layout_test\',sprintf('layout_%d.mat',layout_num)];
%% You can uncomment lines 14 and 15 if you are not working on Aquarius, otherwise comment them out

fieldtrip_path = 'C:\Users\ch220650\Documents\fieldtrip-20221208';
addpath(genpath(fieldtrip_path))
%%
addpath(genpath(layout_path))
addpath('Y:\Public\BEAPP_Testing\yb_scripts')
if ~isfolder(results_path)
    mkdir(results_path)
end
addpath(genpath(results_path))
load(layout_path);
D = dir(fullfile(root_folder,'*.mat*')); % getting all subjects from data_path
    %D = dir(fullfile(data_path,task,['resegment_500ms_wins_' beapp_tag],'*.mat'));

%cd ~ ;
%cd(fullfile(data_path,task,['resegment_500ms_wins_' beapp_tag]));
cd(root_folder)
%%
grp_label_path = fullfile(group_path,'01_Subject_Info_for_Processing','Group_Assignments.mat');
gpi_path = ['out' beapp_tag filesep 'Run_Report_Variables_and_Settings' ...
                                     beapp_tag '.mat'];
load([data_path filesep task filesep gpi_path])
%oad([    'C:\Users\ch220650\aurora' filesep gpi_path])
gpi = grp_proc_info;
clear grp_proc_info

% load group information
%load(grp_label_path,'groups')
%ds = setdiff(groups.id,exclude);
%ids = groups.id;
% get segmentation window
seg_win = [gpi.evt_seg_win_start gpi.evt_seg_win_end] * 1000;
seg_win = [-.1 .400]*1000;
n_samples = ceil(1000 * sum(abs(seg_win))/1000);

% generate times for x-axis
times = round(linspace(seg_win(1),seg_win(2),n_samples));
%% Generate Montage for each file

for file = 1:length(D) %get ERP info per conditions
    disp(D(file).name)
    load(D(file).name)
    n_cond = length(eeg_w);
        n_samp = size(eeg_w{1},2);
        subj_mean = zeros(n_cond,n_samp);
        for i_c = 1:n_cond
            for cond = 1:7
          %  load(  fullfile( 'Z:\Groups\SPA\01_Data_Raw_Summary_Processed\EEG\Pilot_Data\02_Raw_Data\Aurora_2hz_Arm\HAPPE_V3_pull_matlab_time',['segs_to_keep',num2str(cond)]))
           % curr_cond_idx = find(targ_cond_logical);
            %fixed_block = curr_cond_idx(1:54);
            %eeg_w{cond,1} = eeg_w{cond,1}(:,:,segs_to_keep(fixed_block));
            legend_lab{cond} = size(eeg_w{cond,1},3);
            end            
            if isempty(eeg_w{i_c})
                continue
            end
       if reseg
eeg_w = cellfun(@(x) reshape(x,size(x,1),size(x,2),size(x,3)*size(x,4)),eeg_w,'UniformOutput',false) ;     
        end
        ERP_data = eeg_w{i_c};
   % times = ERP_data_and_times(1,:);
   % Reshaping data to put trials on 3rd dimension
    num_trials = size(eeg_w{i_c},3);
times_formatted = repmat(times,1,1,num_trials);
ERP_data_formatted = ERP_data; %reshape(ERP_data,[size(ERP_data,1),length(times)/num_trials,num_trials]) ;
%%
    min_time = min(times_formatted(:,:,1));
    max_time = max(times_formatted(:,:,1));
    
    srate = floor(length(times_formatted(:,:,1))/((range(times_formatted(:,:,1))/1000))); %compute sampling rate
    analysis_win_start =  floor(((min_time/1000) .* srate));
    analysis_win_end = floor(((max_time/1000) .* srate));
    frames = length(analysis_win_start:analysis_win_end);
%% Compute time in units of ms from experiment

    ERPtimes_orig = [min_time/1000:(max_time/1000-min_time/1000)/(frames-2):max_time/1000+0.000001]; %results in a 1Xnumber of frames vector of times
    for trial = 1:1;%size(ERP_data_formatted,3)
        %   Plotting Layout of All Channels
        if size(ERP_data_formatted,3)>1
            fname = strcat(D(file).name(1:5),'_trial #',num2str(trial),'_tap ',(intensities{i_c}),'_montage.fig');
        else
            fname = strcat(D(file).name(1:5),'_all_trials','_montage.fig');
        end
        [data] = beapp_stats_2fieldtrip(nanmean(ERP_data_formatted(:,:,:),3),ERPtimes_orig,layout);
        cfg = [];
        cfg.layout = layout;
        cfg.showlabels = 'yes';
        cfg.dataname = fname;
        f= figure('Name',fname,'NumberTitle','off'); %creates figure with filename
        ft_multiplotER(cfg, data);
        %if save_fig ==1
         %   savefig(fullfile(root_folder,fname),f)
      %  end
        %pause() %will wait for user click to progress to next trial figure
    %    close
    end
        end
end