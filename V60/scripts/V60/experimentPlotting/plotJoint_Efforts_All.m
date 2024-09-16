function plotJoint_Efforts_All(expTable, setName, moName, expName)
% Plots Joint Efforts over all time

    titleName = strcat("All Joint Efforts,  Trial: ", setName, " Active, ", moName, "-", expName);
    
    j = 0;
    for i = 1:size(expTable.x__time, 1)
        if ~isnan(expTable.x_mcu_state_jointURDF_0_effort(i))
            j = j+1;
            time(j, 1) = expTable.x__time(i);

            hip_E_FL(j, 1) = expTable.x_mcu_state_jointURDF_0_effort(i);
            kne_E_FL(j, 1) = expTable.x_mcu_state_jointURDF_1_effort(i);

            hip_E_RL(j, 1) = expTable.x_mcu_state_jointURDF_2_effort(i);
            kne_E_RL(j, 1) = expTable.x_mcu_state_jointURDF_3_effort(i);

            hip_E_FR(j, 1) = expTable.x_mcu_state_jointURDF_4_effort(i);
            kne_E_FR(j, 1) = expTable.x_mcu_state_jointURDF_5_effort(i);

            hip_E_RR(j, 1) = expTable.x_mcu_state_jointURDF_6_effort(i);
            kne_E_RR(j, 1) = expTable.x_mcu_state_jointURDF_7_effort(i);

            abd_E_FL(j, 1) = expTable.x_mcu_state_jointURDF_8_effort(i);
            abd_E_RL(j, 1) = expTable.x_mcu_state_jointURDF_9_effort(i);
            abd_E_FR(j, 1) = expTable.x_mcu_state_jointURDF_10_effort(i);
            abd_E_RR(j, 1) = expTable.x_mcu_state_jointURDF_11_effort(i);
        end
    end
    


    figure

    subplot(2,2, 1)
    plot(time, abd_E_FL, time, hip_E_FL, time, kne_E_FL)
    xlabel('Time [s]')
    ylabel('Front Left Leg Effort  [?]')
    legend('Abductor', 'Hip', 'Knee')

    subplot(2,2, 2)
    plot(time, abd_E_FR, time, hip_E_FR, time, kne_E_FR)
    xlabel('Time [s]')
    ylabel('Front Right Leg Effort  [?]')
    legend('Abductor', 'Hip', 'Knee')

    subplot(2,2, 3)
    plot(time, abd_E_RL, time, hip_E_RL, time, kne_E_RL)
    xlabel('Time [s]')
    ylabel('Rear Left Leg Effort  [?]')
    legend('Abductor', 'Hip', 'Knee')

    subplot(2,2, 4)
    plot(time, abd_E_RR, time, hip_E_RR, time, kne_E_RR)
    xlabel('Time [s]')
    ylabel('Rear Right Leg Effort  [?]')
    legend('Abductor', 'Hip', 'Knee')

    sgtitle(titleName)
end





