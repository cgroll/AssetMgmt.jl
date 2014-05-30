function egarchfit(data::Array{Float64, 1})
    ## fit egarch function to historic return data
    ##
    ## log(s^2) = kappa + gamma log(s^2) + xi*Z + alpha(|Z| -
    ## sqrt(2/pi)) 
    
    nObs = length(data)
    mu = mean(data)
    centeredData = data .- mu
    
    ## subsample to estimate initial sigma
    nInit = 50
    if nInit > nObs
        nInit = nObs
    end
    
    ## preallocate values
    volaT = zeros(nObs, 1)
    logVarT = zeros(nObs, 1)
    
    function egarchNllh(params::Array{Float64, 1}, grad::Vector)
        kappa, gamma, xi, alpha = params;
        
        initSigma = std(centeredData[1:nInit])
        volaT[1] = initSigma
        
        ## retrieve volas
        for ii=2:nObs
            lastZ = centeredData[ii-1]/volaT[ii-1]
            
            logVarT[ii] = kappa + gamma*logVarT[ii-1] +
            xi*lastZ + alpha*(abs(lastZ) - sqrt(2/pi))
            
            volaT[ii] = sqrt(exp(logVarT[ii]))
        end
        
        zVals = centeredData ./ volaT
        nllh = nObs * log(sqrt(2*pi)) +
        sum(log(volaT) + 0.5*(centeredData./volaT).^2)
        
        return nllh
    end
    
    opt = Opt(:LN_SBPLX, 4)
    min_objective!(opt, egarchNllh)
    (minf, minx, ret) = optimize(opt, [std(centeredData), 0.8, 0.1, 0.1])
    
end

function getVola(data::Array{Float64, 1}, params::Array{Float64, 1})
    
    kappa, gamma, xi, alpha = params;
    nObs = length(data)
    mu = mean(data)
    centeredData = data .- mu
    
    ## subsample to estimate initial sigma
    nInit = 50
    if nInit > nObs
        nInit = nObs
    end
    
    ## preallocate values
    volaT = zeros(nObs, 1)
    logVarT = zeros(nObs, 1)

    initSigma = std(centeredData[1:nInit])
    volaT[1] = initSigma
    
    ## retrieve volas
    for ii=2:nObs
        lastZ = centeredData[ii-1]/volaT[ii-1]
        
        logVarT[ii] = kappa + gamma*logVarT[ii-1] +
        xi*lastZ + alpha*(abs(lastZ) - sqrt(2/pi))
        
        volaT[ii] = sqrt(exp(logVarT[ii]))
    end

    return volaT
end
