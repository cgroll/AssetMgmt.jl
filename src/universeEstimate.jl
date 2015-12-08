abstract UniverseEstimate

type MuSigmaUniverse{T<:MuSigmaModel} <: UniverseEstimate
    Universe::T
    Date::Date
    Data::Timematr
    # EstDetails::Estimator

    function MuSigmaUniverse(univ::T, dat::Date, data::Timematr)
        return new(univ, dat, data)
    end
end

function MuSigmaUniverse{T}(univ::T, dat::Date, data::Timematr)
    return MuSigmaUniverse{T}(univ, dat, data)
end

## check for undefined universe
##-----------------------------

function isDef(univ::UniverseEstimate)
    return isDef(univ.Universe)
end

## display
##--------

import Base.Multimedia.display
function display(mod::UniverseEstimate)
    ## display type information
    typ = typeof(mod)
    println("\ntype: $typ")    

    if !isDef(mod)
        println("Model is still undefined!")
        println("   mu: NA")
        println("sigma: NA")
    else
        ## display model
        print("model: ")
        display(typeof(mod.Universe))
        
        ## display mus
        println("Date: $(mod.Date)")

    end

    ## display data information
    print("Data: ")
    fromDate = mod.Data.idx[1];
    toDate = mod.Data.idx[end];
    nObs, nAss = size(mod.Data)
    println("From: $fromDate, To: $toDate, Size: $nObs x $nAss")
end

##############
## estimate ##
##############

function estimate(t::Type{SampleMoments}, data::Timematr, dat::Date)
    ## estimate model and create UniverseEstimate instance
    modFit = fitModel(t, data, dat)
    return MuSigmaUniverse(modFit, dat, data)
end

function estimate(t::Type{ExpWeighted}, data::Timematr, dat::Date)
    ## estimate model and create UniverseEstimate instance
    modFit = fitModel(t, data, dat)
    return MuSigmaUniverse(modFit, dat, data)
end
