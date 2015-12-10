## getFundamentals
##----------------

## calculate fundamental helping values
function getFundamentals(mod::MuSigmaModel)
    nAss = size(mod.mu, 1)

    ## get return moments
    mus = mod.mu
    covMatr = mod.sigma

    ## get helper matrices
    onesN = ones(nAss,1)
    a = ones(1, nAss)/covMatr*ones(nAss, 1)
    b = ones(1, nAss)/covMatr*mus
    c = mus'/covMatr*mus
    d = a.*c-b.^2

    return a[1], b[1], c[1], d[1]
end

## get global minimum variance portfolio with short selling 
function getGMVSS(mod::MuSigmaModel)
    nAss = size(mod.mu, 1)

    ## get return moments
    covMatr = mod.sigma

    a, b, c, d = getFundamentals(mod)
        
    ## compute GMV weights
    xGMV = covMatr\ones(nAss, 1)/a

    return xGMV[:]
end

## efficient frontier
##-------------------

function getEffFrontier(mod::MuSigmaModel;
                        nPoints = 50)

    ## get GMV portfolio
    xGMV = AssetMgmt.getGMVSS(mod)

    ## get associated portfolio mu
    muGMV = AssetMgmt.getPMean(xGMV, mod.mu)

    ## find maximum asset mu
    maxMu = maximum(mod.mu)
    
    ## find maximum asset sigma
    ## sigmas = AssetMgmt.getVolas(mod)
    ## maxSigma = maximum(sigmas)
        
    ## define mu grid
    muGrid = linspace(muGMV, maxMu, nPoints)

    ## get fundamentals
    a, b, c, d = AssetMgmt.getFundamentals(mod)
    
    ## get sigmas for given mu grid
    effSigmas = sqrt((a*muGrid.^2 - 2*b*muGrid + c)/d)

    return muGrid, effSigmas
end

function getEffPortfolios(mod::MuSigmaModel;
                          nPoints = 50)

    ## get GMV portfolio
    xGMV = AssetMgmt.getGMVSS(mod)

    ## get associated portfolio mu
    muGMV = AssetMgmt.getPMean(xGMV, mod.mu)

    ## find maximum asset mu
    maxMu = maximum(mod.mu)

    ## define mu grid
    muGrid = linspace(muGMV, maxMu, nPoints)

    ## get number of assets
    nAss = size(mod.mu, 1)

    ## preallocation
    nPfs = length(muGrid)
    effWgts = ones(nPfs, nAss)
    
    for ii=1:nPfs
        muTarget = muGrid[ii]

        ## get weights
        wgts = getEffPfGivenMu(mod, muTarget)
        effWgts[ii, :] = wgts
    end

    return effWgts
end

function getEffPfGivenMu(mod, muTarget)
    covMatr = mod.sigma
    
    ## get number of assets
    nAss = size(mod.mu, 1)

    ## create helping matrices
    R = [ones(nAss) mod.mu]

    ## get constraints
    muConstr = [1; muTarget]

    ## get weights
    wgts = inv(covMatr)*R*inv(R'*inv(covMatr)*R)*muConstr

    return wgts'
end
