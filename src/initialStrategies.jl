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


##############
## optimize ##
##############


function optimizeWgts(mod::MuSigmaUniverse, s::MinSigma)
    nAss = size(mod.Data, 2)

    ## get return moments
    covMatr = mod.Universe.sigma

    a, b, c, d = getFundamentals(mod)

    ## get target mu
    targetMu = s.mu
    
end

function optimizeWgts(mod::MuSigmaUniverse, s::MaxMu)
    
end


function optimizeWgts(mod::MuSigmaUniverse, s::GMVSS)
    return getGMVSS(mod)
end
