#########################################
## check convex combination constraint ##
#########################################

function chkEqualsOne(x::Array{Float64, 1})
    if(abs(sum(x) - 1) > 1e-10)
        error("weights must sum to one")
    end
end

function chkEqualsOne(df::DataFrame)
    rowSums = sum(array(df), 2)

    if any(abs(rowSums) - 1 .> 1e-10)
        error("weights must sum to one")
    end
end

function chkEqualsOne(tm::Timematr)
    rowSums = sum(core(tm), 2)

    if any(abs(rowSums) - 1 .> 1e-10)
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
