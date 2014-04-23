using TimeData
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime

## load example data
filename =
    "/home/chris/Dropbox/research_databases/cfm/data/discRetSample_jl.csv"
discRet = TimeData.readTimedata(filename)
    
(nObs, nAss) = size(discRet)

## create equally weighted investments
eqInvs = AssetMgmt.equWgtInvestments(discRet)

## get diversification measures
divIndicators = AssetMgmt.diversification(eqInvs)

## get investment turnover
tOver = AssetMgmt.turnover(eqInvs, discRet)

## get portfolio returns
pfRet = AssetMgmt.invRet(eqInvs, discRet)

## get statistics on portfolio return
retStats2 = AssetMgmt.returnStatistics(pfRet)

## putting everything together
kk = [tOver divIndicators]


## portfolio returns
## portfolio return sigmas
## intended turnover: second wgts matrix needed -> or:
## 	intendedIndicators 
## 

using Plotly
Plotly.signin("cgroll", "2it4121bd9")

(x0,y0) = [1,2,3,4], [10,15,13,17]
(x1,y1) = [2,3,4,5], [16,5,11,9]
response = Plotly.plot([[x0 y0] [x1 y1]])
url = response["url"]
filename = response["filename"]

function datsAsStrings(tm::Timematr)
    dats = idx(tm)
    nObs = size(tm, 1)
    datsAsStr = Array(String, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    datsAsStr
end

dats = datsAsStrings(discRet)

Plotly.plot({dats, core(discRet[:, 1])[:]},
            ["filename"=>"Plot from Julia API (6)",
             "fileopt"=>"overwrite"])

# plot:
# maxweights / significant weights
