function fitPacejka()
% fitting a Pacejka tire model
    
    %%%% define some stuff
    tiresfolder = 'C:\Users\Michael\Documents\College\!!SAE\!Suspension\Design\Tires\R6 Processed\Hoosier 20.5 x 7.0 13 R25B A2500 (Item 43163), 7 inch rim\Test Fitting';
    %%%%
    
    global maincoeffs;
    
    % load data
    cd(fullfile(tiresfolder,'Data'));
    sweeps = size(ls('Sweep *.mat'),1);
    for sweepnum = 1:sweeps
        fprintf('\n\nSweep %d', sweepnum)
        
        load(sprintf('%s\\Data\\Sweep %d', tiresfolder, sweepnum));
        clear Pfit
        
        %% Do some initial fitting with only the main variables that have
        %%% some real world significance
        
        % find some known initial values
        % Dy
        maxFYindx = find(FY>(max(FY)*.95),1);
        Dy = FY(maxFYindx); % max force
        
        % Cy
        % crude horiz asymptote
        ya = 0.95*mean([abs(FY(find(SA==max(SA),1))) abs(FY(find(SA==min(SA), 1)))]);
        Cy = 1 + (1 - (2/pi)*asin(ya/Dy));
        
        % By
        linearPoints = intersect(find(SA>-1),find(SA<1)); % find the indices of the linear part of SA v FY
        corneringStiffness = fit(SA(linearPoints),FY(linearPoints),'poly1'); % fit a first degree poly to find slope
        By = corneringStiffness(1)/(Cy*Dy); % BCD = slope
        
        % Ey
        xm = SA(maxFYindx); % SA of max force
        Ey = (By*xm - tan(pi/(2*Cy)))/(By*xm - atan(By*xm));
        
        % SVy
        SVy = 0;
        
        % SHy
        SHy = 0;
        
        x0simple = [Dy Cy By Ey SVy SHy];
        
        % fit data to simple model
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',3000);
        simpleFit = lsqnonlin(@simplePacejkaDiff,x0simple,[],[],options,SA,FY);
        
        %%  move to fitting the more complex model without the full Kya
        % find some known initial values
        avgFZ = mean(FZ);
        avgP = mean(P);
        avgIA = mean(IA);
        
        Fzo = 250 * 0.453592 * 9.806; % nominal FZ
        dfz = (avgFZ - Fzo)/Fzo; % normalized FZ
        pio = 12 * 6.89476; % nominal P
        dpi = (avgP - pio)/pio; % normalized P
        
        % model we fit to, stored in another function
% %       Dy = uy*FZ
% %       Cy = pCy
% %       By = Kya/(Cy+Dy + ey)
% %       Ey = (pEy1 + pEy2*dfz)(1 + pEy5*IA^2 - sgn(SA)*(pEy3 + pEy4*IA))
% %       SVy = FZ*(pVy1 + pVy2*dfz) + SVyy
% %       SHy = (pHy1 + pHy2*dfz) + (Kyyo*IA-SVyy)/(Kya+eK) - 1
        
        % create array of ones for inital points 
        x0 = ones(23,1);
        
        % use old fitting data to find initial values to try and put the
        % function in the area of the global minima
        x0(1) = (simpleFit(1)/avgFZ)^(1/4)/2;
        x0(2) = (simpleFit(1)/avgFZ)^(1/4)/2/dfz;
        x0(3) = ((simpleFit(1)/avgFZ)^(1/4)-1)/2/dpi;
        x0(4) = ((simpleFit(1)/avgFZ)^(1/4)-1)/2/(dpi^2);
        x0(5) = ((simpleFit(1)/avgFZ)^(1/4)+1)/(avgIA^2);
        
        x0(6) = simpleFit(2);
        x0(7) = simpleFit(3)*simpleFit(2)*simpleFit(1);
        
        x0(9) = simpleFit(4)^(1/2)/2;
        x0(10) = simpleFit(4)^(1/2)/2/dfz;
        x0(11) = (simpleFit(4)^(1/2)-1)/2/(avgIA^2);
        
        x0(14) = simpleFit(5)/2/avgFZ/avgIA/2;
        x0(15) = simpleFit(5)/2/avgFZ/avgIA/2/dfz;
        x0(16) = simpleFit(5)/2/avgFZ;
        x0(17) = simpleFit(5)/2/avgFZ/dfz;
        
        x0(18) = ((((simpleFit(6)+1)/2)*x0(7)+avgFZ*avgIA*(x0(14)+x0(15)*dfz))/avgIA/avgFZ)^(1/2)/2;
        x0(19) = ((((simpleFit(6)+1)/2)*x0(7)+avgFZ*avgIA*(x0(14)+x0(15)*dfz))/avgIA/avgFZ)^(1/2)/2/dfz;
        x0(20) = (((((simpleFit(6)+1)/2)*x0(7)+avgFZ*avgIA*(x0(14)+x0(15)*dfz))/avgIA/avgFZ)^(1/2)-1)/dpi;
        x0(21) = (simpleFit(6)+1)/2/2;
        x0(22) = (simpleFit(6)+1)/2/2/dfz;
        
        x0 = real(x0);
        
        % fit data to the complex model without the full Kya eqn
        lsqfcn = @(x)fullPacejkaDiff(x,SA,FY,avgFZ,avgP,avgIA);
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
        Pfit.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
            'pCy1', 'Kya',...
            'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
            'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
        Pfit.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
        Pcurve = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA + maincoeffs(7)) - (maincoeffs(4)-sign(SA).*maincoeffs(5)).*(maincoeffs(3).*(SA+maincoeffs(7)) - atan(maincoeffs(3).*(SA+maincoeffs(7)))))) + maincoeffs(6);
        
        Pfit.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
        Pfit.vals.main = maincoeffs;
        
        %% save and print results, will move to saving specific results later
%         save(sprintf('%s\\Data\\Sweep %d', tiresfolder, sweepnum), 'Pfit', 'Pcurve' '-append')
%         save(sprintf('%s\\Data\\aSweep %d', tiresfolder, sweepnum))
        
        % set fig size as 1920maincoeffs080
        f = figure('Position',[0 0 1920 1080]);
        
        % plot FZ, SA, FY vs ET
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
        
        % plot FY vs SA and Pacejka curve
        % also display avg FZ, P, V, IA
        subplot(3,2,[2 6])
        plot(SA,FY,'.r',SA,Pcurve,'b')
        title(sprintf('Sweep %d: FZ=%0.1f, P=%0.1f, V=%0.1f, IA=%0.1f', sweepnum, mean(FZ), mean(P), mean(V), mean(IA)))
        
        % print fig as jpg
        print(sprintf('%s\\Figures\\Sweep %d', tiresfolder, sweepnum), '-dpng', '-r0')
        
        fprintf('Dy = maincoeffs(1)=%f \n', maincoeffs(1))
        fprintf('Cy = maincoeffs(2)=%f \n', maincoeffs(2))
        fprintf('By = maincoeffs(3)=%f \n', maincoeffs(3))
        fprintf('Ey1 = maincoeffs(4)=%f, Ey2 = maincoeffs(5)=%f \n', maincoeffs(4), maincoeffs(5))
        fprintf('SVy =  maincoeffs(6)=%f \n', maincoeffs(6))
        fprintf('SHy = maincoeffs(7)=%f \n\n', maincoeffs(7))
        
        clear f;
        
        %% fit
        x0 = ones(29,1);
        x0(1:6) = Pfit.vals.all(1:6);
        x0(
        x0(14:29) = Pfit.vals.all(8:23);
        
        lsqfcn = @(x)fullPacejkaDiff2(x,SA,FY,avgFZ,avgP,avgIA);
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
        Pfit2.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
            'pCy1', 'pKy1', 'ppy1', 'pKy3', 'pKy4', 'pKy2', 'pKy5', 'ppy2',...
            'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
            'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
        Pfit2.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
        Pcurve = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA + maincoeffs(7)) - (maincoeffs(4)-sign(SA).*maincoeffs(5)).*(maincoeffs(3).*(SA+maincoeffs(7)) - atan(maincoeffs(3).*(SA+maincoeffs(7)))))) + maincoeffs(6);
        
        Pfit2.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
        Pfit2.vals.main = maincoeffs;
        
        %% save and print results, will move to saving specific results later
%         save(sprintf('%s\\Data\\Sweep %d', tiresfolder, sweepnum), 'Pfit', 'Pcurve' '-append')
        save(sprintf('%s\\Data\\aSweep %d', tiresfolder, sweepnum))
        
        % set fig size as 1920maincoeffs080
        f = figure('Position',[0 0 1920 1080]);
        
        % plot FZ, SA, FY vs ET
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
        
        % plot FY vs SA and Pacejka curve
        % also display avg FZ, P, V, IA
        subplot(3,2,[2 6])
        plot(SA,FY,'.r',SA,Pcurve,'b')
        title(sprintf('Sweep %d: FZ=%0.1f, P=%0.1f, V=%0.1f, IA=%0.1f', sweepnum, mean(FZ), mean(P), mean(V), mean(IA)))
        
        % print fig as jpg
        print(sprintf('%s\\Figures\\Sweep %d', tiresfolder, sweepnum), '-dpng', '-r0')
        
        fprintf('Dy = maincoeffs(1)=%f \n', maincoeffs(1))
        fprintf('Cy = maincoeffs(2)=%f \n', maincoeffs(2))
        fprintf('By = maincoeffs(3)=%f \n', maincoeffs(3))
        fprintf('Ey1 = maincoeffs(4)=%f, Ey2 = maincoeffs(5)=%f \n', maincoeffs(4), maincoeffs(5))
        fprintf('SVy =  maincoeffs(6)=%f \n', maincoeffs(6))
        fprintf('SHy = maincoeffs(7)=%f \n\n', maincoeffs(7))
        
        clear f;
    end
end

% set simple fitting model
% Fyo = Dy*sin(Cy*arctan(By*ay - Ey(By*ay - arctan(By*ay)))) + SVy
function diff = simplePacejkaDiff(x,ay,FY)
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

% generates diff for lsqnonlin using initial values, SA, FY, FZ, P, and IA
function diff = fullPacejkaDiff(x0,ay,FY,FZ,P,IA)
    PacejkaFY = Pacejka_eqn_noKya(x0,ay,FZ,P,IA);
    
    diff = PacejkaFY - FY;
end
function diff = fullPacejkaDiff2(x0,ay,FY,FZ,P,IA)
    PacejkaFY = Pacejka_fulleqn(x0,ay,FZ,P,IA);
    
    diff = PacejkaFY - FY;
end
