function [peak,latency] = calculate_erp_peak_by_cond( eeg,chan,t_range, ...
                                                   seg_win,srate,polarity )
    % convert data to matrix, average across chans
    trace = trace_to_matrix(eeg,chan{1},chan{2},chan{3});
    % get time indeces to average across
    times  = get_segment_times(seg_win,srate);
    if ~isempty(t_range)
        t_idxs = get_indexes(t_range,times,1);
    else
        t_idxs = 1:size(times);
    end
    
    % find max of trace across time indeces
    n_conds = length(eeg);
    peak = zeros(1,n_conds);
    latency = zeros(1,n_conds);
    if ~polarity
        for i_c = 1:n_conds
            [m,i_m] = min(trace(i_c,t_idxs));
            peak(i_c) = m;
            latency(i_c) = times(t_idxs(i_m));
        end
    else
        for i_c = 1:n_conds
            [m,i_m] = max(trace(i_c,t_idxs));
            if isnan(m)
                disp('nan')
            end
            peak(i_c) = m;
            latency(i_c) = times(t_idxs(i_m));
        end
    end
end