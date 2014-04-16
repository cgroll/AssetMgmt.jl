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

function randWgts(nObs::Int, nAss::Int)
    simVals = rand(nObs, nAss)
    rowsums = sum(simVals, 2)
    wgts = simVals ./ repmat(rowsums, 1, nAss)
end

function composeDataFrame(vals, nams)
    ## compose DataFrame from data and column names

    ## TODO: unit tests, specify input types
    
    if size(vals, 2) != length(nams)
        error("to compose DataFrame, number of columns and number of
names must match")
    end
    
    df = convert(DataFrame, vals)
    rename!(df, names(df), nams)

    return df
end
