function fitPacejka()
% fitting a Pacejka tire model to R6 Sweeps
    
    %%%% define some stuff
    tiresfolder = 'C:\Users\Michael\Documents\College\!!SAE\!Suspension\Design\Tires\R6 Processed\Hoosier 20.5 x 7.0 13 R25B A2500 (Item 43163), 7 inch rim\Transients';
    %%%%
    
    % load data
    cd(fullfile(tiresfolder,'Data'));
    sweeps = size(ls('Sweep *.mat'),1)
    for sweepnum = 1:sweeps
        fprintf('Sweep %d', sweepnum)
        
        load(sprintf('%s\\Data\\Sweep %d', tiresfolder, sweepnum));
    
        % find some known initial values
      % Dy
        maxFYindx = find(FY>(max(FY)*.95),1);
        Dy = FY(maxFYindx); % max force
        
      % Cy
        % crude horiz asymptote
        ya = 0.95*mean([abs(FY(find(SA==max(SA),1))) abs(FY(find(SA==min(SA), 1)))]);
        Cy = 1 + (1 - (2/pi)*asin(ya/Dy));
        
      % By
        % indices of the linear part of the graph
        linearPoints = intersect(find(SA>-1),find(SA<1));
        corneringStiffness = fit(SA(linearPoints),FY(linearPoints),'poly1');
        By = corneringStiffness(1)/(Cy*Dy);
        
      % Ey
        xm = SA(maxFYindx); % SA of max force
        Ey = (By*xm - tan(pi/(2*Cy)))/(By*xm - atan(By*xm));
        
      % SVy
        SVy = 0;
        
      % SHy
        SHy = 0;
        x0 = [Dy Cy By Ey SVy SHy];
        
        % fit data
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',3000);
        Pfit = lsqnonlin(@Pacejka,x0,[],[],options,SA,FY);
        Pcurve = Pfit(1)*sin(Pfit(2)*atan(Pfit(3).*(SA+Pfit(6)) - Pfit(4)*(Pfit(3).*(SA+Pfit(6)) - atan(Pfit(3).*(SA+Pfit(6)))))) + Pfit(5);

%         plot(SA,FY,'.r',SA,Pcurve,'b')
        
        save(sprintf('%s\\Data\\Sweep %d', tiresfolder, sweepnum), 'x0', 'Pfit', 'Pcurve', '-append')
%         save(sprintf('%s\\aSweep %d', tiresfolder, sweepnum))
    
%           set fig size as 1920x1080
        f = figure('Position',[0 0 1920 1080]);
    
%           plot FZ, SA, FY vs ET
        figure(f)
        subplot(3,2,1)
        plot(ET,FZ)
        title('FZ')
        
        subplot(3,2,3)
        plot(ET,SA)
        title('SA')
        
        subplot(3,2,5)
        plot(ET,FY)
        title('FY')
    
%           plot FY vs SA and Pacejka curve
%           also display avg FZ, P, V, IA
        subplot(3,2,[2 6])
        plot(SA,FY,'.r',SA,Pcurve,'b')
        title(sprintf('Sweep %d: FZ=%0.1f, P=%0.1f, V=%0.1f, IA=%0.1f', sweepnum, mean(FZ), mean(P), mean(V), mean(IA)))
    
%           print fig as jpg
        print(sprintf('%s\\Figures\\Sweep %d', tiresfolder, sweepnum), '-dpng', '-r0')

%         sweepnum = sweepnum + 1;
    end
end

% set fitting model, Fyo = Dy*sin(Cy*arctan(By*ay - Ey(By*ay - arctan(By*ay)))) + SVy
function diff = Pacejka(x,ay,FY)
    % define your normal variables in terms of x(n)
    Dy = x(1);
    Cy = x(2);
    By = x(3);
    Ey = x(4);
    SVy = x(5);
    SHy = x(6);
    
    % Pacejka fitting model - real FY
    diff = Dy*sin(Cy*atan(By.*(ay+SHy) - Ey*(By.*(ay+SHy) - atan(By.*(ay+SHy))))) + SVy - FY;
end
