function data = parseStilettoData(filePath)
    
    table = readtable(filePath, 'VariableNamingRule','modify');
    table.x__time =  table.x__time - table.x__time(1);
    
    i = 0;
    % efforts
    for k0 = 1:size(table.x__time)
        if ~isnan(table.x_joint_states_front_left_hip_x_effort(k0))
            i = i + 1;
            data.effort.time(i) = table.x__time(k0);

            data.effort.FL.abd(i, 1) = abs(table.x_joint_states_front_left_hip_x_effort(k0));
            data.effort.FL.hip(i, 1) = abs(table.x_joint_states_front_left_hip_y_effort(k0));
            data.effort.FL.kne(i, 1) = abs(table.x_joint_states_front_left_knee_effort(k0));
        
            data.effort.FR.abd(i, 1) = abs(table.x_joint_states_front_right_hip_x_effort(k0));
            data.effort.FR.hip(i, 1) = abs(table.x_joint_states_front_right_hip_y_effort(k0));
            data.effort.FR.kne(i, 1) = abs(table.x_joint_states_front_right_knee_effort(k0));
        
            data.effort.AL.abd(i, 1) = abs(table.x_joint_states_rear_left_hip_x_effort(k0));
            data.effort.AL.hip(i, 1) = abs(table.x_joint_states_rear_left_hip_y_effort(k0));
            data.effort.AL.kne(i, 1) = abs(table.x_joint_states_rear_left_knee_effort(k0));
        
            data.effort.AR.abd(i, 1) = abs(table.x_joint_states_rear_right_hip_x_effort(k0));
            data.effort.AR.hip(i, 1) = abs(table.x_joint_states_rear_right_hip_y_effort(k0));
            data.effort.AR.kne(i, 1) = abs(table.x_joint_states_rear_right_knee_effort(k0));
        end
    end

    % joint angle (position)
    i = 0;
    for k0 = 1:size(table.x__time)
        if ~isnan(table.x_joint_states_front_left_hip_x_position(k0))
            i = i + 1;
            data.angle.time(i) = table.x__time(k0);

            data.angle.FL.abd(i, 1) = table.x_joint_states_front_left_hip_x_position(k0);
            data.angle.FL.hip(i, 1) = table.x_joint_states_front_left_hip_y_position(k0);
            data.angle.FL.kne(i, 1) = table.x_joint_states_front_left_knee_position(k0);
        
            data.angle.FR.abd(i, 1) = table.x_joint_states_front_right_hip_x_position(k0);
            data.angle.FR.hip(i, 1) = table.x_joint_states_front_right_hip_y_position(k0);
            data.angle.FR.kne(i, 1) = table.x_joint_states_front_right_knee_position(k0);
        
            data.angle.AL.abd(i, 1) = table.x_joint_states_rear_left_hip_x_position(k0);
            data.angle.AL.hip(i, 1) = table.x_joint_states_rear_left_hip_y_position(k0);
            data.angle.AL.kne(i, 1) = table.x_joint_states_rear_left_knee_position(k0);
        
            data.angle.AR.abd(i, 1) = table.x_joint_states_rear_right_hip_x_position(k0);
            data.angle.AR.hip(i, 1) = table.x_joint_states_rear_right_hip_y_position(k0);
            data.angle.AR.kne(i, 1) = table.x_joint_states_rear_right_knee_position(k0);
        end
    end


    i = 0;
    % Joystick
    for k0 = 1:size(table.x__time)
        if ~isnan(table.x_spot_odometry_twist_twist_twist_angular_x(k0))
            i = i + 1;
            data.twist.time(i) = table.x__time(k0);

            data.twist.ang.x(i) = table.x_spot_odometry_twist_twist_twist_angular_x(k0);
            data.twist.ang.y(i) = table.x_spot_odometry_twist_twist_twist_angular_y(k0);
            data.twist.ang.z(i) = table.x_spot_odometry_twist_twist_twist_angular_z(k0);
            data.twist.lin.x(i) = table.x_spot_odometry_twist_twist_twist_linear_x(k0);
            data.twist.lin.y(i) = table.x_spot_odometry_twist_twist_twist_linear_y(k0);
            data.twist.lin.z(i) = table.x_spot_odometry_twist_twist_twist_linear_z(k0);
        end
    end



    % Toe Position (for support polygon)
    i = 0;
    for k = 1:size(table.x__time)
        if ~isnan(table.x_spot_status_feet_states_0_foot_position_rt_body_x(k))
            i = i + 1;
            data.toePos.time(i) = table.x__time(k);

            data.toePos.FL.x(i) = table.x_spot_status_feet_states_0_foot_position_rt_body_x(k);
            data.toePos.FL.y(i) = table.x_spot_status_feet_states_0_foot_position_rt_body_y(k);
            data.toePos.FL.z(i) = table.x_spot_status_feet_states_0_foot_position_rt_body_z(k);

            data.toePos.FR.x(i) = table.x_spot_status_feet_states_1_foot_position_rt_body_x(k);
            data.toePos.FR.y(i) = table.x_spot_status_feet_states_1_foot_position_rt_body_y(k);
            data.toePos.FR.z(i) = table.x_spot_status_feet_states_1_foot_position_rt_body_z(k);

            data.toePos.AL.x(i) = table.x_spot_status_feet_states_2_foot_position_rt_body_x(k);
            data.toePos.AL.y(i) = table.x_spot_status_feet_states_2_foot_position_rt_body_y(k);
            data.toePos.AL.z(i) = table.x_spot_status_feet_states_2_foot_position_rt_body_z(k);

            data.toePos.AR.x(i) = table.x_spot_status_feet_states_3_foot_position_rt_body_x(k);
            data.toePos.AR.y(i) = table.x_spot_status_feet_states_3_foot_position_rt_body_y(k);
            data.toePos.AR.z(i) = table.x_spot_status_feet_states_3_foot_position_rt_body_z(k);
        end
    end



    % toe contact
    i = 0;
    for k0 = 1:size(table.x__time)
        if ~isnan(table.x_spot_status_feet_states_0_contact(k0))
            i = i + 1;
            data.contact.time(i) = table.x__time(k0);

            data.contact.FL(i) = table.x_spot_status_feet_states_0_contact(k0);
            data.contact.FR(i) = table.x_spot_status_feet_states_1_contact(k0);
            data.contact.AL(i) = table.x_spot_status_feet_states_2_contact(k0);
            data.contact.AR(i) = table.x_spot_status_feet_states_3_contact(k0);
        end
    end



    % Filter Toe Contact
    t  = 1;
    for i = 1:size(data.effort.time, 2)
        % Check if effort time is less than contact time per step
        %    If effort time is less, set the effort with next known contact
        %    value for each leg
        if data.effort.time(i) <= data.contact.time(t)
            data.effort.FL.contact(i) = data.contact.FL(t);
            data.effort.FR.contact(i) = data.contact.FR(t);
            data.effort.AL.contact(i) = data.contact.AL(t);
            data.effort.AR.contact(i) = data.contact.AR(t);
        else
            t = t+1;
            data.effort.FL.contact(i) = data.contact.FL(t);
            data.effort.FR.contact(i) = data.contact.FR(t);
            data.effort.AL.contact(i) = data.contact.AL(t);
            data.effort.AR.contact(i) = data.contact.AR(t);
        end
    end

    

    % Save Toe Contact Efforts Seperatly
    k0 = 0;
    k1 = 0;
    k2 = 0;
    k3 = 0;

    % For each leg, save the time and effort when contacting
    for i = 1:size(data.effort.time, 2)
        if data.effort.FL.contact(i) == 1
            k0 = k0 + 1;
            data.contactEffort.FL.time(k0) = data.effort.time(i);
            data.contactEffort.FL.abd(k0)  = data.effort.FL.abd(i);
            data.contactEffort.FL.hip(k0)  = data.effort.FL.hip(i);
            data.contactEffort.FL.kne(k0)  = data.effort.FL.kne(i);
        end
        if data.effort.FR.contact(i) == 1
            k1 = k1 + 1;
            data.contactEffort.FR.time(k1) = data.effort.time(i);
            data.contactEffort.FR.abd(k1)  = data.effort.FR.abd(i);
            data.contactEffort.FR.hip(k1)  = data.effort.FR.hip(i);
            data.contactEffort.FR.kne(k1)  = data.effort.FR.kne(i);
        end
        if data.effort.AL.contact(i) == 1
            k2 = k2 + 1;
            data.contactEffort.AL.time(k2) = data.effort.time(i);
            data.contactEffort.AL.abd(k2)  = data.effort.AL.abd(i);
            data.contactEffort.AL.hip(k2)  = data.effort.AL.hip(i);
            data.contactEffort.AL.kne(k2)  = data.effort.AL.kne(i);
        end
        if data.effort.AR.contact(i) == 1
            k3 = k3 + 1;
            data.contactEffort.AR.time(k3) = data.effort.time(i);
            data.contactEffort.AR.abd(k3)  = data.effort.AR.abd(i);
            data.contactEffort.AR.hip(k3)  = data.effort.AR.hip(i);
            data.contactEffort.AR.kne(k3)  = data.effort.AR.kne(i);
        end
    end



    % Gaiting Averages
    data.gaitAveEffort.FL.hip = getGaitingAverages(data.contactEffort.FL.hip);
    data.gaitAveEffort.FR.hip = getGaitingAverages(data.contactEffort.FR.hip);
    data.gaitAveEffort.AL.hip = getGaitingAverages(data.contactEffort.AL.hip);
    data.gaitAveEffort.AR.hip = getGaitingAverages(data.contactEffort.AR.hip);

    data.gaitAveEffort.FL.kne = getGaitingAverages(data.contactEffort.FL.kne);
    data.gaitAveEffort.FR.kne = getGaitingAverages(data.contactEffort.FR.kne);
    data.gaitAveEffort.AL.kne = getGaitingAverages(data.contactEffort.AL.kne);
    data.gaitAveEffort.AR.kne = getGaitingAverages(data.contactEffort.AR.kne);

    data.gaitAveEffort.FL.abd = getGaitingAverages(data.contactEffort.FL.abd);
    data.gaitAveEffort.FR.abd = getGaitingAverages(data.contactEffort.FR.abd);
    data.gaitAveEffort.AL.abd = getGaitingAverages(data.contactEffort.AL.abd);
    data.gaitAveEffort.AR.abd = getGaitingAverages(data.contactEffort.AR.abd);
end





