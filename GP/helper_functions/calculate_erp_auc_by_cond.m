function auc = calculate_erp_auc_by_cond( eeg, chan, t_range,       ...
                                              seg_win, srate )
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
    auc = squeeze(sum(trace(:,t_idxs),2));
end