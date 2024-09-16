function angles = parse_Angles(expTable, setName, moName, expName)
% Plots V60 manual_twist ros2 topic
% Only non-zero data should be angular z aand linear x and y

    %% Parsing
    j = 0;
    for i = 1:size(expTable.x__time, 1)
        if ~isnan(expTable.x_mcu_state_jointURDF_0_position(i))
            j = j+1;
            angles.time(j) = expTable.x__time(i);

            angles.hip_A_FL(j, 1) = expTable.x_mcu_state_jointURDF_0_position(i);
            angles.kne_A_FL(j, 1) = expTable.x_mcu_state_jointURDF_1_position(i);
            angles.abd_A_FL(j, 1) = expTable.x_mcu_state_jointURDF_8_position(i); 
            
            angles.hip_A_RL(j, 1) = expTable.x_mcu_state_jointURDF_2_position(i);
            angles.kne_A_RL(j, 1) = expTable.x_mcu_state_jointURDF_3_position(i);
            angles.abd_A_RL(j, 1) = expTable.x_mcu_state_jointURDF_9_position(i);
            
            angles.hip_A_FR(j, 1) = expTable.x_mcu_state_jointURDF_4_position(i);
            angles.kne_A_FR(j, 1) = expTable.x_mcu_state_jointURDF_5_position(i);
            angles.abd_A_FR(j, 1) = expTable.x_mcu_state_jointURDF_10_position(i);
            
            angles.hip_A_RR(j, 1) = expTable.x_mcu_state_jointURDF_6_position(i);
            angles.kne_A_RR(j, 1) = expTable.x_mcu_state_jointURDF_7_position(i);
            angles.abd_A_RR(j, 1) = expTable.x_mcu_state_jointURDF_11_position(i);
        end
    end

end



