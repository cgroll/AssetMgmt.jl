#########################################
## check convex combination constraint ##
#########################################

const precision = 1e-6
function chkEqualsOne(x::Array{Float64, 1})
    if(abs(sum(x) - 1) > precision)
        error("weights must sum to one")
    end
end

function chkEqualsOne(x::Array{Float64, 2})
    if size(x, 2) == 1
        if(abs(sum(x) - 1) > precision)
            error("weights must sum to one")
        end
    else 
        if any(abs(sum(x, 2) - 1) .> precision)
            error("weights must sum to one")
        end
    end
end

function chkEqualsOne(df::DataFrame)
    rowSums = sum(array(df), 2)

    if any(abs(rowSums) - 1 .> precision)
        error("weights must sum to one")
    end
end

function chkEqualsOne(tm::Timematr)
    rowSums = sum(core(tm), 2)

    if any(abs(rowSums) - 1 .> precision)
        error("weights must sum to one")
    end
end

function makeWeights(matr::Array{Float64, 2})
    ## normalize matrix to have row sums of 1
    nObs = size(matr, 1)
    for ii=1:nObs
        matr[ii, :] = matr[ii, :]./sum(matr[ii, :])
    end
    return matr
end

function chkNumDf(df::DataFrame)
    n = ncol(df)
    for ii=1:n
        ## check for numeric values
        if(!issubtype(types(df)[ii], Number))
            error("all columns must be numeric for conversion")
        end
        if(issubtype(types(df)[ii], Bool))
            error("all columns must be numeric for conversion")
        end
    end
end

function chkNum(df::DataFrame)
    if any(isna(df))
        error("no NAs allowed in Portfolios or Investments")
    end
    chkNumDf(df)
end

