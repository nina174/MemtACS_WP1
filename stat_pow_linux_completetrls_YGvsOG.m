%% define paths and variables

addpath ...fieldtrip-20211016
addpath ...templates 

inpathOG = dir('...');
inpathOG(1:2)=[];
inpathYG = dir('...'); 
inpathYG(1:2)=[];

% choose subjects with enough (<48) rejected trials after preprocessing

load .../YG/outcomes/rejected_trials_150.mat
subjs = find(rejectedtrial_task(:,1) <= 48);
inpathYG = inpathYG(subjs);

clear subjs rejectedtrial_task

load .../OG/outcomes/rejected_trials_150.mat
subjs = find(rejectedtrial_task(:,1) <= 48);
inpathOG = inpathOG(subjs);

outpath = '.../outcomes'; 
cd(outpath)

condition = {'correct' 'incorrect'};

group = {'YG' 'OG'};


%% analysis YG vs OG

%input has to be cell-array of structures, with each subject�s
%averaged stored in one cell (for-loop to combine the data
%from each subject, within each condition, into one variable)

    load GAPOW_YG_BL
    grandavgYG = grandavg;
    load GAPOW_OG_BL
    grandavgOG = grandavg;

    cfg = [];
    cfg.latency          = [0.1 1.5]; % early: 0.1-2.9 late: 3.1-5.9 BL: -0.5 -0.1
    cfg.frequency        = [10 30];
%     cfg.channel          = {'F7', 'FC5', 'T7', 'CP5'}; 
    cfg.method           = 'montecarlo'; % methods for calculating the significance probability and/or critical value
    cfg.statistic        = 'indepsamplesT';
    cfg.correctm         = 'cluster';
%     cfg.clusteralpha     = 0.05; % alpha level of the sample-specific test statistic that will be used for thresholding
    cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution 
    cfg.minnbchan        = 2; % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0) 
    cfg.tail             = 0;  % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg.clustertail      = 0;
    cfg.alpha            = 0.025; % alpha level of the permutation test
    cfg.numrandomization = 1000; % number of draws from the permutation distribution
    cfg.parameter        = 'powspctrm'; % default = 'powspctrm' 
    cfg.clustercritval   = [-1.96 1.96]; % two-tailed[-1.96 1.96]; %because Z-values one-tailed [-1.645 1.645]
%     cfg.avgoverchan = 'yes'; %or 'no'                   % default = 'no'
%       cfg.avgovertime = 'yes';                   %(default = 'no')
%     cfg.avgoverfreq = 'yes'; % or 'no'                   (default = 'no')
    % specifies with which sensors other sensors can form clusters
    cfg_neighb.method    = 'template';
    cfg_neighb.template  = 'MEMTACS32ch-avg_neighb.mat'; 
    cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, grandavgYG);

    % design matrix: number 1 for YG and 2 for OG.
    
    design = zeros(1,size(grandavgYG.powspctrm,1) + size(grandavgOG.powspctrm,1));
    design(1,1:size(grandavgOG.powspctrm,1)) = 1;
    design(1,(size(grandavgOG.powspctrm,1)+1):(size(grandavgOG.powspctrm,1) + size(grandavgYG.powspctrm,1))) = 2;

    cfg.design           = design;
    cfg.ivar             = 1; %conditions/independent variable(s)

    [stat] = ft_freqstatistics(cfg, grandavgOG, grandavgYG);
    
    % extract values
    c_size = length(stat.stat(stat.mask)) 
    t_mean = mean(stat.stat(stat.mask))
    
    %% analysis correct vs incorrect
    
    load GAPOW_correct_BL
    grandavgCO = grandavg;
    load GAPOW_incorrect_BL
    grandavgINCO = grandavg;

    cfg = [];
    cfg.latency          = [0.1 0.3]; % early: 0.1-2.9 late: 3.1-5.9
    cfg.frequency        = [30 45];
%     cfg.channel          = {'F7', 'FC5', 'T7', 'CP5'}; 
    cfg.method           = 'montecarlo'; % methods for calculating the significance probability and/or critical value
    cfg.randomseed       = 5;
    cfg.statistic        = 'depsamplesT';
    cfg.correctm         = 'cluster';
%     cfg.clusteralpha     = 0.05; % alpha level of the sample-specific test statistic that will be used for thresholding
    cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution 
    cfg.minnbchan        = 2; % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0) 
    cfg.tail             = 0;  % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg.clustertail      = 0;
    cfg.alpha            = 0.025; % alpha level of the permutation test
    cfg.numrandomization = 1000; % number of draws from the permutation distribution
    cfg.parameter        = 'powspctrm'; % default = 'powspctrm' 
    cfg.clustercritval   = [-1.96 1.96]; % two-tailed[-1.96 1.96]; %because Z-values one-tailed [-1.645 1.645]
%     cfg.avgoverchan = 'yes'; %or 'no'                   % default = 'no'
%       cfg.avgovertime = 'yes';                   %(default = 'no')
%     cfg.avgoverfreq = 'yes'; % or 'no'                   (default = 'no')
    % specifies with which sensors other sensors can form clusters
    cfg_neighb.method    = 'template';
    cfg_neighb.template  = 'MEMTACS32ch-avg_neighb.mat'; 
    cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, grandavgCO);

    % design matrix: number 1 for correct and 2 for incorrect.
    
    design = zeros(1,size(grandavgCO.powspctrm,1) + size(grandavgINCO.powspctrm,1));
    design(1,1:size(grandavgCO.powspctrm,1)) = 1;
    design(1,(size(grandavgCO.powspctrm,1)+1):(size(grandavgCO.powspctrm,1) + size(grandavgINCO.powspctrm,1))) = 2;
    design(2, 1:size(grandavgCO.powspctrm,1)) = 1:size(grandavgCO.powspctrm,1);
    design(2,(size(grandavgCO.powspctrm,1)+1):(size(grandavgCO.powspctrm,1) + size(grandavgINCO.powspctrm,1))) = 1:size(grandavgINCO.powspctrm,1);

    cfg.design           = design;
    cfg.ivar             = 1; %conditions/independent variable(s)
    cfg.uvar             = 2;

    [stat] = ft_freqstatistics(cfg, grandavgCO, grandavgINCO);
    
    
    %% analysis interaction co/inco YG/OG
    
    load GAs_diff_YG_BL
    YG_diff = diff;
%     YG_diff.powspctrm(3,:,:,:) = []; % exclude YG-066 (6 rejected channels)
    
    load GAs_diff_OG_BL
    OG_diff = diff;
  
    cfg = [];
    cfg.latency          = [0.1 0.3]; % early: 0.1-2.9 late: 3.1-5.9
    cfg.frequency        = [4 8];
%     cfg.channel          = {'F7', 'FC5', 'T7', 'CP5'}; 
    cfg.method           = 'montecarlo'; % methods for calculating the significance probability and/or critical value
    cfg.randomseed       = 5;
    cfg.statistic        = 'indepsamplesT';
    cfg.correctm         = 'cluster';
%     cfg.clusteralpha     = 0.05; % alpha level of the sample-specific test statistic that will be used for thresholding
    cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution 
    cfg.minnbchan        = 2; % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0) 
    cfg.tail             = 0;  % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg.clustertail      = 0;
%     cfg.alpha            = 0.025; % alpha level of the permutation test
    cfg.numrandomization = 1000; % number of draws from the permutation distribution
    cfg.parameter        = 'powspctrm'; % default = 'powspctrm' 
    cfg.clustercritval   = [-1.96 1.96]; % two-tailed[-1.96 1.96]; %because Z-values one-tailed [-1.645 1.645]
%     cfg.avgoverchan = 'yes'; %or 'no'                   % default = 'no'
%       cfg.avgovertime = 'yes';                   %(default = 'no')
%     cfg.avgoverfreq = 'yes'; % or 'no'                   (default = 'no')
    % specifies with which sensors other sensors can form clusters
    cfg_neighb.method    = 'template';
    cfg_neighb.template  = 'MEMTACS32ch-avg_neighb.mat'; 
    cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, YG_diff);
    
    % design matrix: number 1 for YG and 2 for OG.
    
    design = zeros(1,size(YG_diff.powspctrm,1) + size(OG_diff.powspctrm,1));
    design(1,1:size(YG_diff.powspctrm,1)) = 1;
    design(1,(size(YG_diff.powspctrm,1)+1):(size(YG_diff.powspctrm,1) + size(OG_diff.powspctrm,1))) = 2;

    cfg.design           = design;
    cfg.ivar             = 1; %conditions/independent variable(s)

    [stat] = ft_freqstatistics(cfg, YG_diff, OG_diff);
    
    length(find(stat.mask)); % cluster size
    mean(stat.stat(find(stat.mask)));  % mean t-statistic within sig. cluster
    length(find(gamma_late.mask));
    mean(gamma_late.stat(gamma_late.mask));
    
    %% post-hoc tests
    
    load('stats.mat')

    effect = gamma_late;

    idx = find(effect.mask);
    [chan, freq, tp] = ind2sub(size(effect.mask), idx);
    
    load('GAPOW_OG_correct_BL.mat');
    group_co   = grandavg;
    load('GAPOW_OG_incorrect_BL.mat');
    group_inco = grandavg;
    
    cfg = [];
    cfg.latency          = [effect.time(min(tp)) effect.time(max(tp))]; % early: 0.1-2.9 late: 3.1-5.9
    cfg.frequency        = [effect.freq(min(freq)) effect.freq(max(freq))];
    cfg.channel          = effect.label(unique(chan)); 
    cfg.method           = 'montecarlo'; % methods for calculating the significance probability and/or critical value
    cfg.statistic        = 'depsamplesT';
    cfg.correctm         = 'cluster';
%     cfg.clusteralpha     = 0.05; % alpha level of the sample-specific test statistic that will be used for thresholding
    cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution 
    cfg.minnbchan        = 2; % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0) 
    cfg.tail             = 0;  % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg.clustertail      = 0;
    cfg.alpha            = 0.025; % alpha level of the permutation test
    cfg.numrandomization = 1000; % number of draws from the permutation distribution
    cfg.parameter        = 'powspctrm'; % default = 'powspctrm' 
    cfg.clustercritval   = [-1.96 1.96]; % two-tailed[-1.96 1.96]; %because Z-values one-tailed [-1.645 1.645]
%     cfg.avgoverchan = 'yes'; %or 'no'                   % default = 'no'
%       cfg.avgovertime = 'yes';                   %(default = 'no')
%     cfg.avgoverfreq = 'yes'; % or 'no'                   (default = 'no')
    % specifies with which sensors other sensors can form clusters
    cfg_neighb.method    = 'template';
    cfg_neighb.template  = 'MEMTACS32ch-avg_neighb.mat'; 
    cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, group_co);

    % design matrix: number 1 for correct and 2 for incorrect.
    
    design = zeros(1,size(group_co.powspctrm,1) + size(group_inco.powspctrm,1));
    design(1,1:size(group_co.powspctrm,1)) = 1;
    design(1,(size(group_co.powspctrm,1)+1):(size(group_inco.powspctrm,1) + size(group_inco.powspctrm,1))) = 2;
    design(2, 1:size(group_co.powspctrm,1)) = 1:size(group_co.powspctrm,1);
    design(2,(size(group_co.powspctrm,1)+1):(size(group_co.powspctrm,1) + size(group_inco.powspctrm,1))) = 1:size(group_inco.powspctrm,1);

    cfg.design           = design;
    cfg.ivar             = 1; %conditions/independent variable(s)
    cfg.uvar             = 2;

    [stat_OG] = ft_freqstatistics(cfg, group_co, group_inco);
    
    
    load('GAPOW_YG_incorrect_BL.mat');
    YG_perf = grandavg;
    load('GAPOW_OG_incorrect_BL.mat');
    OG_perf = grandavg;
    
    cfg = [];
    cfg.latency          = [effect.time(min(tp)) effect.time(max(tp))]; % early: 0.1-2.9 late: 3.1-5.9
    cfg.frequency        = [effect.freq(min(freq)) effect.freq(max(freq))];
    cfg.channel          = effect.label(unique(chan)); 
    cfg.method           = 'montecarlo'; % methods for calculating the significance probability and/or critical value
    cfg.statistic        = 'indepsamplesT';
    cfg.correctm         = 'cluster';
%     cfg.clusteralpha     = 0.05; % alpha level of the sample-specific test statistic that will be used for thresholding
    cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution 
    cfg.minnbchan        = 2; % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0) 
    cfg.tail             = 0;  % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg.clustertail      = 0;
%     cfg.alpha            = 0.025; % alpha level of the permutation test
    cfg.numrandomization = 1000; % number of draws from the permutation distribution
    cfg.parameter        = 'powspctrm'; % default = 'powspctrm' 
    cfg.clustercritval   = [-1.96 1.96]; % two-tailed[-1.96 1.96]; %because Z-values one-tailed [-1.645 1.645]
%     cfg.avgoverchan = 'yes'; %or 'no'                   % default = 'no'
%       cfg.avgovertime = 'yes';                   %(default = 'no')
%     cfg.avgoverfreq = 'yes'; % or 'no'                   (default = 'no')
    % specifies with which sensors other sensors can form clusters
    cfg_neighb.method    = 'template';
    cfg_neighb.template  = 'MEMTACS32ch-avg_neighb.mat'; 
    cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, YG_perf);
    
    % design matrix: number 1 for YG and 2 for OG.
    
    design = zeros(1,size(YG_perf.powspctrm,1) + size(OG_perf.powspctrm,1));
    design(1,1:size(YG_perf.powspctrm,1)) = 1;
    design(1,(size(YG_perf.powspctrm,1)+1):(size(YG_perf.powspctrm,1) + size(OG_perf.powspctrm,1))) = 2;

    cfg.design           = design;
    cfg.ivar             = 1; %conditions/independent variable(s)

    [stat_inco] = ft_freqstatistics(cfg, YG_perf, OG_perf);
    
    
    
