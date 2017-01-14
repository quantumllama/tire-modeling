% transient tire relaxation length examination
% setup of test is 3 rounds of SA sweeps at different P, each round
% consists of many sweeps at different FZ and max SA
% sweeps are split with a small gap in time, leaving steady state
% conditions before and after the sweep, therefore raw data is unnecessary
%%%% setup - direct load to where the data is, direct the save folder to
%%%% where you want the data saved, ensure in that folder, there are two
%%%% other folders called "Data" and "Figures"
RUN = load('C:\Users\Michael\Documents\GMS\R6 Data\RunData_13inch_Cornering_Matlab_SI\B1654run8.mat');
savefolder = 'C:\Users\Michael\Documents\GMS\R6 Processed\Hoosier 20.5x7 13 R25B A2500\Transients\';
%%%%

% split sweeps by using rundata
dif = diff(RUN.ET);
tempsplits_f = find(dif>1);
tempsplits_b = [1; tempsplits_f + 1]; % creates beginning splits
tempsplits_f(numel(tempsplits_f)+1) = numel(RUN.ET); % creates final end split

% if SA does not change by at least 0.5 over the sweep, remove that sweep
n = 1;
splits = {};
for i = 1:numel(tempsplits_f)
    maxSA = max(RUN.SA(tempsplits_b(i):tempsplits_f(i))); % find max SA of each split
    minSA = min(RUN.SA(tempsplits_b(i):tempsplits_f(i)));
    if maxSA > 0.5 || minSA < -0.5  % if SA changes, add the split to another array
        splits{n,1} = (tempsplits_b(i):tempsplits_f(i))';
        n = n + 1;
    end
end

num_of_splits = numel(splits);

% find distance traveled, V in kph, ET in sec
% (V*1000)*deltaET/3600)=V*1/360
RUN.D = zeros(numel(RUN.ET),1);
RUN.D(1) = RUN.V(1)/360;
for i = 2:numel(RUN.ET)
    RUN.D(i) = RUN.D(i-1) + RUN.V(i)/360;
end
% adds D as a field and unit for RUN struct
RUN.channel.name{1,23} = 'D';
RUN.channel.units{1,23} = 'm';

% plot each sweep, D and ET vs. FY,SA,V; giving a header with sweep num and avg FZ,P
for i = 1:num_of_splits
%     create new struct SAV, to hold current sweep data to save to new file
%     manually add some of the data
    SAV.source = RUN.source;
    SAV.channel = RUN.channel;
    SAV.tireid = RUN.tireid;
    SAV.testid = RUN.testid;
    for j = 1:numel(RUN.channel.name) % add all sweep data to SAV and create new struct AVGS
        k = char(RUN.channel.name(1,j));
        SAV.(k) = RUN.(k)(splits{i,1}); 
        AVGS.(k) = mean(SAV.(k)); % new AVGS(i) struct where i is Sweep # that holds 
    end
    
%     save sweep data to a new file at location saveto, named by sweep
    datafile = fullfile(savefolder, 'Data', sprintf('Transient Sweep %d', i));
    figfile = fullfile(savefolder, 'Figures', sprintf('Transient Sweep %d', i));
    save(datafile, '-struct', 'SAV');
    save(datafile, 'AVGS', '-append');
    
%     title(sprintf('Sweep %d: SA=%d, FZ=%d, P=%d', i, max(SAV.SA), AVGS.FZ, AVGS.P))
    x = SAV.D;
    if max(SAV.SA) > 0.5 % in the case that the SA is positive, you get a negative FY
        y = SAV.FY/min(SAV.FY);
    else % in the case that SA is negative, you get a positive FY
        y = SAV.FY/max(SAV.FY);
    end
    
%     fit curve to increase and decrease in lateral force
%     first the cutoff indexes for both curves
    curve1ind2 = find(y > 0.9, 1)
    curve1ind1 = find(y < 0.1 & SAV.D < SAV.D(curve1ind2), 1, 'last')
    curve2ind1 = find(y > 0.95, 1, 'last')
    curve2ind2 = find(y < 0.15 & SAV.D > SAV.D(curve2ind1), 1)
%     x and y axes for curve fitting and graphing
    x1 = SAV.D(curve1ind1:curve1ind2)
    y1 = SAV.FY(curve1ind1:curve1ind2)
    x2 = SAV.D(curve2ind1:curve2ind2)
    y2 = SAV.FY(curve2ind1:curve2ind2)
%     fit curves
    curve1 = fit(x1,y1,'poly2')
    curve2 = fit(x2,y2,'poly2')
    
    figure % plot sweep and each curve fit
    subplot(3,1,1)
    plot(x,y)
    subplot(3,1,2)
    plot(curve1,x1,y1)
    subplot(3,1,3)
    plot(curve2,x2,y2)
    print(figfile, '-dpng') % save the file
end


