function v60 = getV60MoCap(trc)
    v60.time = table2array(trc(2:end, 2));

% Legs
    v60.FL_leg.X = table2array(trc(2:end, 3));
    v60.FL_leg.Y = table2array(trc(2:end, 4));
    v60.FL_leg.Z = table2array(trc(2:end, 5));
    v60.FL_leg.name = 'Front Left Leg';
    
    v60.FR_leg.X = table2array(trc(2:end, 6));
    v60.FR_leg.Y = table2array(trc(2:end, 7));
    v60.FR_leg.Z = table2array(trc(2:end, 8));
    v60.FR_leg.name = 'Front Right Leg';

    v60.AL_leg.X = table2array(trc(2:end, 9));
    v60.AL_leg.Y = table2array(trc(2:end, 10));
    v60.AL_leg.Z = table2array(trc(2:end, 11));
    v60.AL_leg.name = 'Rear Left Leg';

    v60.AR_leg.X = table2array(trc(2:end, 12));
    v60.AR_leg.Y = table2array(trc(2:end, 13));
    v60.AR_leg.Z = table2array(trc(2:end, 14));
    v60.AR_leg.name = 'Rear Right Leg';

% Base
    v60.Arm.X = table2array(trc(2:end, 15));
    v60.Arm.Y = table2array(trc(2:end, 16));
    v60.Arm.Z = table2array(trc(2:end, 17));
    v60.Arm.name = 'Wrist';

    v60.FL.X = table2array(trc(2:end, 18));
    v60.FL.Y = table2array(trc(2:end, 19));
    v60.FL.Z = table2array(trc(2:end, 20));
    v60.FL.name = 'Front Left Base';
    
    v60.FR.X = table2array(trc(2:end, 21));
    v60.FR.Y = table2array(trc(2:end, 22));
    v60.FR.Z = table2array(trc(2:end, 23));
    v60.FR.name = 'Front Right Base';

    v60.AL.X = table2array(trc(2:end, 24));
    v60.AL.Y = table2array(trc(2:end, 25));
    v60.AL.Z = table2array(trc(2:end, 26));
    v60.AL.name = 'Rear Left Base';

    v60.AR.X = table2array(trc(2:end, 27));
    v60.AR.Y = table2array(trc(2:end, 28));
    v60.AR.Z = table2array(trc(2:end, 29));
    v60.AR.name = 'Rear Right Base';
    
    

end