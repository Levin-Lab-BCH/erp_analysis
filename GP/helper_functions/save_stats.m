function save_stats(folder, fn, s_id, chans, stats, stat_type, tag, override, id, roi)
%% saves calculated stats to chosen folder in a struct
%{
inputs:
    - folder: 
    - fn: 
    - id: 
    - chans: 
    - stats: 
    - stat_type: 
    - tag:
%}
%%
    filepath = [folder filesep fn];
    data_id = ['p' s_id '_' tag];
    if ~exist(folder,'dir')
        mkdir(folder)
    end
    if ~exist('override','var')
        override = 0;
    end
    if ~isfile(filepath) || override
        data = struct(chans,struct(stat_type,struct(data_id,stats)));
        save(filepath,'data');
    else
        load(filepath, 'data')
        data.(chans).(stat_type).(data_id) = stats;
        if exist('id','var') && exist('roi','var')
            save(filepath,'data','id','roi');
        else
            save(filepath,'data');
        end
    end
end