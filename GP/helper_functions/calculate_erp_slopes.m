function out = calculate_erp_slopes(data,groups,rois,erp_times)
n_grps = length(groups); 
n_rois = length(rois);
for i_r = 1:n_rois
    roi = rois{i_r};
    % iterate through groups
    out = struct();
    for i_g = 1:n_grps
        grp    = groups{i_g};
        subjs  = fieldnames(data.(grp).(roi));
        n_subj = length(subjs);
        for i_s = 1:n_subj
            subj = subjs{i_s};
            subj_data = data.(grp).(roi).(subj);
            n_erps    = length(subj_data);

            % fit lines to peaks
            subj_fit_peak_ct = polyfit(1:n_erps,subj_data,1);
            if exist('erp_times','var')
                subj_fit_time  = polyfit(erp_times,subj_data,1);
            end

            % add subject row to struct
            if ~isfield(out,roi), out.(roi) = []; end
            out.(roi)(end+1).id      = str2double(subj(2:end));
            out.(roi)(end).group     = i_g;
            out.(roi)(end).erps      = subj_data;
            out.(roi)(end).m_peak_ct = subj_fit_peak_ct(1);
            out.(roi)(end).b_peak_ct = subj_fit_peak_ct(2);
            if exist('erp_times','var')
                out.(roi)(end).m_time  = subj_fit_time(1);
                out.(roi)(end).b_time  = subj_fit_time(2);
            end
        end
    end
end