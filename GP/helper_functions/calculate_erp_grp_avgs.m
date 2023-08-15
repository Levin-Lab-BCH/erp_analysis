function [group_data,batch] = calculate_erp_grp_avgs(batch,exclude)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% load batch data
data_path = fullfile(batch.path_task_erp,batch.batch_fname);
data_path = strrep(data_path,'X:','Z:');

load( data_path, 'data' )
% get batch information
method = batch.method;
groups = batch.groups.table;
grp_names = fieldnames(batch.groups); grp_names = grp_names(2:end);
n_grps = length(grp_names);
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
        erp = erps{i_c};
        erp_data = data.(roi).(erp);
        % skip if already exists
        if isfield(erp_data,'group_average')
            if isfield(erp_data.group_average,method)
                excluded = erp_data.group_average.(method).exclude;
                if 0 && isempty(setdiff(excluded,exclude)) &&                ...
                        isempty(setdiff(exclude,excluded))
                    for i_g = 1:n_grps
                        grp = grp_names{i_g};
                        try
                        grp_data = erp_data.group_average.(method).(grp);
                        catch
                            a=5
                        end
                        group_data.(grp).(roi).(erp) = grp_data;
                    end
                    continue
                end
            end
        end

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
            if batch.rescale
                subj_data = z_transform(subj_data);
            end
            
            % get subject group
            s_idx  = strcmp(groups.id,subj_id);
            grp_id = groups.group(s_idx);
            if isempty(grp_id) || sum(strcmp(exclude,subj_id)) > 0
                continue
            end
            grp = grp_names{grp_id};
            
            % add subject data to group matrix
            try 
                group_data.(grp).(roi).(erp){end+1} = subj_data;
            catch
                group_data.(grp).(roi).(erp) = {};
                group_data.(grp).(roi).(erp){end+1,1} = subj_data;
            end
        end
    end
end

%% average group entries
% iterate through rois
for i_r = 1:n_rois
    roi = rois{i_r};
    erps = fieldnames(data.(roi));
    n_erps = length(erps);
    % iterate through erp components
    for i_c = 1:n_erps
        erp = erps{i_c};
        
        % skip if already calculated
%         if isfield(erp_data,'group_average')
%             erp_data = data.(roi).(erp);
%             if isfield(erp_data.group_average,method)
%                 excluded = erp_data.group_average.(method).exclude;
%                 if isempty(setdiff(excluded,exclude)) &&                ...
%                         isempty(setdiff(exclude,excluded))
%                     continue
%                 end
%             end
%         end

        % calculate group averages
        for i_g = 1:n_grps
            % get group data
            grp = grp_names{i_g};
            try
                grp_entries = padcat(group_data.(grp).(roi).(erp){:});
            catch
                % if avg/error already calculated, skip ERP component
                continue
            end
           
            n_subjs  = length(group_data.(grp).(roi).(erp));
            n_conds = length(group_data.(grp).(roi).(erp){1});
            grp_entries = reshape(grp_entries,[n_subjs n_conds]);

            % calcualte group average & error
            grp_avg = squeeze(nanmean(grp_entries,1));
            grp_err = nanstd(grp_entries,0,1)/sqrt(size(grp_entries,1));
            
            % save to output variable and struct
            group_data.(grp).(roi).(erp) = [];
            group_data.(grp).(roi).(erp).avg = grp_avg;
            group_data.(grp).(roi).(erp).err = grp_err;
            data.(roi).(erp).group_average.(method).(grp).avg = grp_avg;
            data.(roi).(erp).group_average.(method).(grp).err = grp_err;
            batch.groups.(grp).N = n_subjs;
        end
        data.(roi).(erp).group_average.(method).exclude = exclude;
    end
end

% save struct to server
save(data_path,'data','batch')