% loads data from Sweep # and plots it

%%%% define stuff
tiresfolder = 'C:\Users\Michael\Desktop\Tires\R6 Processed\Hoosier 20.5 x 7.0 13 R25B A2500 (Item 43163), 7 inch rim';
datatype = 'Transients';
sweep = 9;
%%%%

load(sprintf('%s\\%s\\Data\\Sweep %d', tiresfolder, datatype, sweep));

% plots FZ, V, FY, SA, IA, and P
figure('Name','Sweep ','NumberTitle','off')
subplot(3,2,1)
plot(ET,FZ,'.')
title('FZ')

subplot(3,2,2)
plot(ET,V,'.')
title('V')

subplot(3,2,3)
plot(ET,FY,'.')
title('FY')

subplot(3,2,4)
plot(ET,SA,'.')
title('SA')

subplot(3,2,5)
plot(ET,IA,'.')
title('IA')

subplot(3,2,6)
plot(ET,TSTC,'.')
title('P')