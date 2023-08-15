function tables = sort_data_into_group_tables_v2(batch,exclude)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% get batch information
% load batch data
data_path = fullfile(batch.path_task_erp,batch.batch_fname);
load( data_path, 'data' )
% get batch information
groups = batch.groups.table;
rois   = fieldnames(data);
n_rois = length(rois);

%% compile subject data by group
% iterate through rois
for i_r = 1:n_rois
    roi = rois{i_r};
    erps = fieldnames(data.(roi));
    n_erps = length(erps);
    % iterate through erp components
    for i_c = 1:n_erps
        erp = erps{i_c}; erp_data = data.(roi).(erp);
        % initialize roi/erp struct
        tables.(roi).(erp) = [];
        % iterate through subjects
        subjs = fieldnames(erp_data);
        for i_s = 1:length(subjs)
            % get subject id and data
            subj = subjs{i_s};
            if ~strcmp(subj(7:end),batch.method)
                continue
            end
            subj_id   = subj(2:5); subj_data = erp_data.(subj);
            if size(subj_data,2) > size(subj_data,1)
                subj_data = subj_data';
            end
            % get subject group
            s_idx = strcmp(groups.id,subj_id);
            group = groups.group(s_idx);
            % skip if no group assignment, or in "exclude" input
            if isempty(group) || sum(strcmp(exclude,subj_id)) > 0
                continue
            end
            % add subject data to group struct
            tables.(roi).(erp)(end+1).id  = str2double(subj_id);
            tables.(roi).(erp)(end).group = group; 
            tables.(roi).(erp)(end).data  = subj_data;
        end
    end
end

end