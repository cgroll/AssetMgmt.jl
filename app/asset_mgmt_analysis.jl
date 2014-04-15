using TimeData
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime

tm = TimeData.readTimedata("/home/chris/.julia/v0.3/TimeData/data/logRet.csv")

## create random weights
function randWgts(nObs, nAss)
    simVals = rand(nObs, nAss)
    rowsums = sum(simVals, 2)
    wgts = simVals ./ repmat(rowsums, 1, nAss)
end

wgts = randWgts(10, 3)
AssetMgmt.chkEqualsOne(wgts)

function randInvestments(discRet::Timematr)
    ## create random investments for given returns
    nams = names(discRet)
    
    (nObs, nAss) = size(discRet)

    wgts = randWgts(nObs, nAss)
    df = convert(DataFrame, wgts)
    rename!(df, names(df), nams)

    return AssetMgmt.Investments(df, idx(discRet))
end
    
wgts2 = randInvestments(tm)    

function equWgtInvestments(discRet::Timematr)
    ## create equal weights investments for given returns
    nams = names(discRet)

    (nObs, nAss) = size(discRet)

    wgts = 1/nAss * ones(nObs, nAss)
    df = convert(DataFrame, wgts)
    rename!(df, names(df), nams)

    return AssetMgmt.Investments(df, idx(discRet))
end

wgts3 = equWgtInvestments(tm)
display(wgts3)
