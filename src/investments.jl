#################################
## definition Investments type ##
#################################

type Investments{T}
    vals::DataFrame
    idx::Array{T, 1}

    function Investments(vals::DataFrame, idx::Array{T, 1})
        ## consists of time index and numeric data (no NAs allowed)
        ## with equal row numbers and rowsums of data equal to one

        ## check constraints
        TimeData.chkIdx(idx)
        TimeData.chkNum(vals)
        chkEqualsOne(vals)

        ## check equal number of rows
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

## required for parametric type declaration
function Investments{T}(vals::DataFrame, idx::Array{T, 1})
    return Investments{T}(vals, idx)
end

## initialization without dates
function Investments(vals::DataFrame)
    nPortfolios = size(vals, 1)
    return Investments(vals, [1:nPortfolios])
end

####################
## display method ##
####################

import Base.Multimedia.display
function display(invs::Investments)
    ## display information about an array
    
    ## set display parameters
    maxDispCols = 5;
    
    ## get type and field information
    typ = typeof(invs)
    println("\ntype: $typ")    
    print("dimensions: ")
    print(size(invs))
    print("\n")
    
    ## get first entries
    (nrow, ncol) = size(invs)    

    showCols = minimum([maxDispCols ncol]);

    Peekidx = DataFrame(idx = invs.idx);
    Peek = [Peekidx invs.vals[:, 1:showCols]];
    display(Peek)
end

function str(invs::Investments)
    display(invs)
end


######################
## Investments size ##
######################

import Base.size
function size(invs::Investments)
    return size(invs.vals)
end

function size(invs::Investments, ind::Int)
    return size(invs.vals, ind)
end

#####################
## get investments ##
#####################

function weights(invs::Investments)
    return array(invs.vals)
end

import TimeData.core
function core(invs::Investments)
    return convert(Array{Float64}, array(invs.vals))
end

###############
## get index ##
###############

import TimeData.idx
function idx(invs::Investments)
    return invs.idx
end

import Base.names
function names(invs::Investments)
    return names(invs.vals)
end

######################
## evolving weights ##
######################

function evolWgtsCore(wgts::Array{Float64,2},
                      rets::Array{Float64,2})
    ## calculate evolving weights without re-balancing
    ## low-level function not to be called directly!
    ##
    ## Output:
    ## 	nObs x nAss Array{Float64, 2} containing evolved portfolio 
    ## 	weights at the end of each day

    invRets = invRetCore(wgts, rets)
    
    weightsDueToPriceChanges = zeros(size(wgts))
    for ii=1:size(rets, 1)
        weightsDueToPriceChanges[ii, :] = wgts[ii, :] .*
        (1 .+ rets[ii, :]) ./ (1 .+ invRets[ii])
    end

    return weightsDueToPriceChanges
end

function evolWgts(invs::Investments, discRet::Timematr)
    ## calculate evolving weights without re-balancing
    ## evolved weights preserve dates -> interpretation: new weights
    ## at the end of the same day
    ##
    ## Output:
    ## 	nObs x nAss Investments object containing evolved portfolio
    ## 	weights at the end of each day

    chkMatchInvData(invs, discRet)

    weightsDueToPriceChanges = evolWgtsCore(AssetMgmt.core(invs),
                                            core(discRet)) 

    wgtsPriceChanges = composeDataFrame(weightsDueToPriceChanges,
                                        names(discRet)) 
    
    return AssetMgmt.Investments(wgtsPriceChanges, idx(discRet))
end

## #######################
## ## Investments push! ##
## #######################

## ## TO IMPROVE: better way to append to dataframe!
## import Base.push!
## function push!(inv::Investments, pf::Portfolio)
##     ## most likely this is very inefficient!!
##     inv.portfolios = [inv.portfolios, pf.weights]
##     return inv
## end

## ######################
## ## Investments plot ##
## ######################

## import Winston.plot
## function plot(invs::Investments)
##     plot(matrix(invs.portfolios))
## end

## #####################################
## ## Investments measure performance ##
## #####################################

## function perform(invs::Investments, td::TimeData)
##     if(size(invs) != size(td))
##         error("investements must match size of data")
##     end
##     tmp = matrix(invs.portfolios) .* matrix(td.vals)
##     rets = sum(tmp, 2)
##     retsDf = DataFrame(rets)
##     tdRets = TimeData(retsDf, td.dates)
##     return tdRets
## end


## function fixWeights(pf::Portfolio, td::TimeData)
##     if(size(pf)[2] != size(td)[2])
##         error("number of assets must match")
##     end

##     nDays = size(td)[1]
##     invs = repmat(matrix(pf.weights), nDays, 1)
##     assetNames = colnames(td.vals)
##     invs = Investments(DataFrame(invs, assetNames))
##     return invs
## end

## function transactions(invs::Investments, td::TimeData)
##     invsArr = matrix(invs.portfolios)
##     rets = matrix(td.vals)

    

    
##     return transTd
## end

## function evolve(invs::Investments, td::TimeData)
##     nAss = size(invs)[2]
    
##     ## get percentage portfolio returns
##     pRetsDt = perform(invs, td)

##     factors = (1 + matrix(td.vals)/100) ./ repmat(1 +
##                                                  matrix(pRetsDt.vals)/100, 1, nAss)

##     newWeights = matrix(invs.portfolios) .* factors
##     newWeightsDf = DataFrame(newWeights, colnames(td.vals))
##     invs = Investments(newWeightsDf)
## end

## function evolve(pf::Portfolio, td::TimeData)
##     retP = (matrix(pf.weights) * matrix(td.vals)')/100

##     factors = (1 + matrix(td.vals)/100) / (1+retP[1])
##     newWeights = matrix(pf.weights) .* factors
##     newWeightsDf = DataFrame(newWeights, colnames(td.vals))
##     pfNew = Portfolio(newWeightsDf)
## end

## function requiredInvestementChanges(invs::Investments, evolved::Investments)
##     nAss = size(invs)[2]
##     invsArr = matrix(invs.portfolios)
##     evolArr = matrix(evolved.portfolios)

##     trans = [zeros(1, nAss); invsArr[2:end, :] - evolArr[1:(end-1), :]]

##     transDf = DataFrame(trans, colnames(invs.portfolios))
##     return transDf
## end
