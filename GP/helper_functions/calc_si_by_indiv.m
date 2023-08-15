function [group_data,batch] = calc_si_by_indiv(batch,exclude,erps,calc_SI)
%
%
%
%
%
%
%
%
%
%
%
%
%% PLEASE DO NOT MODIFY THIS FUNCTION
%
%
%
%
%
%
%
%
%
%
%
%

%%
% load batch data
data_path = fullfile(batch.path_task_erp,batch.batch_fname);
load( data_path, 'data' )

% get batch information
method = batch.method;
groups = batch.groups.table;
grp_names = fieldnames(batch.groups); 
grp_names = grp_names(~strcmp(grp_names,'table'));
n_grps = length(grp_names);
rois   = fieldnames(data);

n_rois = length(rois);
%% compile subject data by group
% iterate through rois
for i_r = 1:n_rois
    roi = rois{i_r};  % erps = fieldnames(data.(roi));
    n_erps = length(erps);
    % iterate through erp components
    for i_c = 1:n_erps
        erp = erps{i_c};
        if ~isfield(data.(roi),erp), continue; end
        erp_data = data.(roi).(erp);
        % iterate through subjects
        subjs = fieldnames(erp_data);
        for i_s = 1:length(subjs)
            % get subject id and data
            subj = subjs{i_s};
            if ~strcmp(subj(7:end),batch.method)
                continue
            end
            subj_id = subj(1:5); subj_data = erp_data.(subj);
            % flips signs for negative components
            if strcmpi(erp(1),'N'), subj_data = -1 * subj_data; end
            % get subject group
            s_idx  = strcmp(groups.id,subj_id(2:end));
            grp_id = groups.group(s_idx);
            if isempty(grp_id) || sum(strcmp(exclude,subj_id)) > 0 %|| str2num(subj_id(2:end))<1066
                continue
            end
            grp = grp_names{grp_id};
            % calculate suppression ratio
            if calc_SI
                im = subj_data(1) + subj_data(2);
                b  = subj_data(3);
                % if I+M < 0, need to address sign issue
                if im < 0
                    sf = (im - b) ./ -im;
                else
                    sf = (im - b) ./ im;
                end
            else
               sf = subj_data;
            end
            % add subject data to group matrix
            try 
                group_data.(grp).(roi).(subj_id)(end+1) = sf;
            catch
                group_data.(grp).(roi).(subj_id) = [];
                group_data.(grp).(roi).(subj_id)(end+1,1) = sf;
            end
        end
    end
end

% save struct to server
save(data_path,'data','batch')