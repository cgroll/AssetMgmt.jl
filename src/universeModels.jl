abstract UniverseModel
abstract MuSigmaModel <: UniverseModel
abstract DistributionModel <: UniverseModel

###################
## MuSigmaModels ##
###################

## SampleMoments
##--------------

type SampleMoments <: MuSigmaModel
    mu::Array{Float64, 1}
    sigma::Array{Float64, 2}
    names::Array{Symbol, 1}

    function SampleMoments(mu::Array{Float64, 1},
                           sigma::Array{Float64, 2},
                           names::Array{Symbol, 1})
        ## TODO: check for equal sizes

        return new(mu, sigma, names)
    end
end

## define empty constructor
##-------------------------

function SampleMoments()
    return SampleMoments(Array(Float64, 0), Array(Float64, 0, 0),
                         Array(Symbol, 0))
end


## ExpWeighted
##------------

type ExpWeighted <: MuSigmaModel
    mu::Array{Float64, 1}
    sigma::Array{Float64, 2}
    names::Array{Symbol, 1}
    obsWgts::Array{Float64, 1}

    function ExpWeighted(mu::Array{Float64, 1},
                  sigma::Array{Float64, 2},
                  names::Array{Symbol, 1},
                  obsWgts::Array{Float64, 1})
        ## TODO: check for equal sizes

        return new(mu, sigma, names, obsWgts)
    end
end

## define empty constructor
##-------------------------

function ExpWeighted()
    return ExpWeighted(Array(Float64, 0), Array(Float64, 0, 0),
                Array(Symbol, 0), Array(Float64, 0))
end


####################################
## general MuSigmaModel functions ##
####################################

## check for undefined model
##--------------------------

function isDef(mod::MuSigmaModel)
    if isempty(mod.mu)
        return false
    else
        return true
    end
end

import Base.Multimedia.display
function display(mod::MuSigmaModel)
    ## display type information
    typ = typeof(mod)
    println("\ntype: $typ")    

    if !isDef(mod)
        println("Model is still undefined!")
        println("   mu: NA")
        println("sigma: NA")
    else

        ## display mus
        print("mu: ")
        df = DataFrame(name = mod.names, mus = mod.mu)
        display(df)
        print("\n")

        ## display Sigma
        print("sigma: ")
        display(mod.sigma)
        print("\n")
    end
end

## plotting
##---------



################
## estimators ##
################

## sample moments
##---------------

function fitModel(::Type{SampleMoments}, data::Timematr, dat::Date;
                  minObs::Int = 50)
    ## extract data up to given date
    validDates = idx(data) .<= dat

    if sum(validDates) < minObs
        return SampleMoments()
    else
        ## get data
        rets = asArr(data, Float64)[validDates, :]
        mus = mean(rets, 1)[:]
        sigmas = cov(rets)
        return SampleMoments(mus, sigmas, names(data))
    end
end

function fitModel(::Type{ExpWeighted}, data::Timematr, dat::Date;
                  minObs::Int = 5, lambda = 0.96)
    if (lambda < 0) | (1 < lambda)
        error("lambda must be in (0, 1)")
    end

    ## extract data up to given date
    validDates = idx(data) .<= dat

    if sum(validDates) < minObs
        return ExpWeighted()
    else
        ## get data
        rets = asArr(data, Float64)[validDates, :]

        nObs, nAss = size(data)

        ## get weights for observations
        obsWgts = lambda.^((nObs-1):(-1):0)
        wgtsSum = sum(obsWgts)

        ## calculate mus
        mus = sum(rets.*repmat(obsWgts, 1, nAss), 1)/wgtsSum

        ## calculate covariance
        sigmas = rets'*(rets.*repmat(obsWgts, 1, nAss))/wgtsSum
        
        return ExpWeighted(mus[:], sigmas, names(data), obsWgts)
    end
end

