abstract InitialStrategy
abstract MuSigmaStrategy <: InitialStrategy

###################
## short selling ##
###################

type MaxMuSS <: MuSigmaStrategy
    sigma::Float64
    
    function MaxMuSS(sigma::Float64)
        if sigma < 0.01
            error("Specified sigma must be larger than zero.")
        end
        return new(sigma)
    end
end

type MinSigmaSS <: MuSigmaStrategy
    mu::Float64
    
    MinSigmaSS(mu::Float64) = return new(mu)
end

type GMVSS <: MuSigmaStrategy
    
    GMVSS() = return new()
end


######################
## no short selling ##
######################

type MaxMu <: MuSigmaStrategy
    sigma::Float64
    
    function MaxMu(sigma::Float64)
        if sigma < 0.01
            error("Specified sigma must be larger than zero.")
        end
        return new(sigma)
    end
end

type MinSigma <: MuSigmaStrategy
    mu::Float64
    
    MinSigma(mu::Float64) = return new(mu)
end

type GMV <: MuSigmaStrategy
    
    GMV() = return new()
end


####################
## apply strategy ##
####################

function applyStrategy(strat::AssetMgmt.InitialStrategy,
                       estimator::Type{AssetMgmt.ExpWeighted},
                       data::Timematr)
    
    ## iterate over dates
    allDats = idx(data)
    nDats = length(allDats)
    
    ## preallocation
    nObs, nAss = size(data)
    allWgts = Array(Float64, nObs, nAss)
    pfMoments = Array(Float64, nObs, 2)
    modelEstimated = falses(nObs)
    
    for ii=1:nDats
        thisDate = allDats[ii]
        univ = AssetMgmt.estimate(estimator, data, thisDate)
        if AssetMgmt.isDef(univ)
            ## set estimation indicator to true
            modelEstimated[ii] = true
            
            wgts = AssetMgmt.optimizeWgts(strat, univ)
            allWgts[ii, :] = wgts

            ## calculate portfolio moments
            pfMu = AssetMgmt.getPMean(wgts[:], univ.Universe.mu)
            pfSigma = sqrt(AssetMgmt.getPVar(wgts[:], univ.Universe.sigma))
            pfMoments[ii, :] = [pfMu pfSigma]
        end
    end

    ## remove non-estimatable dates
    allWgts = allWgts[modelEstimated, :]
    pfMoments = pfMoments[modelEstimated, :]
    allDats = allDats[modelEstimated]

    ## DataFrame
    wgtsDf = composeDataFrame(allWgts, names(data))
    pfMomentsDf = Timematr(pfMoments, [:mu, :sigma], allDats)
    
    invs = Investments(wgtsDf, allDats)

    return invs, pfMomentsDf
end

##############
## optimize ##
##############

function optimizeWgts(s::MinSigma, univ::MuSigmaUniverse)
    muTarget = s.mu

    return getEffPfGivenMu(univ.Universe, muTarget)
end

function optimizeWgts(s::MaxMu, mod::MuSigmaUniverse)
    
end

function optimizeWgts(s::GMVSS, mod::MuSigmaUniverse)
    return getGMVSS(mod)
end
