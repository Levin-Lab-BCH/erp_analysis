function [plot_data,batch] = calc_dr_by_indiv(batch,exclude,erps,use_mag,conds)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% load batch data
data_path = fullfile(batch.path_task_erp,batch.batch_fname);
load( data_path, 'data' )

% get batch information
method = batch.method;
groups = batch.groups.table;
n_erps = length(erps);
grp_names = fieldnames(batch.groups);
n_grps = length(grp_names);
rois   = fieldnames(data);

n_rois = length(rois);
%% compile subject data by group
% iterate through rois
for i_r = 1:n_rois
    roi = rois{i_r};
    % iterate through erp components
    for i_e = 1:n_erps
        erp = erps{i_e};
        if ~isfield(data.(roi),erp), continue; end
        erp_data = data.(roi).(erp);
        plot_data.(roi).(erp) = [];

        % iterate through subjects
        subjs = fieldnames(erp_data);
        for i_s = 1:length(subjs)
            % get subject id and data
            subj = subjs{i_s};
            if ~strcmp(subj(7:end),batch.method)
                continue
            end
            subj_id = subj(2:5);
            subj_data = erp_data.(subj);
            if strcmpi(erp(1),'N'), subj_data = -1 * subj_data; end
            
            % get subject group
            s_idx  = strcmp(groups.id,subj_id);
            grp_id = groups.group(s_idx);
            if isempty(grp_id) || sum(strcmp(exclude,['p' subj_id])) > 0
                continue
            end
            grp = grp_names{grp_id};

            % calculate amplitude change between each tone
            n_cond = length(subj_data);
            jumps  = zeros(1,n_cond-1);
            for i_c = 2:(n_cond)
                jumps(i_c-1) = subj_data(i_c) - subj_data(i_c-1);
            end

            % get max change
            if ~exist('conds','var'), conds = 1:length(jumps); end
            if use_mag
                [max_j,max_i] = max(abs(jumps(conds)));
            else
                [max_j,max_i] = max(jumps(conds));
            end

            % add subject data to group matrix
            plot_data.(roi).(erp)(end+1).id  = str2double(subj_id);
            plot_data.(roi).(erp)(end).group = grp_id;
            plot_data.(roi).(erp)(end).all_jumps  = jumps';
            plot_data.(roi).(erp)(end).max_jump   = max_j;
            plot_data.(roi).(erp)(end).max_jump_i = max_i;
        end
    end
end

end