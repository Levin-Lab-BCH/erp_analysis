function [peak,latency] = trace_peak(eeg,chan,t_range,seg_win,srate,type)
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
    n_conds = size(eeg,1);
    peak = zeros(1,n_conds);
    latency = zeros(1,n_conds);
    if contains(type,'n') || contains(type,'N')
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

function idxs = get_segment_times(seg_win, srate)
    % get times of samples for a given segment window and samp rate
    n_samps = ceil(srate*sumabs(seg_win)/1000);
    idxs = linspace(seg_win(1),seg_win(2),n_samps);
end