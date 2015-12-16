#########################################
## check convex combination constraint ##
#########################################

const precision = 1e-9
function chkEqualsOne(x::Array{Float64, 1})
    if(abs(sum(x) - 1) > precision)
        error("weights must sum to one")
    end
end

function chkEqualsOne(x::Array{Float64, 2})
    if size(x, 2) == 1
        if(abs(sum(x) .- 1) > precision)
            error("weights must sum to one")
        end
    else 
        if any(abs(sum(x, 2) .- 1) .> precision)
            error("weights must sum to one")
        end
    end
end

function chkEqualsOne(df::DataFrame)
    rowSums = sum(convert(Array, df), 2)

    if any(abs(rowSums .- 1) .> precision)
        error("weights must sum to one")
    end
end

function chkEqualsOne(tm::Timematr)
    rowSums = sum(core(tm), 2)

    if any(abs(rowSums .- 1) .> precision)
        error("weights must sum to one")
    end
end

