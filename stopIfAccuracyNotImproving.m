
function stop = stopIfAccuracyNotImproving(info,N)

stop = false;


    if  info.BaseLearnRate < N
        stop = true;
    end
    
end
