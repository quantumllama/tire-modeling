% find optimal slip angle differences
% weight transfer given (max or average?) lateral G's + aero downforce gain
% at all speeds

%%%% define stuff  dist = distribution, lat = lateral, long = longitudinal
vehicleWeight = 590; % lbs
frontTrack = 48; % inches, despite my hate for the imperial system
rearTrack = 47; % ditto to above
wheelbase = 61; % ditto
CGHeight = 10.9; % ditto
frontWeightDist = .5; % decimal, not percentage
frontRollCoupleDist = .5; % decimal

% point to matrix to load, in mph, where every row is downforce at that speed
load('C:\Users\Michael\Documents\College\!!SAE\!Suspension\Design\Tires\aeroLoad2015-16.mat');
leftLatAeroDist = .5; % decimal
frontLongAeroDist = .34; % decimal, force on front out of total
%%%%

% find weight on each wheel, accounting for weight transfer and aero
% outputs into struct Weight.wheel

% find static weights on each wheel with respect to speed, (speed,1)
Weight.FL.Static = vehicleWeight * (frontWeightDist/2) + (aeroLoadvSpeed * leftLatAeroDist * frontLongAeroDist);
Weight.FR.Static = vehicleWeight * (frontWeightDist/2) + (aeroLoadvSpeed * (1-leftLatAeroDist) * frontLongAeroDist);
Weight.RL.Static = vehicleWeight * ((1-frontWeightDist)/2) + (aeroLoadvSpeed * leftLatAeroDist * (1-frontLongAeroDist));
Weight.RR.Static = vehicleWeight * ((1-frontWeightDist)/2) + (aeroLoadvSpeed * (1-leftLatAeroDist) * (1-frontLongAeroDist));

% make LatAccel vector which has points from 0 to 3G's at resolution of 0.01
LatAccel = linspace(0.01,3,300);

tempstaticFL = kron(ones([1,300]),Weight.FL.Static);
tempstaticFR = kron(ones([1,300]),Weight.FR.Static);
tempstaticRL = kron(ones([1,300]),Weight.RL.Static);
tempstaticRR = kron(ones([1,300]),Weight.RR.Static);

% then using static weights find dynamic lateral weight on each wheel, (speed, lateral G's/100)
Weight.FL.DynamicLat = tempstaticFL - (LatAccel*vehicleWeight*CGHeight*frontRollCoupleDist) / frontTrack;
Weight.FR.DynamicLat = tempstaticFR + (LatAccel*vehicleWeight*CGHeight*frontRollCoupleDist) / frontTrack;
Weight.RL.DynamicLat = tempstaticRL - (LatAccel*vehicleWeight*CGHeight*(1-frontRollCoupleDist)) / rearTrack;
Weight.RR.DynamicLat = tempstaticRR + (LatAccel*vehicleWeight*CGHeight*(1-frontRollCoupleDist)) / rearTrack;


% 