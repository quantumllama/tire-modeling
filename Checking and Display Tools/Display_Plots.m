% setup
% RAW = load('C:\Users\Michael\Documents\College\GMS\Tires\R6 Data\RawData_13inch_Cornering_Matlab_SI\B1654raw8.mat');

sweepnum = 3;
% ind = rawsplits_b(sweepnum):rawsplits_f(sweepnum+1);
%rawind = rawsplits_b2(sweepnum):rawsplits_f2(sweepnum+1);
ind = [1:numel(RAW.ET)];

% plots
figure('Name','Sweep ','NumberTitle','off')
subplot(3,2,1)
plot(RAW.ET(ind),RAW.FZ(ind),'.')
title('FZ')

subplot(3,2,2)
plot(RAW.ET(ind),RAW.V(ind),'.')
title('V')

subplot(3,2,3)
plot(RAW.ET(ind),RAW.FY(ind),'.')
title('FY')

subplot(3,2,4)
plot(RAW.ET(ind),RAW.SA(ind),'.')
title('SA')

subplot(3,2,5)
plot(RAW.ET(ind),RAW.IA(ind),'.')
title('IA')

subplot(3,2,6)
plot(RAW.ET(ind),RAW.P(ind),'.')
title('P')

% subplot(3,4,3)
% plot(RAW.ET(rawind),RAW.FZ(rawind),'.')
% title('FZ')
% 
% subplot(3,4,4)
% plot(RAW.ET(rawind),RAW.V(rawind),'.')
% title('V')
% 
% subplot(3,4,7)
% plot(RAW.ET(rawind),RAW.FY(rawind),'.')
% title('FY')
% 
% subplot(3,4,8)
% plot(RAW.ET(rawind),RAW.SA(rawind),'.')
% title('SA')
% 
% subplot(3,4,11)
% plot(RAW.ET(rawind),RAW.IA(rawind),'.')
% title('IA')
% 
% subplot(3,4,12)
% plot(RAW.ET(rawind),RAW.P(rawind),'.')
% title('P')
