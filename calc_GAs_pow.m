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

%% GA all trials YG

for sub = 1:size(inpathYG,1)
    
    load(sprintf('%s_TOM_alltrls_pow.mat', inpathYG(sub).name))
    
    % Average over trials and write in Grandav variable for YG
   
    cfg = [];
    cfg.keeptrials = 'no';
    aTFRwave = ft_freqdescriptives(cfg, aTFRwave);

    Grandav(sub).aTFRwave = aTFRwave;
   
end

% GA all trials YG

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all'; % early: 0.1-2.9 late: 3.1-5.9
cfg.channel        = 'all';                     
cfg.parameter      = 'powspctrm';% 'crsspctrm'

grandavgYG = ft_freqgrandaverage(cfg, Grandav.aTFRwave);

save('GAPOW_YG', 'grandavgYG', '-v7.3');

clear Grandav grandavgYG

%% GA correct and incorrect trials YG

for cond = 1:2
    
    for sub = 1:size(inpathYG,1)
        
        if isfile(sprintf('.../%s_TOM_correct_trls_pow.mat', inpathYG(sub).name)) && isfile(sprintf('.../%s_TOM_incorrect_trls_pow.mat', inpathYG(sub).name))
    
        load(sprintf('.../%s_TOM_%s_trls_pow.mat', inpathYG(sub).name, condition{cond}), 'aTFRwave');
        
        cfg = [];
        cfg.keeptrials = 'no';
        aTFRwave = ft_freqdescriptives(cfg, aTFRwave);
        
            if sub == 1
            Grandav(1).aTFRwave = aTFRwave;
            else
            Grandav(end+1).aTFRwave = aTFRwave;
            end
            
        end
    end

    cfg = [];
    cfg.keepindividual = 'yes';
    cfg.foilim         = 'all';
    cfg.toilim         = 'all'; % early: 0.1-2.9 late: 3.1-5.9
    cfg.channel        = 'all';                     
    cfg.parameter      = 'powspctrm';% 'crsspctrm'

    grandavg = ft_freqgrandaverage(cfg, Grandav.aTFRwave);

    save(sprintf('GAPOW_YG_%s', condition{cond}), 'grandavg', '-v7.3');
    
    clear Grandav grandavg
    
end

%% Difference GAs correct and incorrect YG

load('GAPOW_YG_correct.mat')
grandavg_co = grandavg;

load('GAPOW_YG_incorrect.mat')
grandavg_inco = grandavg;

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
YG_diff = ft_math(cfg, grandavg_co, grandavg_inco); % co-inco

save('GAs_diff.mat', 'YG_diff', '-v7.3');

clear grandavg grandavg_co grandavg_inco YG_diff

%% GA all trials OG

for sub = 1:size(inpathOG,1)
    
    load(sprintf('%s_TOM_alltrls_pow.mat', inpathOG(sub).name))
    
    % Average over trials and write in Grandav variable for OG
   
    cfg = [];
    cfg.keeptrials = 'no';
    aTFRwave = ft_freqdescriptives(cfg, aTFRwave);

    Grandav(sub).aTFRwave = aTFRwave;
   
end

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all'; % early: 0.1-2.9 late: 3.1-5.9
cfg.channel        = 'all';                     
cfg.parameter      = 'powspctrm';% 'crsspctrm'

grandavgOG = ft_freqgrandaverage(cfg, Grandav.aTFRwave);

save('GAPOW_OG', 'grandavgOG', '-v7.3');

clear Grandav grandavgOG

%% GA correct and incorrect trials OG

for cond = 1:2
    
    for sub = 1:size(inpathOG,1)
    
        load(sprintf('%s_TOM_%s_trls_pow.mat', inpathOG(sub).name, condition{cond}), 'aTFRwave');
        
        cfg = [];
        cfg.keeptrials = 'no';
        aTFRwave = ft_freqdescriptives(cfg, aTFRwave);

        Grandav(sub).aTFRwave = aTFRwave;
                    
    end
    
    cfg = [];
    cfg.keepindividual = 'yes';
    cfg.foilim         = 'all';
    cfg.toilim         = 'all'; % early: 0.1-2.9 late: 3.1-5.9
    cfg.channel        = 'all';                     
    cfg.parameter      = 'powspctrm';% 'crsspctrm'

    grandavg = ft_freqgrandaverage(cfg, Grandav.aTFRwave);

    save(sprintf('GAPOW_OG_%s', condition{cond}), 'grandavg', '-v7.3');
    
    clear Grandav grandavg
    
end

%% Difference GAs correct and incorrect OG

load('GAPOW_OG_correct.mat')
grandavg_co = grandavg;

load('GAPOW_OG_incorrect.mat')
grandavg_inco = grandavg;

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
OG_diff = ft_math(cfg, grandavg_co, grandavg_inco); % co-inco

save('GAs_diff.mat', 'OG_diff', '-append', '-v7.3');

clear grandavg grandavg_co grandavg_inco OG_diff

%% GA correct and incorrect (both groups)

for cond = 1:2
    
    for sub = 1:size(inpathYG,1)
        
        clear aTFRwave
        
        if isfile(sprintf('.../YG/outcomes/%s_TOM_correct_trls_pow.mat', inpathYG(sub).name)) && isfile(sprintf('.../YG/outcomes/%s_TOM_incorrect_trls_pow.mat', inpathYG(sub).name))
        
            load(sprintf('.../YG/outcomes/%s_TOM_%s_trls_pow.mat', inpathYG(sub).name, condition{cond}), 'aTFRwave');

            cfg = [];
            cfg.keeptrials = 'no';
            aTFRwave = ft_freqdescriptives(cfg, aTFRwave);

            if sub == 1
                Grandav(1).aTFRwave = aTFRwave;

            else
                Grandav(end+1).aTFRwave = aTFRwave;
            end
        
        end
    end
    
    for sub = 1:size(inpathOG,1)
        
        clear aTFRwave
        
        load(sprintf('.../OG/outcomes/%s_TOM_%s_trls_pow.mat', inpathOG(sub).name, condition{cond}), 'aTFRwave');
        
        cfg = [];
        cfg.keeptrials = 'no';
        aTFRwave = ft_freqdescriptives(cfg, aTFRwave);

        Grandav(end+1).aTFRwave = aTFRwave; 
        
    end
    
    cfg = [];
    cfg.keepindividual = 'yes';
    cfg.foilim         = 'all';
    cfg.toilim         = 'all'; % early: 0.1-2.9 late: 3.1-5.9
    cfg.channel        = 'all';                     
    cfg.parameter      = 'powspctrm';% 'crsspctrm'

    grandavg = ft_freqgrandaverage(cfg, Grandav.aTFRwave);

    save(sprintf('GAPOW_%s', condition{cond}), 'grandavg', '-v7.3');
    
    clear Grandav grandavg
    
end