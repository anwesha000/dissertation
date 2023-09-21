addpath '/Users/anwesha151200/Documents/Research_placement/fieldtrip-20230215/'
addpath '/Users/anwesha151200/Documents/Research_placement/Subject'
ft_defaults

%Pre-processing: Reading the data
%read continuous data and segment into epochs
cfg = []
cfg.dataset= '/Users/anwesha151200/Documents/Research_placement/Subject/sub-ON72409_ses-01_task-rest_run-01_meg.ds';
cfg.continuous = 'yes';
cfg.channel = {'MEG'};
data = ft_preprocessing(cfg)
cfg         = [];
cfg.length  = 2;
cfg.overlap = 0.5;
data        = ft_redefinetrial(cfg, data);

%removing DC component & zero segments
cfg        = [];
cfg.demean = 'yes';
cfg.trials = 1:(numel(data.trial)-6);
data       = ft_preprocessing(cfg, data);

%rejecting bad trials/channels based on visual inspection
cfg         = [];
cfg.method  = 'summary';
cfg.channel = 'MEG';
cfg.layout  = 'CTF275.lay';
dataclean   = ft_rejectvisual(cfg, data);

%identifying & rejecting trial numbers
trlind = [];
for i=1:length(dataclean.cfg.artfctdef.summary.artifact)
  badtrials(i) = find(data.sampleinfo(:,1)==dataclean.cfg.artfctdef.summary.artifact(i));
end
disp(badtrials);

%speeding up component analysis by downsampling data
dataclean.time(1:end) = dataclean.time(1);
cfg            = [];
cfg.resamplefs = 100;
cfg.detrend    = 'yes';
datads         = ft_resampledata(cfg, dataclean);

%Using ICA to identify cardiac and blink components in dataset
cfg                 = [];
cfg.method          = 'runica';
cfg.runica.maxsteps = 50;
comp                = ft_componentanalysis(cfg, datads);

%visualizing the identifies bad components
badcomp = [2 6 8 15 17 29 35 39]; 
cfg            = [];
cfg.channel    = badcomp;
cfg.layout     = 'CTF275_helmet.mat';
cfg.compscale  = 'local';
cfg.continuous = 'yes';
ft_databrowser(cfg, comp);

cfg           = [];
cfg.component = badcomp;
dataica       = ft_rejectcomponent(cfg, comp);

%rejecting bad components
cfg            = [];
cfg.component  = badcomp;
dataica        = ft_rejectcomponent(cfg, comp);

%Spectral analysis
% compute the power spectrum
cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmfft';
cfg.taper        = 'dpss';
cfg.tapsmofrq    = 1;
cfg.keeptrials   = 'no';
datapow          = ft_freqanalysis(cfg, dataica);

load ctf275_neighb

dataicatmp      = dataica;
dataicatmp.grad = data.grad;
cfg               = [];
cfg.neighbours    = neighbours;
cfg.planarmethod  = 'sincos';
planar            = ft_megplanar(cfg, dataicatmp);
clear dataicatmp;

% compute the power spectrum
cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmfft';
cfg.taper        = 'dpss';
cfg.tapsmofrq    = 1;
cfg.keeptrials   = 'no';
datapow_planar   = ft_freqanalysis(cfg, planar);

figure; %??

cfg        = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.xlim   = [4 8];
subplot(2,2,1); ft_topoplotER(cfg, datapow);
%subplot(2,2,2); ft_topoplotER(cfg, ft_combineplanar([], datapow_planar));

cfg         = [];
cfg.channel = {'MRO22', 'MRO32', 'MRO33'};
subplot(2,2,3); ft_singleplotER(cfg, datapow);

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'MEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:2:30;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
TFRhann = ft_freqanalysis(cfg, dataclean);

cfg = [];
cfg.baseline     = [-0.5 -0.1];
cfg.baselinetype = 'absolute';
cfg.zlim         = [-2.5e-27 2.5e-27];
cfg.showlabels   = 'yes';
cfg.layout       = 'CTF275_helmet.mat';
cfg.colorbar     = 'yes';
figure
ft_multiplotTFR(cfg, TFRhann);

cfg = [];
cfg.baseline     = [-0.5 -0.1];
cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'saturation';
cfg.zlim         = [-2.5e-27 2.5e-27];
cfg.channel      = 'MRC15';
cfg.layout       = 'CTF275_helmet.mat';
figure
ft_singleplotTFR(cfg, TFRhann);


grandavg_young  = ft_freqgrandaverage(cfg, data_young{1}, data_young{2}, data_young{3}, data_young{4}, data_young{5},data_young{6},data_young{7},data_young{8},data_young{9},data_young{10},data_young{11},data_young{12},data_young{13},data_young{14},data_young{15},data_young{16},data_young{17},data_young{18},data_young{19},data_young{20},data_young{21},data_young{22},data_young{23},data_young{24}); % grand average data - young group: change this to add more participants
grandavg_old    = ft_freqgrandaverage(cfg, data_old{1}, data_old{2}, data_old{3}, data_old{4}, data_old{5}, data_old{6}, data_old{7}, data_old{8}, data_old{9}, data_old{10}, data_old{11}, data_old{12}, data_old{13}, data_old{14}, data_old{15}, data_old{16}); % grand average data - old group: change this to add more participants

'MRO22', 'MRO32', 'MRO33'