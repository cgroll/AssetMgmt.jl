using TimeData
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime

## load example data
filename =
    "/home/chris/Dropbox/research_databases/cfm/data/discRetSample_jl.csv"
discRet = TimeData.readTimedata(filename)
    
## (nObs, nAss) = size(discRet)

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
