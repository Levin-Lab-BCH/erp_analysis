%% batch_erps_calculate.m
% Calculates and saves ERP peaks/averages for multiple files and ROIs
% Fill in inputs in first section to run
% Author: Yael Braverman
function [path_erp_batch] = batch_erp_calculate_function_yb(phase,task,batch_tag,run_tag,computer,method,eeg_dat)
%% batch inputs
% inputs for loading batch parameters
% phase     = 'study';%'pilot_raw';% 'pilot_raw'; % 'study' or 'pilot_raw
% task      = 'Aurora';% 'aurora_test';   % 'sl', 'ath', 'tss', 'tth', 'tss_a'
% batch_tag = 'yb_100msblcorr_meandet_all'; %'yb_noexclusion_full_200ms_individ_bl'; %'_yb_v6_2';%_yb_replicate_happe+er_2022-08-18_gp_2'; %reseg_blcorr';    % tag for saving batch file
% computer  = 'pc';    % 'pc' or 'mac', for filepaths
% run_tag   = '3_14_23_notch_filt_50msbl';%'seg_.1_100_200msblcorr; %'full_.1_30_noblcorr';%25hzLP_32hzNF';%'seg_.1_30';%run_08_09_22_at_04_14_16';%'full_.1_30_blcorr';%'2hz_test';
% run_tag = '3_14_23_notch_filt_100msbl';
% run_tag = '3_16_23_notch_filt_100msbl_jointprob_meandet';
%run_tag = '3_16_23_notch_filt_100msbl_jointprob_lindet';
% inputs for processing
%method  = 'conds';% 'conds';  % ('conds' or 'trials) + ('_peak' or '_avg')
use_abs = 0;  % 1 = use absolute values for averaging, 0 = normal
trial_thresh = 0; %threshold for trials? 0=no 1= yes
%% get data and information for processing
% load batch processing information
batch = batch_erp_load_params_aurora(task,phase,batch_tag,computer,run_tag);
group_names = {'TD','ASD','SPD'};

%batch = batch_erp_load_params_v7(task,phase,batch_tag,computer);
% batch = batch_erp_load_params_v6(task,phase,batch_tag,computer,run_tag);

batch.method  = method;
batch.use_abs = use_abs;

% get data directory struct
%eeg_dir = dir( fullfile(batch.path_task_eeg,'*.mat') );        
n_files = max(size(eeg_dat));
n_rois  = length(batch.roi_1020);

% create empty structs: ids, rois, erps
ids  = cell(n_files,1);
rois = cell(n_rois,1);  
erps = cell(n_rois,1);

%% iterate through files and calculate erp components
for i_f = 1:n_files
    % load file
    file    = eeg_dat(i_f);
    subject = file.name(1:4);
    ids{i_f,1} = subject;
    subject_group =1;% batch.groups.table.group(find(strcmp(batch.groups.table.id,subject)));
   % batch.groups.(group_names{subject_group}).N = batch.groups.(group_names{subject_group}).N+1;
    disp(['Calculating ERPs for participant ' subject])
    %load( fullfile(file.folder,file.name), 'eeg_w','file_proc_info' );
    eeg_w = eeg_dat(i_f).data;
    if strcmp(batch.task,'aurora_test')
        eeg_w = cellfun(@(x) reshape(x,size(x,1),size(x,2),size(x,3)*size(x,4)),eeg_w,'UniformOutput',false) ;     
    end
    if trial_thresh && any(cell2mat(cellfun(@(x) size(x,3),eeg_w,'UniformOutput',false))<9)
        continue
    end% get rise-decay average for SL, if necessary
    if batch.avg_rise_decay
        new_eeg = cell(8,1);
        eeg_w = loudness_rise_decay_avg(eeg_w);
    end

    % iterate through rois
    for i_r=1:n_rois
        n_erps    = length(batch.peak_name{1,i_r});
        erps{i_r} = cell(1,n_erps);

        % iterate through erp components
        for i_l=1:n_erps
            erps{i_r,1}{1,i_l} = batch.peak_name{1,i_r}{1,i_l};
            
            % calculate erp component
            % NOTE: calculate_erps_v1 is previous version, calculate_erps
            % is actually v2/the current version
           % calculate_erps( eeg_w, subject, batch, i_r, i_l ,file_proc_info);
           %yb edited to run through without file proc since may be
           %unneccesary
                        calculate_erps( eeg_w, subject, batch, i_r, i_l ,[]);

        end
    end

    % TODO: calculate_erps_by_amplitude
    
    clear eeg_w
end

% calculate peak differences
calculate_erp_peak_distances( batch );

%% save batch info with dataset
path_erp_batch = fullfile(batch.path_task_erp,batch.batch_fname);
load(path_erp_batch,'data'); save(path_erp_batch,'data','ids','batch');

disp('Finished.')