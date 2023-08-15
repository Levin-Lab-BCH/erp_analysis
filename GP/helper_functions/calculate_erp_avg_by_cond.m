function average = calculate_erp_avg_by_cond( eeg, chan, t_range,       ...
                                              seg_win, srate, use_abs )
    % convert data to matrix, average across chans
    trace = trace_to_matrix(eeg,chan{1},chan{2},chan{3});
    % get time indeces to average across
    times  = get_segment_times(seg_win,srate);
    if t_range
        t_idxs = get_indexes(t_range,times,1);
    else
        t_idxs = 1:size(times);
    end
    
    % average trace across time indeces
    if use_abs
        average = abs(squeeze(nanmean(trace(:,t_idxs),2)));
    else
        average = squeeze(nanmean(trace(:,t_idxs),2));
    end
end