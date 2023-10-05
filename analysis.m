%-------------------------------------------%
% Grand-average and stats for NIMH data     %
%-------------------------------------------%

%% Read data
% cd to relevant folders or add tp path
addpath '/Users/anwesha151200/Documents/Dissertation/Power matrices'

subs_old    = {'sub-ON02747','sub-ON02811','sub-ON72082','sub-ON43016','sub-ON41090','sub-ON62003','sub-ON82386','sub-ON88614','sub-ON94856','sub-ON99620','sub-ON84896','sub-ON91906','sub-ON85616','sub-ON08643','sub-ON25939','sub-ON48555','sub-ON89045'}; % change this to add more participants
subs_young  = {'sub-ON05530','sub-ON03748','sub-ON39099','sub-ON08792','sub-ON42107','sub-ON23483','sub-ON40397','sub-ON52083','sub-ON47254','sub-ON56044','sub-ON61373','sub-ON70467','sub-ON73969','sub-ON80038','sub-ON84651','sub-ON86202','sub-ON89475','sub-ON93426','sub-ON95003','sub-ON49080','sub-ON05311','sub-ON80038','sub-ON97504'}; % change this to add more participants

% this creates a structure with data from participants from the 'young' group
for i = 1:length(subs_young)

    load(subs_young{i})
    data_young{i} = datapow;

end

% same, but for 'old' group
for i = 1:length(subs_old)

    load(subs_old{i})
    data_old{i} = datapow;

end


%% Grand averaged data
% compute seperately for young and old
addpath '/Users/anwesha151200/Documents/Research_placement/fieldtrip-20230215/'

cfg = [];
cfg.keepindividual = 'yes'; % to keep data from individual participants

grandavg_young  = ft_freqgrandaverage(cfg, data_young{1},data_young{2},data_young{3},data_young{4},data_young{5},data_young{6},data_young{7},data_young{8},data_young{9},data_young{10},data_young{11},data_young{12},data_young{13},data_young{14},data_young{15},data_young{16},data_young{17},data_young{18},data_young{19},data_young{20},data_young{21},data_young{22},data_young{23}); % grand average data - young group: change this to add more participants
grandavg_old    = ft_freqgrandaverage(cfg, data_old{1},data_old{2},data_old{3},data_old{4},data_old{5},data_old{6},data_old{7},data_old{8},data_old{9},data_old{10},data_old{11},data_old{12},data_old{13},data_old{14},data_old{15},data_old{16},data_old{17});


% plot 'young' data 
figure 
cfg        = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.xlim   = [13 30]; % can choose different ranges 
%cfg.zlim   = [1.91e-28 2.52e-27] 
%cfg.zlim   = [1.39e-28 1.3e-27] theta
%cfg.zlim   = [1.51e-28 3.43e-27] alpha
cfg.zlim = [7.29e-29 3.69e-28]
%cfg.zlim   = [2.48e-29 9.1e-29] gamma
ft_topoplotER(cfg,grandavg_young);

% plot 'old' data
figure
%cfg.zlim   = [1.01e-28 2.89e-27] 
ft_topoplotER(cfg,grandavg_old);


%% Match channels for young and old
% because different channels were removed in each group, channels should be matched in order to calculate a 'diff' matrix 

% young participants
rm_young    = grandavg_young.label(~ismember(grandavg_young.label,grandavg_old.label)) % this will return the channels in the 'old' group that are absent in the 'young' group   

cfg = [];
cfg.channel = {'all','-MLF11','-MLF13','-MLF14','-MLP33','-MLP54','-MLT21','-MLT32','-MLT42','-MRC52','-MRF11','-MRO11','-MRT22', '-MRT32','-MRT33','-MRT42','-MRT51','-MZC01'}; % update to include all channels in rm_young
grandavg_young_rm   = ft_freqgrandaverage(cfg, data_young{1},data_young{2},data_young{3},data_young{4},data_young{5},data_young{6},data_young{7},data_young{8},data_young{9},data_young{10},data_young{11},data_young{12},data_young{13},data_young{14},data_young{15},data_young{16}),data_young{17},data_young{18},data_young{19},data_young{20},data_young{21},data_young{22},data_young{23};
% old participants
rm_old      = grandavg_old.label(~ismember(grandavg_old.label,grandavg_young.label)) % this will return the channels in the 'old' group that are absent in the 'young' group   

cfg = [];
cfg.channel = {'all','-MLF12','-MLF14','-MLF46','-MLO51','-MLO52','-MLT51','-MRC54','-MRO51'}%'-MLF12','-MLF46','-MLO51','-MLO52','-MRC54','-MRO51','-MRT21'}; % update to include all channels in rm_young
cfg.foilim = [30 40]
grandavg_old_2   = ft_freqgrandaverage(cfg, data_old{1},data_old{2},data_old{3},data_old{4},data_old{5},data_old{6},data_old{7},data_old{8},data_old{9},data_old{10},data_old{11},data_old{12},data_old{13},data_old{14},data_old{15},data_old{16},data_old{17});
avg_old = mean(mean(grandavg_old_2.powspctrm))
grandavg_young_2  = ft_freqgrandaverage(cfg, data_young{1},data_young{2},data_young{3},data_young{4},data_young{5},data_young{6},data_young{7},data_young{8},data_young{9},data_young{10},data_young{11},data_young{12},data_young{13},data_young{14},data_young{15},data_young{16}),data_young{17},data_young{18},data_young{19},data_young{20},data_young{21},data_young{22},data_young{23};
avg_young = mean(mean(grandavg_young_2.powspctrm))


% plot average across all channels
cfg         = [];
cfg.channel = {'all'};
cfg.layout = 'CTF275_helmet.mat';
cfg.interactive = 'no'
ft_singleplotER(cfg, grandavg_young_rm, grandavg_old_rm);


cfg.xlim   = [1 4]
cfg.channel = {'all'};
boxplot(cfg,grandavg_young_rm)

%% Create a 'diff' data
% will be used later on, for plotting

grandavg_diff   = grandavg_young_rm; % this is just to have the structure of the data
grandavg_diff.powspctrm =  grandavg_old_rm.powspctrm - grandavg_young_rm.powspctrm ; % replace the powspctrm with a 'diff' powerspctrm


% plot the diff between young and old
figure 
cfg        = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.xlim   = [13 30]; % can change this
%cfg.zlim = [9.18e-29 9.18e-28] delta
%cfg.zlim = [-9.98e-29 9.98e-28] theta
%cfg.zlim = [-2.21e-28 2.21e-27] alpha
cfg.zlim = [-9.05e-29 9.05e-28]
%cfg.zlim = [-1.6e-29 1.6e-29] gamma
ft_topoplotER(cfg,grandavg_diff); % note that here we're plotting the 'diff' matrix

%rm= grandavg_old_rm.label(~ismember(grandavg_old_rm.label,grandavg_young_rm.label))
%rm2    = grandavg_young_rm.label(~ismember(grandavg_young_rm.label,grandavg_old_rm.label))

%% Stats
%Run an independent sample t-test to compare young and older adults

cfg = [];
cfg.layout           = 'CTF275_helmet.mat';
cfg.avgoverfreq      = 'yes';       % average across freqs given in cfg.frequency
cfg.parameter        = 'powspctrm';
cfg.frequency        = [30 40];      % can change this to look at other freqs
cfg.method           = 'stats';
cfg.statistic        = 'ttest2';    % independent-sample t-test
cfg.avgoverchan = 'yes'
cfg.design           = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2]; % this is the design matrix for the analysis. currenly includes 24 young participants (1) and 16 old participants (2). needs to be changed when more participants are added 
stat = ft_freqstatistics(cfg, data_young{1},data_young{2},data_young{3},data_young{4},data_young{5},data_young{6},data_young{7},data_young{8},data_young{9},data_young{10},data_young{11},data_young{12},data_young{13},data_young{14},data_young{15},data_young{16},data_young{17},data_young{18},data_young{19},data_young{20},data_young{21},data_young{22},data_young{23}, ...
    data_old{1},data_old{2},data_old{3},data_old{4},data_old{5},data_old{6},data_old{7},data_old{8},data_old{9},data_old{10},data_old{11},data_old{12},data_old{13},data_old{14},data_old{15},data_old{16},data_old{17});

% change this to add more participants

% plot the results 
figure 
cfg        = [];
cfg.layout           = 'CTF275_helmet.mat';
cfg.xlim             = [13 30]; % this should match the analysis. ie if stat was calculated for [9 11] the diff plot shuold also be for [9 11] 
cfg.highlight        = 'on';
%cfg.highlightchannel = stat.label(stat.mask==1); % use this to highlight all channels that are significant at p<.05
cfg.highlightchannel = stat.label(stat.prob<0.05); % use this to change the threshold (correction for multiple comparisons) 
ft_topoplotER(cfg,grandavg_diff); % note that we're still plotting the 'diff' matrix, but this time we also highlight channels where differences were significant

avg = mean(mean(grandavg_old_2.powspctrm))

