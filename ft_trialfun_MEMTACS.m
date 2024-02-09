% by Guglielmo Lucchese

function [trl, event] = trialfun_MEMTACS(cfg)

%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events
hdr        = ft_read_header(cfg.datafile); % datafile defined in preprocessing script
event      = ft_read_event(cfg.datafile);

%% from here on it becomes specific to the experiment and the data format
% for all events, find the sample numbers (these are integers)
% for all events, find the trigger values (these are strings in the case of BrainVision)
EVsample   = [event.sample]'; % sample points of stimulus marker
EVvalue    = {event.value}'; % value/name of stimulus marker
EVsample   = EVsample(3:length(EVsample)); % delete first two rows (no specific stimulus marker)
EVvalue    = EVvalue(3:length(EVvalue));


KEY = cfg.trialdef.key; %=key (info from log-file of task)

goodtrials = sort(vertcat(KEY (:,1), KEY (:, 2))); % stimulus names from logfile are joined together vertically and sorted in ascending order
gtnum = length(goodtrials); % number of trials

for gt = 1:gtnum % for all trials
    
    [gti, gtj] = find(KEY(:,1:2)==goodtrials(gt)); % stimulus name of current trial
    
    if gt == 1
        GTi = gti;
        GTj = gtj;
    else
        GTi = vertcat(GTi, gti);
        GTj = vertcat(GTj, gtj);
    end
    
    
end

clear trialsincorrect
clear trialscorrect
trialsincorrect{1} = '';
trialscorrect{1} = '';


for gt = 1:gtnum
    
    
    if GTj(gt)==1 && isempty(trialsincorrect)==1 && KEY(GTi(gt),GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+2)==99
    
        trialsincorrect{1} = sprintf('S %d', KEY (GTi(gt),GTj(gt)));
        
    elseif GTj(gt)==1 && isempty(trialsincorrect)==1 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+2)==99
        
        trialsincorrect{1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));
          
    elseif GTj(gt)==1 && isempty(trialsincorrect)==0  && KEY(GTi(gt), GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+2)==99
        
        trialsincorrect{length(trialsincorrect)+1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));     
            
    elseif GTj(gt)==1 && isempty(trialsincorrect)==0 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+2)==99
        
        trialsincorrect{length(trialsincorrect)+1} = sprintf('S%d', KEY(GTi(gt),GTj(gt))); 
        
    elseif GTj(gt)==1 && isempty(trialscorrect)==1 && KEY(GTi(gt), GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+2)<99
        
        trialscorrect{1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));
        
    elseif GTj(gt)==1 && isempty(trialscorrect)==1 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+2)<99
        
        trialscorrect{1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));
    
    elseif GTj(gt)==1 && isempty(trialscorrect)==0 && KEY(GTi(gt), GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+2)<99
        
        trialscorrect{length(trialscorrect)+1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));
        
    elseif GTj(gt)==1 && isempty(trialscorrect)==0 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+2)<99
        
        trialscorrect{length(trialscorrect)+1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));
        
              
        
    elseif GTj(gt)>1 && isempty(trialsincorrect)==1 && KEY(GTi(gt),GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+1)==99
    
        trialsincorrect{1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));
        
    elseif GTj(gt)>1 && isempty(trialsincorrect)==1 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+1)==99
        
        trialsincorrect{1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));
          
    elseif GTj(gt)>1 && isempty(trialsincorrect)==0  && KEY(GTi(gt), GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+1)==99
        
        trialsincorrect{length(trialsincorrect)+1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));    
            
    elseif GTj(gt)>1 && isempty(trialsincorrect)==0 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+1)==99
        
        trialsincorrect{length(trialsincorrect)+1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));
        
    elseif GTj(gt)>1 && isempty(trialscorrect)==1 && KEY(GTi(gt), GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+1)<99
        
        trialscorrect{1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));
        
    elseif GTj(gt)>1 && isempty(trialscorrect)==1 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+1)<99
        
        trialscorrect{1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));
    
    elseif GTj(gt)>1 && isempty(trialscorrect)==0 && KEY(GTi(gt), GTj(gt))<100 && KEY(GTi(gt), GTj(gt)+1)<99
        
        trialscorrect{length(trialscorrect)+1} = sprintf('S %d', KEY(GTi(gt),GTj(gt)));
        
    elseif GTj(gt)>1 && isempty(trialscorrect)==0 && KEY(GTi(gt), GTj(gt))>99 && KEY(GTi(gt), GTj(gt)+1)<99
        
        trialscorrect{length(trialscorrect)+1} = sprintf('S%d', KEY(GTi(gt),GTj(gt)));                      
        
    end
   
    
end



% for tc = 1:length(trialscorrect)    
%     retrieving(tc,1) = 1;
%     begsample(tc,1) = EVsample(trialscorrect{tc}) + cfg.trialdef.pre;
%     endsample(tc,1) = EVsample(trialscorrect{tc}) + cfg.trialdef.post;
% end
% 
% for tci = 1:length(trialsincorrect) 
%     retrieving(length(trialscorrect)+tci, 1) = 2;
%     begsample(length(trialscorrect)+tci, 1) = EVsample(trialscorrect{tci}) + cfg.trialdef.pre;
%     endsample(length(trialscorrect)+tci, 1) = EVsample(trialscorrect{tci}) + cfg.trialdef.post;
% end
% 
% 
% % begsample = EVsample(Word) + cfg.trialdef.pre;
% % endsample = EVsample(Word) + cfg.trialdef.post;
% 
% 
% %% the last part is again common to all trial functions
% % return the trl matrix (required) and the event structure (optional)
% trl = [begsample endsample retrieving];


% define trial according to condition; code for the memory retrieving task: 1 => Correct; 2 => Incorrect;
trl = [];
for j = 1:(length(EVvalue));
    marker = str2double(EVvalue{j}(2:4));
  if  ismember(EVvalue(j), trialscorrect) == 1 & ismember(EVvalue(j), trialsincorrect) == 0
    trlbegin = EVsample(j) + cfg.trialdef.pre;      
    trlend   = EVsample(j) + cfg.trialdef.post;      
    offset   = cfg.trialdef.pre; 
    retrieving = 1;
    newtrl   = [trlbegin trlend offset retrieving marker];
    trl      = [trl; newtrl];
  elseif ismember(EVvalue(j), trialscorrect) == 0 & ismember(EVvalue(j), trialsincorrect) == 1
    trlbegin = EVsample(j) + cfg.trialdef.pre;     
    trlend   = EVsample(j) + cfg.trialdef.post;        
    offset   = cfg.trialdef.pre; 
    retrieving = 2;
    newtrl   = [trlbegin trlend offset retrieving marker];
    trl      = [trl; newtrl];    
  end
end



end % function