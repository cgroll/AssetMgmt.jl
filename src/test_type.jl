type TimematrFast{T}
    vals::DataFrame
    idx::Array{T, 1}

    function TimematrFast(vals::Array{Float64, 2}, idx::Array{T, 1})
        ## chkIdx(idx)
        ## chkNum(vals)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(DataFrame(vals), idx)
    end
end

function TimematrFast{T}(vals::Array{Float64, 2}, idx::Array{T, 1})
    return TimematrFast{T}(vals, idx)
end
