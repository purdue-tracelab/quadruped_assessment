function boundedRMS = getGaitingRMS(data)

    %meanGaitFrame = 37;
    %gaitBounds = floor(meanGaitFrame/2);   % should = 18
    gaitBounds = 18;

    numFrames = length(data);
    j = 0;
    for i = 1+gaitBounds:numFrames-gaitBounds
        j = j + 1;
        boundedRMS(j) = rms(data(i-gaitBounds:i+gaitBounds));
    end

end