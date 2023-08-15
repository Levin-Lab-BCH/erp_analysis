function trace = trace_to_matrix(eeg, chan_1020, chan_other, chan_weights, use_median)
    %% convert segment output to matrix with selected channels
    %{
    inputs:
        - eeg:          n_c x 1 cell output by BEAPP segment module
        - chan_1020:    cell containing 1020 channel names to keep
        - chan_other:   double with other channel numbers to keep
        - chan_weights: optional weights to apply to channels
    outputs:
        - trace: n_c x n_s matrix, where n_c=# conditions, n_s=# samples
    %}
    %% 
    % get channel numbers
    chan_nos = [get_channels(chan_1020) chan_other];
  %  chan_nos = 1:128;
    % initialize output
    n_conds = length(eeg);
    n_samps = 0;
    counter = 1;
    while (n_samps) == 0
        n_samps = size(eeg{counter,1},2);
        counter = counter +1;
    end
    
    trace   = zeros(n_conds,n_samps);
    
    if ~exist('use_median','var')
        use_median = 0;
    end
    
    for i_c = 1:n_conds
        if isempty(chan_nos)
            % average across all chans, then across trials
            trace(i_c,:) = avg_mtx_d3(nanmean(eeg{i_c},1),use_median);
        else
            % pull out relevant channels, average across trials
            if ~isempty(eeg{i_c})
            temp = avg_mtx_d3(eeg{i_c}(chan_nos,:,:),use_median);
            else
                temp = NaN(1,n_samps);
            end
            % if channel weights, apply
            if exist('chan_weights', 'var')
                if ~isempty(chan_weights)
                    temp = sum(chan_weights'.*temp,1);
                end
            end
            
            % average out channels
            try
            trace(i_c,:) = squeeze(nanmean(temp,1));
            catch
                pause()
            end
        end
    end
end

function mtx = avg_mtx_d3(mtx,use_med)
    % average and squeeze out 3rd dimension of input matrix
    if ~use_med
        mtx = squeeze(nanmean(mtx,3));
    else
        mtx = squeeze(nanmedian(mtx,3));
    end
end