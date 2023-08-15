function [peak,latency] = calculate_erp_peak_with_peak_picker_by_trial( eeg_w, chan,     ...
                                        t_range, seg_win, srate, polarity,multi )
    % get channel numbers
    chan_nos = [get_channels(chan{1}) chan{2}];
    % get time indeces to average across
    times_seg = get_segment_times(seg_win,srate);
    if ~isempty(t_range)
        times_erp = get_indexes(t_range,times_seg,1);
    else
        times_erp = 1:size(times_seg,2);
    end
if multi
        multi_str = 'yes';
    else
        multi_str = 'no';
    end
    % initialize output variables
    n_conds = size(eeg_w,1);
    peaks_all = cell(1,n_conds);
    latency_all = cell(1,n_conds);

    % iterate through conditions
    for i_c = 1:n_conds
        % get condition data in selected time windows & channels
        eeg = eeg_w{i_c}(chan_nos,times_erp,:);

        % if channel weights, apply
        if ~isempty(chan{3})
            eeg = sum(chan{3}'.*eeg,1);
        end
        % get channel average time series
        eeg = squeeze(nanmean(eeg,1));
        
        %find local peaks
     
            for trial = 1:size(eeg,2)
                
        [peaks_all{i_c}(1,trial), ~, ~, errorcode] = localpeak(eeg(:,trial), times_erp, 'Neighborhood',10,'PeakPolarity',polarity,'Peakreplace',char('NaN'),'Multipeak',char(multi_str));
            end     
              
                
        if isnan(peaks_all{i_c}(1,trial))
            latency_all{i_c}(1,trial) = NaN;
        else
        latency_all{i_c}(1,trial) = times_seg(times_erp(find(eeg(:,trial)==peaks_all{i_c}(1,trial))));
        end

            end
    
    % reshape matrix into chronological vector
    peaks_all = padcat(peaks_all{:});
    latency_all = padcat(latency_all{:});
    n_trials = size(peaks_all,2);
    peak = reshape(peaks_all,[1 n_conds*n_trials]);
    latency = reshape(latency_all,[1 n_conds*n_trials]);

