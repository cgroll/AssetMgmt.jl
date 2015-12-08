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
    
    
end

function optimizeWgts(mod::MuSigmaUniverse, s::MaxMu)
    
    
end

function optimizeWgts(mod::MuSigmaUniverse, s::GMVSS)
    nAss = size(mod.Data, 2)

    ## get return moments
    mus = mod.Universe.mu
    covMatr = mod.Universe.sigma

    ## get helper matrices
    onesN = ones(nAss,1)
    a = ones(1, nAss)/covMatr*ones(nAss, 1)
    b = ones(1, nAss)/covMatr*mus
    c = mus'/covMatr*mus
    d = a*c-b^2
    
    ## compute GMV weights
    xGMV = covMatr\ones(1, nAss)/a

    return xGMV
end
