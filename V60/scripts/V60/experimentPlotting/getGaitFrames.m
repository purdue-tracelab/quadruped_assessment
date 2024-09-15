function aveGaitFrameLen = getGaitFrames(expTable)

    toe0c = expTable.x_mcu_state_toe_array_toes_0_contact;
    toe1c = expTable.x_mcu_state_toe_array_toes_1_contact;
    toe2c = expTable.x_mcu_state_toe_array_toes_2_contact;
    toe3c = expTable.x_mcu_state_toe_array_toes_3_contact;

    toe0c = removeNan(toe0c);
    toe1c = removeNan(toe1c);
    toe2c = removeNan(toe2c);
    toe3c = removeNan(toe3c);

    frame_length0 = getFrameLength(toe0c);
    frame_length1 = getFrameLength(toe1c);
    frame_length2 = getFrameLength(toe2c);
    frame_length3 = getFrameLength(toe3c);

    aveGaitFrameLen = (frame_length0 + frame_length1 + frame_length2 + frame_length3)/4;

end



function toe = removeNan(toeWithNan)
    j = 0;

    for i = 1:length(toeWithNan)
        if ~isnan(toeWithNan(i))
            j = j + 1;
            toe(j) = toeWithNan(i);
        end
    end

    toe = toe';
end


function frame_length = getFrameLength(toeC)
    start  = 0;
    finish = 0;

    for i = 1:length(toeC)-1
            if toeC(i) == 1
                if toeC(i+1) == 0
                    start = i;
                    
                end
            end
            if toeC(i) == 0
                if toeC(i+1) ==1
                    finish = i;
                end
            end
            if start > 0 && finish > 0
                break
            end
    end
    frame_length = abs(finish - start);
end
   


