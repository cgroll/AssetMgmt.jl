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

## Moving window sample moments
##-----------------------------

type MovWinSampleMoments <: MuSigmaModel
    mu::Array{Float64, 1}
    sigma::Array{Float64, 2}
    names::Array{Symbol, 1}

    function MovWinSampleMoments(mu::Array{Float64, 1},
                                 sigma::Array{Float64, 2},
                                 names::Array{Symbol, 1})
        ## TODO: check for equal sizes

        return new(mu, sigma, names)
    end
end

## define empty constructor
##-------------------------

function MovWinSampleMoments()
    return MovWinSampleMoments(Array(Float64, 0),
                               Array(Float64, 0, 0),
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

##################
## extract info ##
##################

function getVolas(mod::MuSigmaModel)
    nAss = size(mod.sigma, 1)
    variances = Float64[mod.sigma[ii, ii] for ii=1:nAss]
    return sqrt(variances)
end

################
## estimators ##
################

## no estimator may use data of the given date itself!!
## One could think of the estimator as a forecast for the given date
## made in the morning, hence using data only up to there.

## sample moments
##---------------

function fitModel(::Type{SampleMoments}, data::Timematr, dat::Date;
                  minObs::Int = 50)
    ## extract data up to given date
    validDates = idx(data) .< dat

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

function fitModel(::Type{MovWinSampleMoments},
                  data::Timematr,
                  dat::Date; windSize::Int = 50)
    ## extract data up to given date
    validDates = idx(data) .< dat

    if sum(validDates) < windSize
        return MovWinSampleMoments()
    else
        ## get data
        rets = asArr(data, Float64)[validDates, :]

        ## only take data equal with length equal to window size
        rets = rets[(end-windSize+1):end, :]
        
        mus = mean(rets, 1)[:]
        sigmas = cov(rets)
        return MovWinSampleMoments(mus, sigmas, names(data))
    end
end

function fitModel(::Type{ExpWeighted}, data::Timematr, dat::Date;
                  minObs::Int = 50, lambda = 0.96)
    if (lambda < 0) | (1 < lambda)
        error("lambda must be in (0, 1)")
    end

    ## extract data up to given date
    validDates = idx(data) .< dat

    if sum(validDates) < minObs
        return ExpWeighted()
    else
        ## get data
        rets = asArr(data, Float64)[validDates, :]

        nObs, nAss = size(rets)

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

###########################
## get moments over time ##
###########################

macro defineApplyMuSigmaModelEstimators(myType)
    esc(quote
        function applyMuSigmaModelEstimator(modType::Type{$myType},
                                            data::Timematr)
            ## get all days
            allDats = idx(data)
            
            ## preallocation
            nObs, nAss = size(data)
            musOverTime = Array(Float64, nObs, nAss)
            sigmasOverTime = Array(Float64, nObs, nAss)
            nCovs = int((nAss)*(nAss-1)/2)
            corrOverTime = Array(Float64, nObs, nCovs)
            modelEstimated = falses(nObs)
            
            for ii=1:length(allDats)
                thisDat = allDats[ii]

                ## estimate moments
                mod = AssetMgmt.fitModel(modType, data, thisDat)
                
                ## extract mus and sigmas
                if AssetMgmt.isDef(mod)
                    ## set estimation indicator to true
                    modelEstimated[ii] = true
                    
                    musOverTime[ii, :] = mod.mu'
                    sigmasOverTime[ii, :] =
                        (Float64[sqrt(mod.sigma[jj, jj]) for jj=1:nAss])'
                    
                    ## get correlation matrix
                    d = diagm(1./sqrt(diag(mod.sigma)))
                    corrMatr = d*mod.sigma*d
                    
                    ## extract correlations
                    corrs = vcat([corrMatr[(jj+1:end), jj] for jj=1:(nAss-1)]...)
                    corrOverTime[ii, :] = corrs'
                end
            end

            ## remove non-estimatable dates
            musOverTime = musOverTime[modelEstimated, :]
            sigmasOverTime = sigmasOverTime[modelEstimated, :]
            corrOverTime = corrOverTime[modelEstimated, :]
            
            ## transform to Timematr
            dfMus = DataFrame()
            dfSigmas = DataFrame()
            for ii=1:nAss
                thisNam = names(data)[ii]
                dfMus[thisNam] = musOverTime[:, ii]
                dfSigmas[thisNam] = sigmasOverTime[:, ii]
            end

            dfCorrs = DataFrame()
            for ii=1:size(corrOverTime, 2)
                dfCorrs[ii] = corrOverTime[:, ii]
            end

            dats = idx(data)[modelEstimated]
            musOverTimeTd = Timematr(dfMus, dats)
            sigmasOverTimeTd = Timematr(dfSigmas, dats)
            corrOverTimeTd = Timematr(dfCorrs, dats)
            return (musOverTimeTd, sigmasOverTimeTd, corrOverTimeTd)
        end

    end)
end

for t = (:(SampleMoments), :(MovWinSampleMoments), :(ExpWeighted))
    eval(macroexpand(:(@defineApplyMuSigmaModelEstimators($t))))
end
