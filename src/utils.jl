############################
## grossMomentsLogMoments ##
############################

function grossRetMomentsToLogRetMoments(mu::Float64, sigma::Float64)
    ## arithmetic moments R to r^{log}
    
    ## calculate log variance
    varLog = log(1 + sigma^2/mu^2)
    muLog = log(mu) - 0.5*varLog
    sigmaLog = sqrt(varLog)

    return muLog, sigmaLog
end

function logRetMomentsToGrossRetMoments(muLog::Float64,
                                        sigmaLog::Float64)
    ## logarithmic moments r^{log} to R
    mu = exp(muLog + 0.5*sigmaLog^2)
    varGross = (exp(sigmaLog^2) - 1)*exp(2*muLog + sigmaLog^2)

    return mu, sqrt(varGross)
end

#######################
## scaling functions ##
#######################

## Note: initialized without any scaling by now
## Problem: mus should not be scaled linearly, as discrete returns may
## not be aggregated over time linearly. A better way might be to make
## a distributional assumption (log-normal) and scale geometric means
## (or arithmetic means for log returns)

function defaultMuSigmaScaling(mu::Float64, sigma::Float64;
                               scalingFactor = 52)
    ## - annualized arithmetic mean and sigma shown
    ## - via annualized log moments
    ## - percentage values
    ## Assumptions:
    ## - log-normality to get log moments
    ## - independence over time for square-root-of-time scaling
    ## - constant weights over time
    ## - constant moments over time

    ## net to gross
    muGross = mu + 1

    ## get log moments
    muLog, sigmaLog = grossRetMomentsToLogRetMoments(muGross, sigma)

    ## annualize log moments
    muLogAnnual = muLog*scalingFactor
    sigmaLogAnnual = sqrt(scalingFactor)*sigmaLog

    ## translate to gross moments
    muGrossAnnual, sigmaAnnual =
        logRetMomentsToGrossRetMoments(muLogAnnual,
                                       sigmaLogAnnual)

    ## translate to net returns
    muNetAnnual = muGrossAnnual - 1

    ## translate to percentages
    muNetAnnualPercent = muNetAnnual * 100
    sigmaAnnualPercent = sigmaAnnual * 100

    return muNetAnnualPercent, sigmaAnnualPercent
end


## applied to vectors
function defaultMuSigmaScaling(mus::Array{Float64, 1},
                               sigmas::Array{Float64, 1};
                               scalingFactor = 52)
    ## preallocation
    nMoments = size(mus, 1)
    scaledMus = ones(nMoments)
    scaledSigmas = ones(nMoments)

    for ii=1:nMoments
        thisMu, thisSigma =
            defaultMuSigmaScaling(mus[ii], sigmas[ii])
        scaledMus[ii] = thisMu
        scaledSigmas[ii] = thisSigma
    end
    return scaledMus, scaledSigmas
end

##########################################
## symbol / string conversion functions ##
##########################################

function symbToStr(symbs::Array{Symbol, 1})
    return UTF8String[string(symb) for symb in symbs]
end

function symbToStr(symbs::DataArray{Symbol, 1})
    return UTF8String[string(symb) for symb in symbs]
end

function strToSymb(strs::Array{UTF8String, 1})
    return Symbol[symbol(xx) for xx in strs]
end

function strToSymb(strs::DataArray{UTF8String, 1})
    return Symbol[symbol(xx) for xx in strs]
end

function strToSymb(strs::DataArray{String, 1})
    return Symbol[symbol(xx) for xx in strs]
end

#######################
## calculate moments ##
#######################

## single portfolio, single universe
function getPMean(wgts::Array{Float64, 1}, mus::Array{Float64, 1})
    return (wgts'*mus)[1]
end

## multiple portfolios, single universe
function getPMean(wgts::Array{Float64, 2}, mus::Array{Float64, 1})
    nPfs = size(wgts, 1)
    pfMus = ones(nPfs)
    for ii=1:nPfs
        pfMus[ii] = getPMean(wgts[ii, :][:], mus)
    end
    return pfMus
end

## single portfolio, single universe
function getPVar(wgts::Array{Float64, 1}, covMatr::Array{Float64, 2})
    return (wgts'*covMatr*wgts)[1]
end

## multiple portfolios, single universe
function getPVar(wgts::Array{Float64, 2}, covMatr::Array{Float64, 2})
    nPfs = size(wgts, 1)
    pfVariances = ones(nPfs)
    for ii=1:nPfs
        pfVariances[ii] = getPVar(wgts[ii, :][:], covMatr)
    end
    return pfVariances
end

####################################
## statistic functions DataFrames ##
####################################

import Base.mean
function mean(df::DataFrame, int::Integer)
    if int==2
        error("for row-wise mean, use rowmean instead")
    else
        mus = DataFrame(mean(array(df), 1), names(df))
    end
end

import Base.cov
function cov(df::DataFrame)
    return DataFrame(cov(array(df)), names(df))
end

function corrcov(covMatr::DataFrame)
    d = diagm(1/sqrt(diag(array(covMatr))))
    return DataFrame(d*array(covMatr)*d, names(covMatr))
end

##################################
## create random weights matrix ##
##################################

## function randWgts(nObs::Int, nAss::Int)
##     ## create random weights
##     ##
##     ## Output:
##     ## 	nObs x nAss Array{Float64,2} containing portfolio weights in
##     ## 	each row
    
##     simVals = rand(nObs, nAss)
##     rowsums = sum(simVals, 2)
##     wgts = simVals ./ repmat(rowsums, 1, nAss)
## end

##################################################
## normalize matrix values to represent weights ##
##################################################

function makeWeights(matr::Array{Float64, 2})
    ## normalize matrix to have row sums of 1
    nObs = size(matr, 1)
    for ii=1:nObs
        matr[ii, :] = matr[ii, :]./sum(matr[ii, :])
    end
    return matr
end


#################################
## download interest rate data ##
#################################

function getTBill()
    ## get Federal funds effective rate

    tbillsURL =
        "http://www.federalreserve.gov/datadownload/Output.aspx?rel=H15&series=646250c87b1afd04cc6774796fc0cec8&lastObs=&from=&to=&filetype=csv&label=include&layout=seriescolumn"


    rawSplitted = download(tbillsURL) |>
    readall |>
    s -> split(s,"\r\n") |> # get individual lines
    s -> map(l -> split(l, ","), s)     # decompose each line into
                                        # dates and rates

    maxNumberDates = length(rawSplitted)
    dats = Array(Date{ISOCalendar}, maxNumberDates)
    intRatesStr = Array(String, maxNumberDates)
    skipLines = rep(false, maxNumberDates)

    for ii=1:maxNumberDates
        try
            dats[ii] = date(rawSplitted[ii][1])
            intRatesStr[ii] = rawSplitted[ii][2]
            if intRatesStr[ii] == "ND"
                skipLines[ii] = true
                println("line ", ii, " skipped: no observation")
            end
        catch
            println("line ", ii, " skipped: no date in line")
            skipLines[ii] = true
            continue
        end
    end

    intRatesValid = intRatesStr[!skipLines]
    intRates = Array(Float64, length(intRatesValid))
    for ii=1:length(intRatesValid)
        intRates[ii] = parsefloat(intRatesValid[ii])
    end

    intRatesDf = DataFrame(FEDrate = intRates)
    return Timematr(intRatesDf, dats[!skipLines])
end
