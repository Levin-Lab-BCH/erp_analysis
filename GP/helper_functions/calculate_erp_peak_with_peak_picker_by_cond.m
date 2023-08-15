function [peaks_all,latency_all] = calculate_erp_peak_with_peak_picker_by_cond( eeg,chan,t_range, ...
                                                   seg_win,srate,polarity,multi )
    % convert data to matrix, average across chans
    trace = trace_to_matrix(eeg,chan{1},chan{2},chan{3});
    % get time indeces to average across
    times  = get_segment_times(seg_win,srate);
    if ~isempty(t_range)
        t_idxs = get_indexes(t_range,times,1);
    else
        t_idxs = 1:size(times,2);
    end
    if multi
        multi_str = 'yes';
    else
        multi_str = 'no';
    end
    % find max of trace across time indeces
    n_conds = length(eeg);
    peaks_all = cell(1,n_conds);
    latency_all = cell(1,n_conds);
    for i_c = 1:n_conds
        
    [peaks_all{i_c}, ~, ~, errorcode] = localpeak(trace(i_c,t_idxs), t_idxs, 'Neighborhood',40,'PeakPolarity',polarity,'Peakreplace',char('NaN'),'Multipeak',char(multi_str));
        
    if isnan(peaks_all{i_c})
            latency_all{i_c}= NaN;
    else
        try
        latency_all{i_c} = times(t_idxs(find(ismember(trace(i_c,t_idxs),peaks_all{i_c}))));
        catch
            A = 5
        end
    end
    end
    peaks_all = padcat(peaks_all{:});
    latency_all = padcat(latency_all{:});
    n_trials = size(peaks_all,2);
    peak = reshape(peaks_all,[1 n_conds*n_trials]);
    latency = reshape(latency_all,[1 n_conds*n_trials]);
end