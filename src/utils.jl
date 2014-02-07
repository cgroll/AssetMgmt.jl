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


