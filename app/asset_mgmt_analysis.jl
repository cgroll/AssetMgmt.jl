using TimeData
## using Plotly
## using Gadfly
include("/home/chris/.julia/v0.3/Gadfly/src/Gadfly.jl")
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime

## load example data
filename =
    "/home/chris/Dropbox/research_databases/cfm/data/discRetSample_jl.csv"

## large file
## filename =
    ## "/home/chris/Dropbox/research_databases/cfm/data/all_sp500_clean_logRet_jl.csv"

discRet = TimeData.readTimedata(filename)
(nObs, nAss) = size(discRet)
## create equally weighted investments
eqInvs = AssetMgmt.equWgtInvestments(discRet)
## get portfolio returns
pfRet = AssetMgmt.invRet(eqInvs, discRet, name=:equallyWeighted)

## get random portfolio returns as benchmarks
randInvs = AssetMgmt.randInvestments(discRet)
randRet1 = AssetMgmt.invRet(randInvs, discRet, name=:randPort1)
randInvs = AssetMgmt.randInvestments(discRet)
randRet2 = AssetMgmt.invRet(randInvs, discRet, name=:randPort2)

## create visual analysis
## AssetMgmt.plotPfPerformance(eqInvs, discRet, randRet1, randRet2, strName=:equWgts)

## get filtered weights
fltWgts = AssetMgmt.regularRB(eqInvs, discRet, freq=250)
AssetMgmt.plotPfPerformance(fltWgts, discRet, pfRet, randRet1, strName=:equWgts_flt250)

## enlargen default plot size
set_default_plot_size(24cm, 14cm)



########################
## plots using plotly ##
########################

using Plotly
Plotly.signin("cgroll", "2it4121bd9")

(x0,y0) = [1,2,3,4], [10,15,13,17]
(x1,y1) = [2,3,4,5], [16,5,11,9]
response = Plotly.plot([[x0 y0] [x1 y1]])
url = response["url"]
filename = response["filename"]


dats = datsAsStrings(discRet)

Plotly.plot({dats, core(discRet[:, 1])[:]},
            ["filename"=>"Plot from Julia API (6)",
             "fileopt"=>"overwrite"])

# plot:
# maxweights / significant weights

