% Display SA vs. FY sweeps with temp color data

%%%% Define some stuff
tiresfolder = 'C:\Users\Michael\Documents\College\!!SAE\!Suspension\Design\Tires\R6 Processed\Hoosier 20.5 x 7.0 13 R25B A2500 (Item 43163), 7 inch rim\Transients\Data';
sweepnum = 5;
dotsz = 25;
%%%%

DATA = load(sprintf('%s\\Sweep %d.mat', tiresfolder, sweepnum));

plotinner = subplot(1,3,1);
scatter(plotinner,SA,FY,dotsz,TSTI)
title(SAvFY, TSTI)

plotcenter = subplot(1,3,2);
scatter(plotcenter,SA,FY,dotsz,TSTC)
title(SAvFY, TSTC)

plotouter = subplot(1,3,3);
scatter(plotouter,SA,FY,dotsz,TSTO)
title(SAvFY, TSTO)