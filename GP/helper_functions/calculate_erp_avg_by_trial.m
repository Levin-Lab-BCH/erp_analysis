function avg = calculate_erp_avg_by_trial( eeg_w, chan, t_range,        ...
                                           seg_win, srate, use_abs )
    % get channel numbers
    chan_nos = [get_channels(chan{1}) chan{2}];
    % get time indeces to average across
    times_seg = get_segment_times(seg_win,srate);
    if ~isempty(t_range)
        times_erp = get_indexes(t_range,times_seg,1);
    else
        times_erp = 1:size(times_seg);
    end

    % initialize output variables
    n_conds = size(eeg_w,1);
    avgs_all = cell(1,n_conds);

    % iterate through conditions
    for i_c = 1:n_conds
        % get condition data in selected time windows & channels
        eeg = eeg_w{i_c}(chan_nos,times_erp,:);
        if size(eeg,3) == 1
            only_one_trial =1;
        else
            only_one_trial = 0;
        end
        % if channel weights, apply
        if ~isempty(chan{3})
            eeg = sum(chan{3}'.*eeg,1);
        end
        % get channel average time series
        eeg = squeeze(nanmean(eeg,1));
        % find average
        if only_one_trial
            eeg = eeg';
        end
        if use_abs
            eeg = abs(eeg);
        end
        avgs_all{i_c} = mean(eeg,1);
    end

    % reshape matrix into chronological vector
   if n_conds <=1
       avgs_all = avgs_all{:};
   else
    avgs_all = padcat(avgs_all{:});
   end
    n_trials = size(avgs_all,2);
    avg = reshape(avgs_all,[1 n_conds*n_trials]);

end