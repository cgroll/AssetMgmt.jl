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

## get random portfolio returns
randInvs = AssetMgmt.randInvestments(discRet)
randRet1 = AssetMgmt.invRet(randInvs, discRet, name=:randPort1)
randInvs = AssetMgmt.randInvestments(discRet)
randRet2 = AssetMgmt.invRet(randInvs, discRet, name=:randPort2)

## AssetMgmt.plotPfPerformance(eqInvs, discRet, randRet2, strName=:equWgts)
## AssetMgmt.plotWithBMs(pfRet, (randRet1, randRet2)...)
AssetMgmt.plotPfPerformance(eqInvs, discRet, randRet1, randRet2, strName=:equWgts)



## get diversification measures
divIndicators = AssetMgmt.diversification(eqInvs)

## get investment turnover
tOver = AssetMgmt.turnover(eqInvs, discRet)
intTOver = AssetMgmt.intendedTurnover(eqInvs)

## enlargen default plot size
set_default_plot_size(24cm, 14cm)

######################
## plotting results ##
######################













###############################
## histogram with statistics ##
###############################



moments = DataFrame()
moments[:mus] = array(mus)[:]
moments[:sigmas] = array(sigmas)[:]
moments[:names] = nams

pfMoments = DataFrame()
pfMoments[:mu] = retStats.mu
pfMoments[:sigma] = retStats.sigma
pfMoments[:name] = string(names(pfRet)[1])

moments = DataFrame()
moments[:mus] = [array(mus)[:], retStats.mu]
moments[:sigmas] = [array(sigmas)[:], retStats.sigma]
typs = [["asset" for ii=1:nAss], "pf"]
moments[:typ] = typs
nams = Array(ASCIIString, (nAss+1))
for ii=1:nAss
    nams[ii] = string(names(sigmas)[ii])
end
nams[end] = string(names(pfRet)[1])
moments[:names] = nams

plot(layer(moments, x="sigmas", y="mus", color="typ",
           Geom.point),
     layer(moments, x="sigmas", y="mus", label="names",
           Geom.label),
     Guide.xlabel("sigma"),
     Guide.ylabel("mu"),
     Guide.title("mu-sigma combinations"))


plot(layer(moments, x="sigmas", y="mus",
           Geom.point, Theme(default_color=color("orange"))),
     layer(pfMoments, x="sigma", y="mu", label="name",
           Geom.label),
     layer(pfMoments, x="sigma", y="mu",
           Geom.point,
           Theme(default_color=color("black"),
                 default_point_size(10))),
     Guide.xlabel("sigma"),
     Guide.ylabel("mu"),
     Guide.title("mu-sigma combinations"), )


plot(layer(moments, x="sigmas", y="mus", label="names",
           Geom.point),
     layer(pfMoments, x="sigma", y="mu", label="name",
           Geom.point),
     Guide.xlabel("sigma"),
     Guide.ylabel("mu"),
     Guide.title("mu-sigma combinations"))


moments[9, 1] = pfMoments[:mu]
moments[9, 2] = pfMoments[:sigma]
moments[9, 3] = pfMoments[:names]

plot(layer(moments, x="sigmas", y="mus", label="names",
           Geom.point),
     layer(moments, x="sigmas", y="mus", label="names",
           Geom.label),
     layer(pfMoments, x="sigma", y="mu", label="name",
           Geom.label),
     layer(pfMoments, x="sigma", y="mu", label="name",
           Geom.point),
     Guide.xlabel("sigma"),
     Guide.ylabel("mu"),
     Guide.title("mu-sigma combinations"))
     
## portfolio returns
## portfolio return sigmas
## intended turnover: second wgts matrix needed -> or:
## 	intendedIndicators 
## 


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


function plot(tm::Timematr)
    ## plot timematr object with date axis
end

plot(kk, x="Idx", y="value", color="variable", Geom.line)



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

