function tables = sort_data_into_group_tables(batch,exclude,conds,run_rois)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% load batch data
data_path = fullfile(batch.path_task_erp,batch.batch_fname);
load( data_path, 'data' )

% get batch information
groups = batch.groups.table;
grp_names = fieldnames(batch.groups); grp_names = grp_names(2:end);
n_grps = length(grp_names);
rois   = fieldnames(data);
rois = intersect(rois,run_rois);
n_rois = length(rois);
%% compile subject data by group
% iterate through rois
for i_r = 1:n_rois
    roi = rois{i_r};
    erps = fieldnames(data.(roi));
    n_erps = length(erps);
    % iterate through erp components
    for i_c = 1:n_erps
        erp = erps{i_c};
        erp_data = data.(roi).(erp);

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
            % TODO: rescale data
            
            % get subject group
            s_idx  = strcmp(groups.id,subj_id);
            grp_id = groups.group(s_idx);
            if isempty(grp_id) || sum(strcmp(exclude,subj_id)) > 0
                continue
            end
            grp = grp_names{grp_id};
            
            % add subject data to group struct
            if ~isrow(subj_data), subj_data = subj_data'; end
            try 
                group_data.(grp).(roi).(erp).ids{end+1}  = subj_id;
                group_data.(grp).(roi).(erp).data{end+1} = subj_data;
            catch
                group_data.(grp).(roi).(erp).ids  = [];
                group_data.(grp).(roi).(erp).data = {};
                group_data.(grp).(roi).(erp).ids{end+1,1}  = subj_id;
                group_data.(grp).(roi).(erp).data{end+1,1} = subj_data;
            end
        end
    end
end

%% average group entries
% iterate through rois
for i_r = 1:n_rois
    roi = rois{i_r};
    erps = fieldnames(group_data.(grp).(roi));
    n_erps = length(erps);
    % iterate through erp components
    for i_c = 1:n_erps
        erp = erps{i_c};

        for i_g = 1:n_grps
            % get group data
            grp = grp_names{i_g};
            try
            grp_entries = cell2mat(group_data.(grp).(roi).(erp).data');
            catch
                a = 5
            end
            grp_ids     = group_data.(grp).(roi).(erp).ids';
            T = table(grp_entries(:,1),'VariableNames',{conds{1}},'RowNames',grp_ids);
            for i = 2:size(grp_entries,2)
                T.(conds{i}) = grp_entries(:,i);
            end
            tables.(grp).(roi).(erp) = T;
        end
    end
end

end