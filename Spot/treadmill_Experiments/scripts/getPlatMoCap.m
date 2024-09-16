function plat = getPlatMoCap(trc)

    plat.time = table2array(trc(2:end, 2));

    plat.FL.X = table2array(trc(2:end, 3));

    plat.FL.Y = table2array(trc(2:end, 4));

    plat.FL.Z = table2array(trc(2:end, 5));

    plat.FL.name = 'Front Left';

    plat.FR.X = table2array(trc(2:end, 6));
    plat.FR.Y = table2array(trc(2:end, 7));
    plat.FR.Z = table2array(trc(2:end, 8));
    plat.FL.name = 'Front Right';

    plat.AL.X = table2array(trc(2:end, 9));
    plat.AL.Y = table2array(trc(2:end, 10));
    plat.AL.Z = table2array(trc(2:end, 11));
    plat.FL.name = 'Aft Left';

    plat.AR.X = table2array(trc(2:end, 12));
    plat.AR.Y = table2array(trc(2:end, 13));
    plat.AR.Z = table2array(trc(2:end, 14));
    plat.FL.name = 'Aft Right';

    plat.Po.X = table2array(trc(2:end, 15));
    plat.Po.Y = table2array(trc(2:end, 16));
    plat.Po.Z = table2array(trc(2:end, 17));
    plat.FL.name = 'Marker Post';

end

function dir = cla(dir)
    if string(class(dir(1))) == "cell"
        dir = nan(size(dir));
    end
end