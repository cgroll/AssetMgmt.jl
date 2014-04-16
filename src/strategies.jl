function randHolding(discRet::Timematr)
    ## create random weights and hold them without re-balancing 

end

function randInvestments(discRet::Timematr)
    ## create random investments for given returns
    nams = names(discRet)
    
    (nObs, nAss) = size(discRet)

    wgts = randWgts(nObs, nAss)
    df = convert(DataFrame, wgts)
    rename!(df, names(df), nams)

    return AssetMgmt.Investments(df, idx(discRet))
end

function equWgtInvestments(discRet::Timematr)
    ## create equal weights investments for given returns
    nams = names(discRet)

    (nObs, nAss) = size(discRet)

    wgts = 1/nAss * ones(nObs, nAss)
    df = convert(DataFrame, wgts)
    rename!(df, names(df), nams)

    return AssetMgmt.Investments(df, idx(discRet))
end
