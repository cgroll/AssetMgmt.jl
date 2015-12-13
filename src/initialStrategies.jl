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


function optimizeWgts(s::MinSigma, univ::MuSigmaUniverse)
    muTarget = s.mu

    return getEffPfGivenMu(univ.Universe, muTarget)
end

function optimizeWgts(s::MaxMu, mod::MuSigmaUniverse)
    
end

function optimizeWgts(s::GMVSS, mod::MuSigmaUniverse)
    return getGMVSS(mod)
end
