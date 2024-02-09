%% initialise

% start up fieldtrip
addpath .../fieldtrip-20200819;
ft_defaults

% path to script
addpath .../scripts;

% path to templates
addpath .../templates;

%% define paths and variables

inpath = dir(''); 
inpath(1:2)=[];

outpath = '.../outcomes'; 
cd(outpath)

condition = {'correct' 'incorrect'}; 
 
for sub = 1:size(inpath,1)

    %% creatingdatasetsMEMTACS 
            % read and convert data from BrainVision .vhdr into Fieldtrip

    cfg                 = [];                
    cfg.dataset         = strcat(inpath(sub).folder,'/',inpath(sub).name,'/EEG/', inpath(sub).name,'_',blocks{blo},'.vhdr') 
    cfg.event = ft_read_event(cfg.dataset);
    data_raw            = ft_preprocessing(cfg);


    %% manual channel rejection                                            

    % manually select bad channels

    cfg            = [];
    cfg.viewmode   = 'vertical';
    cfg.ylim       = [-50 50];
    artf           = ft_databrowser(cfg, data_raw);

    artf.badchannel = input('write badchannels: ');
    artf.badEOG     = input('write badEOG: ');

    % manually write bad channel names as strings in cell-array
    % (e.g., {'FC5'} in command window
    % artif.misschannel = input('write missed channels: ');

    if strcmpi('Vo', artf.badEOG)
       cfg          = [];
       cfg.channel  = {'all', '-Vo'};
       data_raw    = ft_selectdata(cfg, data_raw);
       disp('Vo is removed')
    end   
  %% Channel Interpolation      

    % Prepare neighbouring channels

    cfg               = [];
    cfg.method        = 'template' % 'distance', 'triangulation';
    cfg.template      = 'MEMTACS32ch-avg_neighb.mat';
%                 cfg.neighbourdist = number; % maximum distance between neighbouring sensors (only for 'distance')
    cfg.channel       = artf.badchannel;
    %cfg.feedback      = 'yes'; % default = 'no'
    %cfg.elec          = ft_read_sens('easycap-M1.txt');
    neighbours        = ft_prepare_neighbours(cfg, data_raw); % with an input data structure with the channels of interest and that contains a sensor description


    % Interpolation

    if length(artf.badchannel) == 0

    cfg                 = [];
    cfg.method          = 'weighted'; % default; other options: 'average', 'spline', 'slap' or 'nan'
    cfg.badchannel      = artf.badchannel;
%                 cfg.missingchannel = artf.misschannel
    cfg.neighbours      = neighbours;
    cfg.trials          = 'all'; % or a selection given as a 1xN vector (default = 'all')
%                 cfg.lambda         = regularisation parameter (default = 1e-5, not for method 'distance')
%                 cfg.order          = order of the polynomial interpolation (default = 4, not for method 'distance')
    cfg.elec            = ft_read_sens('easycap-M1.txt'); % read electrode positions
    data_chan           = ft_channelrepair(cfg, data_raw);

    elseif length(artf.badchannel) == 1

    cfg                 = [];
    cfg.method          = 'weighted'; % default; other options: 'average', 'spline', 'slap' or 'nan'
    cfg.badchannel      = artf.badchannel(1);
%                 cfg.missingchannel = artf.misschannel
    cfg.neighbours      = neighbours;
    cfg.trials          = 'all'; % or a selection given as a 1xN vector (default = 'all')
%                 cfg.lambda         = regularisation parameter (default = 1e-5, not for method 'distance')
%                 cfg.order          = order of the polynomial interpolation (default = 4, not for method 'distance')
    cfg.elec            = ft_read_sens('easycap-M1.txt'); % read electrode positions
    data_chan           = ft_channelrepair(cfg, data_raw);

    elseif length(artf.badchannel) > 1

        cfg                 = [];
        cfg.method          = 'weighted'; % default; other options: 'average', 'spline', 'slap' or 'nan'
        cfg.badchannel      = artf.badchannel(1);
%                     cfg.missingchannel = artf.misschannel
        cfg.neighbours      = neighbours;
        cfg.trials          = 'all'; % or a selection given as a 1xN vector (default = 'all')
%                     cfg.lambda         = regularisation parameter (default = 1e-5, not for method 'distance')
%                     cfg.order          = order of the polynomial interpolation (default = 4, not for method 'distance')
        cfg.elec            = ft_read_sens('easycap-M1.txt'); % read electrode positions
        data_chan           = ft_channelrepair(cfg, data_raw);

        for i = 2:length(artf.badchannel)

        cfg                 = [];
        cfg.method          = 'weighted'; % default; other options: 'average', 'spline', 'slap' or 'nan'
        cfg.badchannel      = artf.badchannel(i);
%                     cfg.missingchannel  = artf.misschannel
        cfg.neighbours      = neighbours;
        cfg.trials          = 'all'; % or a selection given as a 1xN vector (default = 'all')
%                     cfg.lambda         = regularisation parameter (default = 1e-5, not for method 'distance')
%                     cfg.order          = order of the polynomial interpolation (default = 4, not for method 'distance')
        cfg.elec            = ft_read_sens('easycap-M1.txt'); % read electrode positions
        data_chan           = ft_channelrepair(cfg, data_chan);

        end

   end


    %% filtMEMTACS
    %anti-aliasing low-pass filtering on continous data before resampling
    cfg = [];                
    cfg.lpfilter        = 'yes';
    cfg.lpfreq          = 50; % cutoff (for resampled data to sampling rate 500 Hz = 125, for sampling rate 1000 Hz = 250 Hz)
    cfg.lpfiltord       = 550; % transition band 10 Hz(mostly artifact-free until 100 Hz, transition band until 150 Hz)
    cfg.lpfilttype      = 'firws';
    cfg.lpfiltwintype   = 'blackman';
%                cfg.bsfilter = 'yes'; % bandstop filter
%                cfg.bsfreq = [20 30];
   data_filt           = ft_preprocessing(cfg, data_chan);

    %% epoMEMTACS 
    % define trials 

    clear key
        key = readtable(strcat(inpath(sub).folder,'/',inpath(sub).name,'/TOM/', inpath(sub).name,'_TOM_EEG.txt')); % log-file from MemTask
        key = table2array(key(:,1:3));
        cfg                = [];
        cfg.trialdef.key   = key;
        cfg.trialdef.pre   = -1500; % in sample points
        cfg.trialdef.post  = 6500; % in sample points
        cfg.trialfun       = 'MEMTACS'; % ft_trialfun_MEMTACS_earlylate = specific trial-defining function, 1 => early; 2 => late; combines responses with EEG ->  
        cfg.headerfile     = strcat(inpath(sub).folder,'/',inpath(sub).name,'/EEG/', inpath(sub).name,'_',blocks{blo},'.vhdr');
        cfg.datafile       = strcat(inpath(sub).folder,'/',inpath(sub).name,'/EEG/', inpath(sub).name,'_',blocks{blo},'.eeg');
        cfg                = ft_definetrial(cfg); 
        trl                = cfg.trl;


    %re-defining trials, actual epoching, step needed to apply trial structure to
    %data. It must occur before resampling because resampling might "delete" trigger when they are at time point that is not sampled anymore with smaller sampling rate.
    cfg                 = [];
    cfg.trl             = trl;
    data_trial          = ft_redefinetrial(cfg, data_filt); 

    %% artifact rejection of marked trials

    if data_trial.sampleinfo(1) < 1;
        data_trial.sampleinfo(1) = 1;
    end

    cfg = [];
    cfg.artfctdef.xxx.artifact = artf_trls; %.xxx or .trial?
    data_artf = ft_rejectartifact(cfg, data_trial);

    %% resampleMEMTACS
    %resampling to 500 Hz sampling rate
    cfg = [];
    cfg.resamplefs = 500;
    data_resamp           = ft_resampledata(cfg, data_artf);

    %% filtnotchhighMEMTACS and baselineMEMTACS
    %DFT-filtering line-noise (not a real notch filter!) and
    %baseline correcting-demeaning (subtracting mean of epochs, works like high-pass filter (removes slow oscillations), but not a real high-pass filter!)
    cfg           = []; 
%                 cfg.dftfilter = 'yes';
%                 cfg.dftfreq   = 50;
    cfg.demean    = 'yes';
    data_resamp_filt          = ft_preprocessing(cfg, data_resamp);

    save(sprintf('%s_preICA_data.mat', inpath(sub).name), 'data_resamp_filt');

    %% eogrerefMEMTACS
    %rereferencing horizontal EOG into a bipolar channel
    %before ICA
    clear eogh 
    clear eogv
    cfg            = [];         
    cfg.channel    = {'Re', 'Li'};
    cfg.reref      = 'yes';
    cfg.refchannel = 'Re';
    eogh           = ft_preprocessing(cfg, data_resamp_filt);

    %removing other channels 
    cfg              = [];
    cfg.channel      = 'Li';
    eogh             = ft_selectdata(cfg, eogh);
    eogh.label       = {'eogh'};

    %rereferencing vertical EOG into a bipolar channel before
    %ICA

    if find(strcmpi('Vo', artf.badEOG))== 1
        cfg            = [];  
        cfg.channel    = {'Fp1', 'Vu'};
        cfg.reref      = 'yes';
        cfg.refchannel = 'Fp1';
        eogv           = ft_preprocessing(cfg, data_resamp_filt);
    else 

    cfg            = [];  
    cfg.channel    = {'Vo', 'Vu'};
    cfg.reref      = 'yes';
    cfg.refchannel = 'Vo';
    eogv           = ft_preprocessing(cfg, data_resamp_filt);

    end 

    %removing other channels 
    cfg              = [];
    cfg.channel      = 'Vu';
    eogv             = ft_selectdata(cfg, eogv);
    eogv.label       = {'eogv'};

    %% doicaMEMTACS  
    % run ICA  

    clear comp
    cfg              = [];
    cfg.method       = 'runica'; % this is the default and uses the implementation from EEGLAB
    cfg.demean       = 'yes';
    cfg.numcomponent = 28;
    comp             = ft_componentanalysis(cfg, data_resamp_filt);

    save(sprintf('%s_comp.mat', inpath(sub).name), 'comp')

    % compute correlations of 28 components with vEOG and hEOG
       for tr = 1:length(comp.trialinfo)
                if tr == 1
                    eogvtrials = eogv.trial{tr};
                    eoghtrials = eogh.trial{tr};
                    comptrials = comp.trial{tr};

                else
                    eogvtrials = horzcat(eogvtrials,eogv.trial{tr});
                    eoghtrials = horzcat(eoghtrials,eogh.trial{tr});
                    comptrials = cat(2,comptrials,comp.trial{tr});
                end
       end

       for c = 1:28
            Rv = corrcoef(eogvtrials,comptrials(c,:)); %compute coefficient for each trial for each component
            VR(c) = Rv(1,2);

            Rh = corrcoef(eoghtrials,comptrials(c,:)); %compute coefficient for each trial for each component
            HR(c) = Rh(1,2);               

        end

%             VR = mean(VR, 'omitnan'); % average correlation coefficient across trials
%             HR = mean(HR, 'omitnan'); % average correlation coefficient across trials

        % vector of components to remove, indexes
        recompV = find(abs(VR) > 0.3); % note the conversion to absolute values; correlations can be positive or negative, but polarity is not interesting here.
        recompH = find(abs(HR) > 0.3);           
        recomp = horzcat(recompV, recompH);
        recomp = transpose(unique(recomp));

        cfg                    = [];
        cfg.component          = recomp; % to be removed component(s)
        cfg.demean             = 'no';
        data_rejcomp           = ft_rejectcomponent(cfg, comp, data_resamp_filt);


        %% eogreref2MEMTACS
        %rereferencing horizontal EOG into a bipolar channel
        %after EOG-component rejection (to compare with before ICA
        %to check if ICA worked)
        clear eogh 
        clear eogv
        cfg            = [];         
        cfg.channel    = {'Re', 'Li'};
        cfg.reref      = 'yes';
        cfg.refchannel = 'Re';
        eogh           = ft_preprocessing(cfg, data_rejcomp); % this is eog after ICA

        %removing other channels 
        cfg              = [];
        cfg.channel      = 'Li';
        eogh           = ft_selectdata(cfg, eogh);
        eogh.label       = {'eogh'};

        %rereferencing vertical EOG into a bipolar channel after
        %EOG-component rejection

        if find(strcmpi('Vo', artf.badEOG))== 1
            cfg            = [];  
            cfg.channel    = {'Fp1', 'Vu'};
            cfg.reref      = 'yes';
            cfg.refchannel = 'Fp1';
            eogv           = ft_preprocessing(cfg, data_rejcomp);
        else 

        cfg            = [];  
        cfg.channel    = {'Vo', 'Vu'};
        cfg.reref      = 'yes';
        cfg.refchannel = 'Vo';
        eogv           = ft_preprocessing(cfg, data_rejcomp);

        end 

        %removing other channels 
        cfg              = [];
        cfg.channel      = 'Vu';
        eogv             = ft_selectdata(cfg, eogv);
        eogv.label       = {'eogv'};

        %discard unipolar eog channels from main data structure

        cfg              = [];
        cfg.channel      = {'all', '-Re', '-Li', '-Vo', '-Vu'}; %transpose(data.label(5:32));
        data             = ft_selectdata(cfg, data_rejcomp);

        %append bipolar eog channels to main data structure
        cfg  = [];
        data = ft_appenddata(cfg, data, eogv, eogh);

        save(sprintf('%s_pruned_data.mat', inpath(sub).name), 'data');

        %% artrejMEMTACS

        trl2=zeros(size(data.sampleinfo,1),5);
        trl2(:,1:2)=data.sampleinfo;
        trl2(:,3)=-1500;
        trl2(:,4:5)=data.trialinfo;

        cfg  = [];
        cfg.trl                           = trl2;
        cfg.continuous                    = 'no';
        cfg.artfctdef.threshold.channel   = data.label;
        cfg.artfctdef.threshold.bpfilter  = 'no';
        cfg.artfctdef.threshold.min       = -150;
        cfg.artfctdef.threshold.max       = 150;
        [~, artData]                    = ft_artifact_threshold(cfg, data);


        cfg  = [];
%                 cfg.artfctdef.feedback = 'yes'
        cfg.artfctdef.xxx.artifact = artData;     
        data = ft_rejectartifact(cfg, data);


        %% log number of rejected trials

        if isfile('rejected_trials_new.mat')
        load ('rejected_trials_new.mat', 'rejectedtrial_task');
        rejectedtrial_task(sub, 1) = 192 - length(data.trial); %rejected trial overall
        rejectedtrial_task(sub, 2) = sum(trl(:,4) == 1) - sum(data.trialinfo(:, 1) == 1); %rejected correct trials
        rejectedtrial_task(sub, 3) = sum(trl(:,4) == 2) - sum(data.trialinfo(:, 1) == 2); %rejected incorrect trials
        else
        rejectedtrial_task(sub, 1) = 192 - length(data.trial); %rejected trial overall
        rejectedtrial_task(sub, 2) = sum(trl(:,4) == 1) - sum(data.trialinfo(:, 1) == 1); %rejected correct trials
        rejectedtrial_task(sub, 3) = sum(trl(:,4) == 2) - sum(data.trialinfo(:, 1) == 2); %rejected incorrect trials
        end

        save('rejected_trials.mat', 'rejectedtrial_task');


        %% CSDMEMTACS
        %calculating Current Source Density

        cfg.method =  'spline';
        cfg.elec   = ft_read_sens('easycap-M1.txt');
        data_csd   = ft_scalpcurrentdensity(cfg, data);

        % save preprocessing

        save (sprintf('%s_%s_preproc.mat', inpath(sub).name, blocks{blo}), 'data', 'data_artf', 'artf', 'data_csd', 'trl', 'trl2', 'comp', 'recomp');

end                                         
    