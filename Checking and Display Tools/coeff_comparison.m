%%%% define some stuff
tiresfolder = 'C:\Users\Michael\Documents\College\!!SAE\!Suspension\Design\Tires\R6 Processed\Hoosier 20.5 x 7.0 13 R25B A2500 (Item 43163), 7 inch rim\Test Fitting';
Fzo = 250; % nominal FZ, in lbs
pio = 12; % nominal P, in psi
%%%%

Fzo = Fzo * 0.453592 * 9.806; % Fzo to kg and then N
pio = pio * 6.89476; % pio to kPa

% load data to be displayed
data = load(sprintf('%s\\Data\\aSweep 1', tiresfolder));

% set fig size as 1920x1080 and hold
f = figure('Position',[0 0 1920 1080]);
hold on;
title(sprintf('Sweep 1: FZ=%0.1f, P=%0.1f, V=%0.1f, IA=%0.1f', data.avgFZ, data.avgP, mean(data.V), data.avgIA))

% iterate the data over every set of coeffs to see accuracy
cd(fullfile(tiresfolder,'Data'));
sweeps = size(ls('aSweep *.mat'),1);
colors = prism(sweeps);
linestyle = {'-','--',':'};
for sweepnum = 1:sweeps
    load(sprintf('%s\\Data\\aSweep %d', tiresfolder, sweepnum));
    curve = Pacejka_fulleqn(Pfit.vals.all,data.SA,data.avgFZ,data.dfz,data.dpi,data.avgIA);
    
    figure(f)
    plot(data.SA,curve,'color',colors(sweepnum,:),'LineStyle',linestyle{1+floor(sweepnum/7)},'DisplayName', num2str(sweepnum))
end

legend('show');
