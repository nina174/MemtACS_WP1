%% define paths and variables

outpath = ''; 
cd(outpath)

condition = {'correct' 'incorrect'};
group = {'YG' 'OG'};

%%

for cond = 1:2
    
    load(sprintf('GAPOW_%s.mat', condition{cond}))


    cfg.baseline     = [-0.5 -0.1];
    cfg.baselinetype = 'db';
    cfg.parameter    = 'powspctrm';
    grandavg         = ft_freqbaseline(cfg, grandavg);
    
    save(sprintf('GAPOW_%s_BL.mat', condition{cond}), '-v7.3')
    
end

for grp = 1:2
    
    load(sprintf('GAPOW_%s.mat', group{grp}))


    cfg.baseline     = [-0.5 -0.1];
    cfg.baselinetype = 'db';
    cfg.parameter    = 'powspctrm';
    grandavg         = ft_freqbaseline(cfg, grandavg);
    
    save(sprintf('GAPOW_%s_BL.mat', group{grp}), '-v7.3')
    
    for cond = 1:2
        
        load(sprintf('GAPOW_%s_%s.mat', group{grp}, condition{cond}))


        cfg.baseline     = [-0.5 -0.1];
        cfg.baselinetype = 'db';
        cfg.parameter    = 'powspctrm';
        grandavg         = ft_freqbaseline(cfg, grandavg);

        save(sprintf('GAPOW_%s_%s_BL.mat', group{grp}, condition{cond}), '-v7.3')
        
    end
    
end
 
%% Difference GAs correct and incorrect

for grp = 1:2
    
    load(sprintf('GAPOW_%s_correct_BL.mat', group{grp}));
    grandavg_co = grandavg;

    load(sprintf('GAPOW_%s_incorrect_BL.mat', group{grp}));
    grandavg_inco = grandavg;

    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = 'subtract';
    diff = ft_math(cfg, grandavg_co, grandavg_inco); % co-inco

    save(sprintf('GAs_diff_%s_BL.mat',group{grp}), 'diff', '-v7.3');
    
end