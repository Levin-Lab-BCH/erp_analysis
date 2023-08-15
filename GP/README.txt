pipeline to automatically compute and subsequently plot erp peak/average amplitudes and AUCs.
to run erp pipeline:
	1. create parameter file 'batch_erp_load_params_v[X].m', using previous version as a template
		- add information for data to process, including windows to search for ERP peaks, file paths, and processing params
	2. edit 'batch_erp_calculate.m' to call 'batch_erp_load_params_v[X]'
		- make sure the few params on this file are also set correctly, including:
			- computer type ('pc' or 'mac', for filepath format)
			- paradigm to process 
			- run tag for batch
			- proccess data by paradigm conditions ['conds'] or individual trials ['trials']
	3. run 'batch_erp_calculate'
	4. data will be saved to a .mat file named 'erp[beapp data run tag][erp pipeline run tag].mat' to the folder indicated in parameters
		- file will contain a struct variable 'data' with outputs, organized by ROI and ERP component
		- use 'batch_erp_plot_[...].mlx' scripts to visualize outputs