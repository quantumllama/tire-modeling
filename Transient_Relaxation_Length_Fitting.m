% SPLIT CURVES AT TOP .9 and bottom .15 each side of plateau
% fit curve to single sweep (Sweep 10)
% then broaden to all sweeps

plot1ind2 = find(FY/max(FY) > 0.9, 1)
plot1ind1 = find(FY/max(FY) < 0.1 & D < D(plot1ind2), 1, 'last')

plot2ind1 = find(FY/max(FY) > 0.95, 1, 'last')
plot2ind2 = find(FY/max(FY) < 0.15 & D > D(plot2ind1), 1)

x1 = D(plot1ind1:plot1ind2)
y1 = FY(plot1ind1:plot1ind2)

x2 = D(plot2ind1:plot2ind2)
y2 = FY(plot2ind1:plot2ind2)

curve1 = fit(x1,y1,'poly2')

curve2 = fit(x2,y2,'poly2')
figure
subplot(2,1,1)
plot(curve1,x1,y1)

subplot(2,1,2)
plot(curve2,x2,y2)