##############
## contents ##
##############

types:
- Investments :: quite similar to Timematr, with fields ~vals~ and ~idx~


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

#####################
## get investments ##
#####################

function weights(invs::Investments)
    return array(invs.vals)
end

import TimeData.core
function core(invs::Investments)
    return array(invs.vals)
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

