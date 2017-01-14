% program intended to split run and raw TTC data into understandable sweeps
% with the goal of creating a Pacjeka model
% still need to incorporate dwells and a loop to save

%%%% define some stuff
tiresfolder = 'C:\Users\Michael\Documents\College\!!SAE\!Suspension\Design\Tires';
runnum = 9;
datatype = 'Transients';
%%%%

% load run data
RUN = load(sprintf('%s\\R6 Data\\RunData_13inch_Cornering_Matlab_SI\\B1654run%d.mat', tiresfolder, runnum));

% define save folder
saveto = sprintf('%s\\R6 Processed\\%s\\%s', tiresfolder, RUN.tireid, datatype);


% Splits curves with Run Data
dif = diff(RUN.ET);
splits_f = find(dif>1); % creates finish splits
splits_b = [1; splits_f + 1]; % creates beginning splits
splits_f(numel(splits_f)+1) = numel(RUN.ET); % adds final finish split

num_of_splits = numel(splits_b);

% converts indexes of 'RunData' splits to time
ET_b = RUN.ET(splits_b);
ET_f = RUN.ET(splits_f);

% load raw data
RAW = load(sprintf('%s\\R6 Data\\RawData_13inch_Cornering_Matlab_SI\\B1654raw%d.mat', tiresfolder, runnum));

% finds the "Raw Data" index at which the splits from 'Run Data' occur
rawsplits_b = find(ismember(RAW.ET,ET_b));
rawsplits_f = find(ismember(RAW.ET,ET_f));

% validation
% splitFY = RAW.FY((rawsplits_b(1)):rawsplits_f(1));
% splitSA = RAW.SA((rawsplits_b(1)):rawsplits_f(1));
% plot(splitSA,splitFY,':b')

% find averages over each split for FZ, P, IA
FZ_avgs = zeros(num_of_splits,1);
P_avgs = zeros(num_of_splits,1);
IA_avgs = zeros(num_of_splits,1);
FZ_stddev = zeros(num_of_splits,1);
P_stddev = zeros(num_of_splits,1);
IA_stddev = zeros(num_of_splits,1);

for i = 1:num_of_splits % creates avgs and std dev for each split
    temp_FZ = RAW.FZ(rawsplits_b(i):rawsplits_f(i));
    temp_P = RAW.P(rawsplits_b(i):rawsplits_f(i));
    temp_IA = RAW.IA(rawsplits_b(i):rawsplits_f(i));
    FZ_avgs(i) = mean(temp_FZ);
    P_avgs(i) = mean(temp_P);
    IA_avgs(i) = mean(temp_IA);
    FZ_stddev(i) = std(temp_FZ);
    P_stddev(i) = std(temp_P);
    IA_stddev(i) = std(temp_IA);
end

% separate case for i=1 to account for no ET_*(0)
for i = 1:num_of_splits  % widen splits to include dwells
%     advance from previous end split until all FZ,P, and IA averages have
%     been hit
    if i-1 ~= 0
        rawsplits_b2(i) = find(RAW.ET>ET_f(i-1) & RAW.FZ-FZ_avgs(i)<FZ_stddev(i) & RAW.P-P_avgs(i)<P_stddev(i) & RAW.IA-IA_avgs(i)<IA_stddev(i),1);
    else
        rawsplits_b2(1) = find(RAW.FZ-FZ_avgs(1)<FZ_stddev(1) & RAW.P-P_avgs(1)<P_stddev(1) & RAW.IA-IA_avgs(1)<IA_stddev(1),1);
    end
    
%     advance from current end split, finding only the last point at which
%     conditions are satisfied
    if i < num_of_splits
        rawsplits_f2(i) = find(RAW.ET>ET_f(i) & RAW.ET<ET_b(i+1) & RAW.FZ-FZ_avgs(i)<FZ_stddev(i) & RAW.P-P_avgs(i)<P_stddev(i) & RAW.IA-IA_avgs(i)<IA_stddev(i),1,'last');
    else
        rawsplits_f2(num_of_splits) = find(RAW.ET>ET_f(num_of_splits) & RAW.FZ-FZ_avgs(num_of_splits)<FZ_stddev(num_of_splits) & RAW.P-P_avgs(num_of_splits)<P_stddev(num_of_splits) & RAW.IA-IA_avgs(num_of_splits)<IA_stddev(num_of_splits),1,'last');
    end
end

% saves figures and variables
channelnames = RAW.channel.name;
for i = 1:num_of_splits
%     create index range for each split
    indstart = rawsplits_b(i);
    indend = rawsplits_f(i);
    
    saveloc = sprintf('%s\\Data\\Sweep %d', saveto, i);
%     adds tire heading data to file
    save(sprintf('%s', saveloc), '-struct', 'RAW', 'source', 'channel', 'tireid', 'testid');
    
% % %     A way to save in a loop, more robust and faster(maybe?), but not
% % %     currently working
%     append = '-append';
%     for j = 1:numel(RAW.channel.name)
%         k = RAW.channel.name{j}
% %         l = sprintf('%s(%d:%d)', k, indstart, indend)
%         eval(sprintf('%s = RAW.%s(%d:%d)', k, k, indstart, indend));
%         eval(sprintf('save(%s, %s, -append)', saveloc, k));
% %         save(sprintf('%s\\Data\\Sweep %d', saveto, i), '-struct', 'RAW', l, '-append'); % adds split range of data to sweep file
%     end
    
%     Save each variable on its own two lines, very long and waste space,
%     please redo
%     First name and assign each variable from RAW.channel.name
    ET = RAW.ET(indstart:indend);
    V = RAW.V(indstart:indend);
    N = RAW.N(indstart:indend);
    SA = RAW.SA(indstart:indend);
    IA = RAW.IA(indstart:indend);
    RL = RAW.RL(indstart:indend);
    RE = RAW.RE(indstart:indend);
    P = RAW.P(indstart:indend);
    FX = RAW.FX(indstart:indend);
    FY = RAW.FY(indstart:indend);
    FZ = RAW.FZ(indstart:indend);
    MX = RAW.MX(indstart:indend);
    MZ = RAW.MZ(indstart:indend);
    NFX = RAW.NFX(indstart:indend);
    NFY = RAW.NFY(indstart:indend);
    RST = RAW.RST(indstart:indend);
    TSTI = RAW.TSTI(indstart:indend);
    TSTC = RAW.TSTC(indstart:indend);
    TSTO = RAW.TSTO(indstart:indend);
    AMBTMP = RAW.AMBTMP(indstart:indend);
    SR = RAW.SR(indstart:indend);
    SL = RAW.SL(indstart:indend);
    
%     Then save them all
    save(sprintf('%s', saveloc), 'ET','V','N','SA','IA','RL','RE','P','FX','FY','FZ','MX','MZ','NFX','NFY','RST','TSTI','TSTC','TSTO','AMBTMP','SR','SL','-append');
    
% %     clear figure window (obvs only happens after first iteration) so only
% %     one figure window pops up when running
%     set(0, 'CurrentFigure', 1);
%     clf reset;
    
%     load some of the data you just saved
    picvars = load(sprintf('%s', saveloc), 'ET', 'FZ', 'SA', 'FY', 'P', 'V', 'IA');
    
%     set fig size as 1920x1080
    f = figure('Position',[0 0 1920 1080]);
    
%     plot FZ, SA, FY vs ET
    figure(f)
    subplot(3,2,1)
    plot(picvars.ET,picvars.FZ)
    title('FZ')
    
    subplot(3,2,3)
    plot(picvars.ET,picvars.SA)
    title('SA')
    
    subplot(3,2,5)
    plot(picvars.ET,picvars.FY)
    title('FY')
    
%     plot FY vs SA to get pacejka curves
%     also display avg FZ, P, V, IA
    subplot(3,2,[2 6])
    plot(picvars.SA,picvars.FY,':.')
    title(sprintf('Sweep %d: FZ=%0.1f, P=%0.1f, V=%0.1f, IA=%0.1f', i, mean(picvars.FZ), mean(picvars.P), mean(picvars.V), mean(picvars.IA)))
    
%     print fig as jpg
    print(sprintf('%s\\Figures\\Sweep %d', saveto, i), '-dpng', '-r0')
end
