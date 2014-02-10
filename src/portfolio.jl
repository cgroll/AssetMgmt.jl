###########################
## define Portfolio type ##
###########################

## portfolio constraints:
## - numeric values
## - no NAs
## - convex combination

## type portfolio: rows summing up to one
type Portfolio
    vals::DataFrame

    function Portfolio(vals)
        chkNum(vals)
        chkEqualsOne(vals)
        new(vals)
    end
end

###################################
## Portfolio outer constructors  ##
###################################

## initialize from core components
function Portfolio(vals::Array{Float64, 2},
                   nams::Array{Union(ASCIIString,UTF8String),1})
    if size(vals, 2) != length(nams)
        error("number of names must equal number of weights")
    end

    df = DataFrame(vals)
    names!(df) = nams
    return Portfolio(df)
end

## initialize single portfolio from core components
function Portfolio(vals::Array{Float64, 1},
                   nams::Array{Union(ASCIIString,UTF8String),1})
    if length(vals) != length(nams)
        error("number of names must equal number of weights")
    end

    df = DataFrame(vals')
    names!(df) = nams
    return Portfolio(df)
end


## initialize from timematr
function Portfolio(tm::Timematr)
    return Portfolio(core(tm), names(tm))
end

## initialize from one-dimensional array (column vector)
function Portfolio(x::Array{Float64, 1})
    df = DataFrame(x')
    return Portfolio(df)
end

## initialize from two-dimensional array (row vector)
function Portfolio(x::Array{Float64, 2})
    df = DataFrame(x)
    return Portfolio(df)
end

###########################
## information retrieval ##
###########################

import Base.names
names(pf::Portfolio) = names(pf.vals)

weights(pf::Portfolio) = array(pf.vals)

import DataFrames.array
array(pf::Portfolio) = array(pf.vals)

import TimeData.names
core(pf::Portfolio) = array(pf.vals)

#######################
## display Portfolio ##
#######################

## import Base.Multimedia.display
## function display(pf::Portfolio)
##     ## get type and field information
##     typ = typeof(pf)
##     println("\ntype: $typ")    
##     print("dimensions: ")
##     print(size(pf.weights, 2))
##     print("\n")

##     df = DataFrame((pf.weights)', pf.names);
##     display(df)
## end

function display(pf::Portfolio)
    
    nAss = size(pf, 2)
    print("Portfolio of $nAss assets:\n")

    if size(pf, 1) > 1
        display(pf.vals)
    else
        maxNameLength = maximum([length(t) for t in names(pf)])+2
        for ii=1:nAss
            print(@sprintf("%6s | %4f \n",
                           names(pf)[ii], pf.vals[1, ii]))
        end
    end
end


## ########################
## ## Portfolio setindex ##
## ########################

## ## problem: requires copy of complete object
## function setindex!(pf::Portfolio, args...)
##     pfCopy = copy(pf)
##     setindex!(pfCopy.weights, args...)
##     chkEqualsOne(pf)
##     if (abs(sum(pfCopy.weights) - 1) > 1e-10)
##         error("weights must sum to one")
##     else
##         setindex!(pf.weights, args...)
##     end
## end

## better implementation? Only copy changed values
## function setindex!(pf::Portfolio, x, args...)
##     oldVals = getindex(pf.weights, args...)
##     setindex!(pf.weights, x, args...)
##     try
##         chkEqualsOne(pf)
##     catch
##         setindex!(pf.weights, oldVals, args...)
##     end
## end


## ####################
## ## Portfolio copy ##
## ####################

## import Base.copy
## function copy(pf::Portfolio)
##     newDf = copy(pf.weights)
##     newPf = Portfolio(newDf)
##     return newPf
## end

## ####################
## ## Portfolio plot ##
## ####################

## import Winston.plot
## function plot(x::Portfolio)
##     ## visualize portfolio weights
##     weights = dfrow(pf.weights, 1)
##     minY = minimum([minimum(weights) 0])
##     maxY = ceil(1.05*maximum(weights)*10)/10
##     p = FramedPlot(yrange=(minY, maxY), title="Portfolio weights")
##     a = Points([1:length(weights)], weights, kind="filled circle")
##     add(p, a)
## end

########################################
## Portfolio other overloaded methods ##
########################################

import Base.size
size(pf::Portfolio) = size(pf.vals)
size(pf::Portfolio, int::Integer) = size(pf.vals, int)

## import Base.getindex
## getindex(pf::Portfolio, args...) = getindex(pf.weights, args...)

