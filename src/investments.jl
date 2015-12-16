##############
## contents ##
##############

## types:
## - Investments :: quite similar to Timematr, with fields ~vals~ and ~idx~


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
        TimeData.chkNum(vals)           # numeric values only?
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

import Base.ndims
function ndims(invs::Investments)
    return ndims(invs.vals)
end

#####################
## get investments ##
#####################

function weights(invs::Investments)
    return array(invs.vals)
end

import TimeData.core
function core(invs::Investments)
    return convert(Array, invs.vals)
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

#############
## convert ##
#############

import Base.convert
function convert(::Type{Timematr}, invs::Investments)
    return Timematr(invs.vals, idx(invs))
end

function convert(::Type{DataFrame}, invs::Investments)
    return [DataFrame(idx = invs.idx) invs.vals]
end

## asArr
##------

import TimeData.asArr
function asArr(invs::Investments)
    return convert(Array, invs.vals)
end

########
## IO ##
########

function readInvestments(filename::String)
    td = readTimedata(filename)
    return Investments(td.vals, idx(td))
end

function writeInvestments(filename::String, invs::Investments)
    ## create large dataframe
    idxDf = DataFrame(idx = idx(invs));
    df = [idxDf invs.vals];
    writetable(filename, df)
end

#############
## isequal ##
#############

import Base.isequal
function isequal(invs::Investments, invs2::Investments)
    typeEqu = isequal(typeof(invs), typeof(invs2))
    valsEqu = isequal(invs.vals, invs2.vals)
    idxEqu = isequal(invs.idx, invs2.idx)
    equ = (valsEqu & idxEqu & typeEqu)
    return equ
end

##########
## copy ##
##########

function Base.copy(invs::Investments)
    copiedVals = copy(invs.vals)
    copiedInvs = AssetMgmt.Investments(copiedVals, idx(invs))
    return copiedInvs
end

###############################################
## check matching investment and return data ##
###############################################

function chkMatchInvData(invs::Investments, discRet::Timematr)
    ## test whether investments and return data are matching
    ##
    ## Matching: all investement dates are entailed in return data
    ## dates.
    ##
    ## Output: error when inputs don't match

    ## check for conforming dates and assets
    if !issubset(idx(invs), idx(discRet))
        error("indices / dates of investments must be contained in
    dates of return data")
    end

    if AssetMgmt.names(invs) != names(discRet)
        error("asset names of investments and returns must coincide")
    end
end

#######################################
## find trading days for investments ##
#######################################

function isTradingDay(invs::Investments, discRet::Timematr)
    ## most changes in investment weights are caused by simple price
    ## changes without actual trading. This function finds all days
    ## with active rebalancing of weights. If evening weights
    ## (achieved through price changes) deviate from next day morning
    ## weights, next day will be called trading day.
    ##
    ## return dates may deviate from investment dates as long as all
    ## investment dates are also contained in return dates.
    ##
    ## trading day indicators are returned for all investment dates.

    ## get automatic daily changes of weights
    wgtsPriceChanges = evolWgts(invs, discRet)

    ## get values without metadata
    invsArr = AssetMgmt.core(invs)
    wgtsPriceChangesArr = AssetMgmt.core(wgtsPriceChanges)

    ## preallocate trading indicator
    nObs = size(invs, 1)
    isTrading = falses(nObs)

    ## first day is defined as trading day
    isTrading[1] = true

    for ii=2:nObs
        ## get weight changes from evening weights last day to morning
        ## weights of current day
        wgtChange =
            sum(abs(invsArr[ii, :] - wgtsPriceChangesArr[ii-1, :]))
        if wgtChange > 1e-12
            isTrading[ii] = true
        end
    end
    
    return isTrading
end

######################
## getindex methods ##
######################

## invs[SingleColumnIndex] => Timematr
## invs[MultiColumnIndex] => Timematr (if columns sum up to one:
## Investments?) 
## invs[SingleRowIndex, SingleColumnIndex] => Scalar
## invs[SingleRowIndex, MultiColumnIndex] => Timematr
## invs[MultiRowIndex, SingleColumnIndex] => Timematr
## invs[MultiRowIndex, MultiColumnIndex] => Timematr (if columns sum
## up to one: Investments)

## TimeData types do ALWAYS preserve types when indexing.

typealias ColumnIndex Union(Real, Symbol)

# invs[SingleColumnIndex] => Timematr
function Base.getindex(invs::Investments, col_ind::ColumnIndex)
    tm = convert(Timematr, invs)
    return tm[col_ind]
end

# invs[MultiColumnIndex] => Timematr (Investments for simple
# re-ordering)  
function Base.getindex{T <: ColumnIndex}(invs::Investments,
                                         col_inds::AbstractVector{T})
    output = convert(Timematr, invs)[col_inds]
    
    ## are all columns selected?
    nAss = size(invs, 2)
    if length(col_inds) == nAss
        if sort(col_inds) == sort(names(invs))
            output = AssetMgmt.Investments(output.vals, idx(invs))
        end
    end
    return output
end

# invs[SingleRowIndex, SingleColumnIndex] => Timematr
function Base.getindex(invs::Investments, row_ind::Real,
                       col_ind::ColumnIndex)
    tm = convert(Timematr, invs)
    return tm[row_ind, col_ind]
end

# invs[SingleRowIndex, MultiColumnIndex] => Timematr
function Base.getindex{T <: ColumnIndex}(invs::Investments,
                                         row_ind::Real,
                                         col_inds::AbstractVector{T})
    output = convert(Timematr, invs)[row_ind, col_inds]

    ## are all columns selected?
    nAss = size(invs, 2)
    if length(col_inds) == nAss
        if sort(col_inds) == sort(names(invs))
            output = AssetMgmt.Investments(output.vals, idx(invs))
        end
    end
    return output
end

# invs[MultiRowIndex, SingleColumnIndex] => Timematr
function Base.getindex{T <: Real}(invs::Investments,
                                  row_inds::AbstractVector{T},
                                  col_ind::ColumnIndex)
    tm = convert(Timematr, invs)
    return tm[row_inds, col_ind]
end

# invs[MultiRowIndex, MultiColumnIndex] => Timematr
function Base.getindex{R <: Real, T <: ColumnIndex}(invs::Investments,
                                                    row_inds::AbstractVector{R},
                                                    col_inds::AbstractVector{T})
    output = convert(Timematr, invs)[row_inds, col_inds]

    ## are all columns selected?
    nAss = size(invs, 2)
    if length(col_inds) == nAss
        if sort(col_inds) == sort(names(invs))
            output = AssetMgmt.Investments(output.vals, idx(invs))
        end
    end
    return output
end


