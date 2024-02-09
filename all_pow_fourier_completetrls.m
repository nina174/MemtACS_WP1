%% start up fieldtrip

addpath ~...fieldtrip-20200215;
ft_defaults

%% paths

inpath = dir('...');
inpath(1:2) = [];

outpath = '...'; 
cd(outpath)

condition = {'correct' 'incorrect'}; 

%% choose subjects with enough (<48) rejected trials after preprocessing

load rejected_trials_new.mat

subjs = find(rejectedtrial_task(:,1) <= 48);

inpath = inpath(subjs);
 
for sub = 1:size(inpath,1)
    
    load(sprintf('%s_TOM_preproc.mat', inpath(sub).name), 'data_csd');
                        
    %% TFMEMTACS 
    %time-frequency-analysis power for correct and
    %incorrect trials

    for cond = 1:2

        cfg = [];
        cfg.channel    = 'all';	                
        cfg.keeptrials = 'yes';
        cfg.trials     = find(data_csd.trialinfo == cond);
        cfg.method     = 'wavelet';                
        cfg.width      =  linspace(3, 10, length(1:1:89)); % cycle  %linspace(6, 60, length(5:5:200));  %linspace(3, 31, length(4:1:18))
        cfg.output     = 'pow';	
%         cfg.gwidth     = 2;
        cfg.foi        = 1:0.5:45;   %4:1:80;	                
        cfg.toi        = -1.5:0.01:6.5;	    %-0.9995:0.01:1;	 %-0.4995:0.001:0.5;	
%         cfg.pad        = 'maxperlen';
%         cfg.padtype    = 'zero';
        aTFRwave = ft_freqanalysis(cfg, data_csd);

       save(sprintf('%s_TOM_%s_trls_pow.mat', inpath(sub).name, condition{cond}), 'aTFRwave', '-v7.3');

    end
    
    cfg = [];
    cfg.channel    = 'all';	                
    cfg.keeptrials = 'yes';
%     cfg.trials     = find(data_csd.trialinfo == cond);
    cfg.method     = 'wavelet';                
    cfg.width      =  linspace(3, 10, length(1:1:89)); % cycle  %linspace(6, 60, length(5:5:200));  %linspace(3, 31, length(4:1:18))
    cfg.output     = 'pow';	
%         cfg.gwidth     = 2;
    cfg.foi        = 1:0.5:45;   %4:1:80;	                
    cfg.toi        = -1.5:0.01:6.5;	    %-0.9995:0.01:1;	 %-0.4995:0.001:0.5;	
%         cfg.pad        = 'maxperlen';
%         cfg.padtype    = 'zero';
    aTFRwave = ft_freqanalysis(cfg, data_csd);

   save(sprintf('%s_TOM_all_trls_pow.mat', inpath(sub).name, 'aTFRwave', '-v7.3');

  %% fourier
    for cond = 1:2

        cfg = [];
        cfg.channel    = 'all';	                
        cfg.keeptrials = 'yes';
        cfg.trials     = find(data_csd.trialinfo == cond);
        cfg.method     = 'wavelet';                
        cfg.width      =  linspace(3, 10, length(1:1:89)); % cycle  %linspace(6, 60, length(5:5:200));  %linspace(3, 31, length(4:1:18))
        cfg.output     = 'fourier';	
%         cfg.gwidth     = 2;
        cfg.foi        = 1:0.5:45;   %4:1:80;	                
        cfg.toi        = -1.5:0.01:6.5;	    %-0.9995:0.01:1;	 %-0.4995:0.001:0.5;	
%         cfg.pad        = 'maxperlen';
%         cfg.padtype    = 'zero';
%         TFRwave = ft_freqanalysis(cfg, dataA);
%         TFRwave = ft_freqanalysis(cfg, dataPW);
        aTFRwave = ft_freqanalysis(cfg, data_csd);

       save(sprintf('%s_TOM_%s_trls_fourier.mat', inpath(sub).name, condition{cond}), 'aTFRwave', '-v7.3');

    end
end
    
