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
    
    Kya  = coeffs(7); % begin with it set as By*Cy*Dy
    %{
    pKy1 = ;
    ppy1 = ;
    pKy3 = ;
    pKy4 = ;
    pKy2 = ;
    pKy5 = ;
    ppy2 = ;
    %}
    % By
    ey   = coeffs(8);
    
    % Ey1
    pEy1 = coeffs(9);
    pEy2 = coeffs(10);
    pEy5 = coeffs(11);
    % Ey2
    pEy3 = coeffs(12);
    pEy4 = coeffs(13);
    
    % SVyy
    pVy3 = coeffs(14);
    pVy4 = coeffs(15);
    % SVy
    pVy1 = coeffs(16);
    pVy2 = coeffs(17);
    
    % Kyyo
    pKy6 = coeffs(18);
    pKy7 = coeffs(19);
    ppy5 = coeffs(20);
    % SHy
    pHy1 = coeffs(21);
    pHy2 = coeffs(22);
    eK   = coeffs(23);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2*dfz)*(1 + ppy3*dpi + ppy4*(dpi^2))*(1 - pDy3*(IA^2));
    Dy = uy*FZ;
    
    Cy = pCy1;
    
%     Kya = pKy1*Fzo*(1 + ppy1*dpi)*(1 - pKy3*abs(IA))*...
%         sin(pKy4*atan((FZ/Fzo)/((pKy2 + pKy5*(IA^2))*(1 + ppy2*dpi))));
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
