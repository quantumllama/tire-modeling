% takes coeff vals, SA, FZ, dfz, dpi, IA; returns FY
function FY = Pacejka_fulleqn(coeffs,ay,FZ,P,IA)
    % values of Fzo=250lbs and pio=12psi were fit
    
    Fzo = 250 * 0.453592 * 9.806; % nominal FZ
    dfz = (FZ - Fzo)/Fzo; % normalized FZ
    pio = 12 * 6.89476; % nominal P
    dpi = (P - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = coeffs(1);
    pDy2 = coeffs(2);
    ppy3 = coeffs(3);
    ppy4 = coeffs(4);
    pDy3 = coeffs(5);
    
    % Cy
    pCy1 = coeffs(6);
    
    % coeffs that belong to Kya
    pKy1 = coeffs(7);
    ppy1 = coeffs(8);
    pKy3 = coeffs(9);
    pKy4 = coeffs(10);
    pKy2 = coeffs(11);
    pKy5 = coeffs(12);
    ppy2 = coeffs(13);
    %
    % By
    ey   = coeffs(14);
    
    % Ey1
    pEy1 = coeffs(15);
    pEy2 = coeffs(16);
    pEy5 = coeffs(17);
    % Ey2
    pEy3 = coeffs(18);
    pEy4 = coeffs(19);
    
    % SVyy
    pVy3 = coeffs(20);
    pVy4 = coeffs(21);
    % SVy
    pVy1 = coeffs(22);
    pVy2 = coeffs(23);
    
    % Kyyo
    pKy6 = coeffs(24);
    pKy7 = coeffs(25);
    ppy5 = coeffs(26);
    % SHy
    pHy1 = coeffs(27);
    pHy2 = coeffs(28);
    eK   = coeffs(29);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2*dfz)*(1 + ppy3*dpi + ppy4*(dpi^2))*(1 - pDy3*(IA^2));
    Dy = uy*FZ;
    
    Cy = pCy1;
    
    Kya = pKy1*Fzo*(1 + ppy1*dpi)*(1 - pKy3*abs(IA))*sin(pKy4*atan((FZ/Fzo)/((pKy2 + pKy5*IA^2)*(1 + ppy2*dpi))));
    By = Kya/(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2*dfz + (pEy1 + pEy2*dfz)*pEy5*IA^2;
    Ey2 = (pEy1 + pEy2*dfz)*(pEy3 + pEy4*IA);
    
    SVyy = FZ*(pVy3 + pVy4*dfz)*IA;
    SVy = FZ*(pVy1 + pVy2*dfz) + SVyy;
    
    Kyyo = FZ*(pKy6 + pKy7*dfz)*(1 + ppy5*dpi);
    SHy = (pHy1 + pHy2*dfz) + (Kyyo*IA-SVyy)/(Kya+eK) - 1;
    
%     disp(Dy)
%     disp(Cy)
%     disp(By)
%     disp(Ey1)
%     disp(Ey2)
%     disp(SVy)
%     disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
    FY = Dy*sin(Cy*atan(By.*(ay+SHy) - (Ey1-sign(ay).*Ey2).*(By.*(ay+SHy) - atan(By.*(ay+SHy))))) + SVy;
end
