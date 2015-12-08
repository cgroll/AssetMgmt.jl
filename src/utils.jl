##########################################
## symbol / string conversion functions ##
##########################################



#######################
## scaling functions ##
#######################

## Note: initialized without any scaling by now
## Problem: mus should not be scaled linearly, as discrete returns may
## not be aggregated over time linearly. A better way might be to make
## a distributional assumption (log-normal) and scale geometric means
## (or arithmetic means for log returns)

function scaleMu(mu::Float64; scalingFactor = 52)
    return mu
end

function scaleMu(mus::Array{Float64, 1}; scalingFactor = 52)
    return Float64[scaleMu(xx) for xx in mus]
end

function scaleVola(vola::Float64; scalingFactor = 52)
    return vola
end

function scaleVola(volas::Array{Float64, 1}; scalingFactor = 52)
    return Float64[scaleVola(xx) for xx in volas]
end


####################################
## statistic functions DataFrames ##
####################################

function Base.mean(df::DataFrame, int::Integer)
    if int==2
        error("for row-wise mean, use rowmean instead")
    else
        mus = DataFrame(mean(array(df), 1), names(df))
    end
end

function Base.cov(df::DataFrame)
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

###############################################
## check matching investment and return data ##
###############################################

## function chkMatchInvData(invs::Investments, discRet::Timematr)
##     ## test whether investments and return data are matching
##     ##
##     ## Output: error when inputs don't match

##     ## check for conforming dates and assets
##     if AssetMgmt.idx(invs) != idx(discRet)
##         error("indices / dates of investments and returns must
## coincide")
##     end

##     if AssetMgmt.names(invs) != names(discRet)
##         error("asset names of investments and returns must coincide")
##     end
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
