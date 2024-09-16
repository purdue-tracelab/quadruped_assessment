function angles = parse_Angles(expTable, setName, moName, expName)
% Plots Spot angles ros2 topic

    %% Parsing
    j = 0;
    for i = 1:size(expTable.Time, 1)
        if ~isnan(expTable.fl_hy_Pos(i))
            j = j+1;
            angles.time(j) = expTable.Time(i);

            angles.hip_A_FL(j, 1) = expTable.fl_hy_Pos(i);
            angles.kne_A_FL(j, 1) = expTable.fl_kn_Pos(i);
            angles.abd_A_FL(j, 1) = expTable.fl_hx_Pos(i);
            
            angles.hip_A_RL(j, 1) = expTable.hl_hy_Pos(i);
            angles.kne_A_RL(j, 1) = expTable.hl_kn_Pos(i);
            angles.abd_A_RL(j, 1) = expTable.hl_hx_Pos(i);
            
            angles.hip_A_FR(j, 1) = expTable.fr_hy_Pos(i);
            angles.kne_A_FR(j, 1) = expTable.fr_kn_Pos(i);
            angles.abd_A_FR(j, 1) = expTable.fr_hx_Pos(i);
            
            angles.hip_A_RR(j, 1) = expTable.hr_hy_Pos(i);
            angles.kne_A_RR(j, 1) = expTable.hr_kn_Pos(i);
            angles.abd_A_RR(j, 1) = expTable.hr_hx_Pos(i);
        end
    end
end



