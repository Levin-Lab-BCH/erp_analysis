function [grp_mtx,grp_labels,sis] = sort_erp_data_for_plotting( data,   ...
                                        task, groups, rois, erps, use_si )

% iterate through group
n_grps = length(groups);
n_rois = length(rois);
n_erps = length(erps);

% initialize variables
grp_mtx    = cell(n_grps,n_rois); 
grp_labels = cell(1,n_grps);
sis        = cell(n_grps,n_rois);

% get group data
for i_g = 1:n_grps
    for i_r = 1:n_rois
        % initialize group/roi arrays
        grp_mtx{i_g,i_r} = cell(1,n_erps); 
        sis{i_g,i_r} = cell(1,n_erps);
        roi = rois{i_r};
        for i_e = 1:n_erps
            if ~isfield(data.(groups{1}),roi)
                continue
            end
            
            % skip if ERP component not in ROI
            erp = erps{i_e};
            if ~isfield(data.(groups{1}).(roi),erp)
                continue
            end

            % get group data
            group = groups{i_g};
            grp_mtx{i_g,i_r}{i_e} = data.(group).(roi).(erp);
            grp_labels{i_g} = [group ', n=' int2str(size(grp_mtx{i_g},1))];

            switch task
                % calculate suppression faction/index for TSS
                case '04_Tactile_Spatial_Suppression'
                    for i_s = 1:size(grp_mtx{i_g},1)
                        subj_erp = abs(grp_mtx{i_g}(i_s,:));
                        % log suppression fraction: log2(B/[I+M])
                        if use_si
                            sf = 1 - subj_erp(3)/(subj_erp(1)+subj_erp(2));
                        else
                            sf = log2(subj_erp(3)/(subj_erp(1)+subj_erp(2)));
                        end
                        sis{i_g,i_r}{i_e} = sf;
                    end
            end
        end
    end
end

end