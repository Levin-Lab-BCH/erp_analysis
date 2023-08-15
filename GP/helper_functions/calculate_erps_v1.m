function erps = calculate_erps( eeg, subject, batch, i_r, i_l )
%% CALCULATE_ERPS: calculate and save erp components for given eeg & params
% Inputs:
%  - eeg - beapp-type cell with segmented eeg across conditions
%  - subject    - char with 4-digit subject id
%  - batch_info - struct w/ processing info from load_batch_erp_variables.m
%  - i_r        - index of roi to use from batch_info
%  - i_l        - index of erp component to use from batch_info

%% get information about batch
% get channel information
chan_1020   = batch.roi_1020{1,i_r};
chan_other  = batch.roi_other{1,i_r};
chan_weight = batch.roi_weight{1,i_r};
chan_str    = get_chan_str(chan_1020,chan_other);
roi = {chan_1020,chan_other,chan_weight};
use_abs = batch.use_abs;

% get temporal information
seg_win   = batch.seg_win;
srate     = batch.srate;
peak_time = batch.peak_time{1,i_r}(i_l);
win_size  = batch.peak_win_size{1,i_r}(i_l);
t_range   = [peak_time-win_size peak_time+win_size];

% get information about peak type and file saving
peak_name = batch.peak_name{1,i_r}{1,i_l};
data_path = batch.path_task_erp;
data_fn   = batch.batch_fname;
polarity  = batch.peak_polarity{i_r}(i_l);

%% calculate averages/peaks
switch batch.method
    case 'conds_avg'
        erps = calculate_erp_avg_by_cond( eeg, roi, t_range, seg_win,   ...
                                           srate, use_abs );

    case 'trials_avg'
        erps = calculate_erp_avg_by_trial( eeg, roi, t_range, seg_win,  ...
                                           srate, use_abs );

    case 'conds_peak'
        [erps,lat] = calculate_erp_peak_by_cond( eeg, roi, t_range,     ...
                                                seg_win, srate, polarity );

    case 'trials_peak'
        [erps,lat] = calculate_erp_peak_by_trial( eeg, roi, t_range,    ...
                                                seg_win, srate, polarity );
end

%% save data
% save erp peak/average data
save_stats( data_path, data_fn, subject, chan_str, erps, peak_name, ...
            batch.method );

% save latency data
if exist('lat','var')
    save_stats( data_path, data_fn, subject, chan_str, lat,         ...
                peak_name, [batch.method '_latency'] );
end

end