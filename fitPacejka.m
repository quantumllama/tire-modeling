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
        
        x0 = [Dy Cy By Ey SVy SHy];
        
        % fit data to simple model
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',3000);
        Pfit_simple = lsqnonlin(@simplePacejka,x0,[],[],options,SA,FY);

        
        %%  move to fitting the more complex model
        % find some known initial values
        avgFZ = mean(FZ);
        avgP = mean(P);
        avgIA = mean(IA);
        
        % model we fit to, stored in another function
% %       Dy = uy*FZ
% %       Cy = pCy
% %       By = Kya/(Cy+Dy + ey)
% %       Ey = (pEy1 + pEy2*dfz)(1 + pEy5*IA^2 - sgn(SA)*(pEy3 + pEy4*IA))
% %       SVy = FZ*(pVy1 + pVy2*dfz) + SVyy
% %       SHy = (pHy1 + pHy2*dfz) + (Kyyo*IA-SVyy)/(Kya+eK) - 1
        
        % create array of ones for inital points 
        x0 = ones(23,1);
        
        % use old fitting data to find an inital value, this is enough to
        % put us into the area of the global minima
        x0(7) = Pfit_simple(3)*Pfit_simple(2)*Pfit_simple(1);
        
        % fit data to the complex model
        lsqfcn = @(x)diffPacejka_all_coeffs(x,SA,FY,avgFZ,avgP,avgIA);
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
        Pfit.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
            'pCy1', 'Kya',...Kya coeffs omittied for now, 'pKy1', 'ppy1', 'pKy3', 'pKy4', 'pKy2', 'pKy5', 'ppy2',...
            'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
            'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
        Pfit.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
        Pcurve = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA + maincoeffs(7)) - (maincoeffs(4)-sign(SA).*maincoeffs(5)).*(maincoeffs(3).*(SA+maincoeffs(7)) - atan(maincoeffs(3).*(SA+maincoeffs(7)))))) + maincoeffs(6);
        
        Pfit.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
        Pfit.vals.main = maincoeffs;
        
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
function diff = simplePacejka(x,ay,FY)
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
function diff = diffPacejka_all_coeffs(x0,ay,FY,FZ,P,IA)    
    PacejkaFY = Pacejka_fulleqn(x0,ay,FZ,P,IA);
    
    diff = PacejkaFY - FY;
end
