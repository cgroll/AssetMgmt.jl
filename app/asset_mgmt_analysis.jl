using TimeData
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime

## load example data
filename =
    "/home/chris/Dropbox/research_databases/cfm/data/discRetSample_jl.csv"

## large file
filename =
    "/home/chris/Dropbox/research_databases/cfm/data/all_sp500_clean_logRet_jl.csv"

discRet = TimeData.readTimedata(filename)

(nObs, nAss) = size(discRet)    

## create equally weighted investments
eqInvs = AssetMgmt.equWgtInvestments(discRet)

## get diversification measures
divIndicators = AssetMgmt.diversification(eqInvs)

## get investment turnover
tOver = AssetMgmt.turnover(eqInvs, discRet)

## enlargen default plot size
set_default_plot_size(24cm, 14cm)

## plot tOver
plot(x=[1:nObs], y=array(tOver.vals[:,1]),
     Guide.xlabel("time"), Guide.ylabel("turnover"),
     Guide.title("turnover over time"),
     Scale.x_continuous(minvalue=0, maxvalue=(nObs-1)))

## get portfolio returns
pfRet = AssetMgmt.invRet(eqInvs, discRet)
plot(x=[1:nObs], y=array(100*pfRet.vals[:,1]),
     Guide.xlabel("time"), Guide.ylabel("return"),
     Guide.title("portfolio return (percentage)"),
     Scale.x_continuous(minvalue=0, maxvalue=(nObs-1)),
     Geom.line)

myplot = vstack(plot(x=[1:nObs], y=array(tOver.vals[:,1])),
     plot(x=[1:nObs], y=array(100*pfRet.vals[:,1])))

## get statistics on portfolio return
retStats2 = AssetMgmt.returnStatistics(pfRet)

## putting everything together
kk = [tOver divIndicators]


## portfolio returns
## portfolio return sigmas
## intended turnover: second wgts matrix needed -> or:
## 	intendedIndicators 
## 

function datsAsStrings(tm::Timematr)
    nObs = size(tm, 1)
    datsAsStr = Array(ASCIIString, nObs)
    idxes = idx(tm)
    for ii=1:nObs
        datsAsStr[ii] = string(idxes[ii])
    end
    return datsAsStr
end

df = discRet.vals
datsAsStr = datsAsStrings(discRet)
vals = core(discRet)

myplot = plot(x=datsAsStr, y=vals[:, 1])
for ii=2:nAss
    layer(x=datsAsStr, y=vals[:, ii], Geom.point)
end


df = copy(discRet.vals)
nams = names(df)
dats = datsAsStrings(discRet)
df[:Idx] = dats
kk = stack(df, nams)

import Gadfly.plot
function plot(tm::Timematr)
    ## plot timematr object with date axis
    dats = datsAsStrings(tm)
    
    plot(x=dats, y=core(tm), Geom.line)
end

plot(kk, x="Idx", y="value", color="variable", Geom.line)

function plotCumPrices(tm::Timematr)
    ## get dates and names
    dats = datsAsStrings(tm)
    nams = names(tm.vals)

    ## get copy of data
    vals = core(tm)

    ## cumulate prices
    cumVals = cumsum(vals, 1)

    ## transform to dataframe
    cumDf = AssetMgmt.composeDataFrame(cumVals, nams)

    ## add index column
    cumDf[:Idx] = dats

    ## reshape data
    stackedCumPrices = stack(cumDf, nams)

    plot(stackedCumPrices, x="Idx", y="value",
         color="variable", Geom.line)
end
    

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

