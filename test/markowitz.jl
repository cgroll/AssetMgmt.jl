module testUniverse

using Base.Test
using DataFrames
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running universe tests\n")

df = DataFrame(rand(500, 4))
mus = AssetMgmt.mean(df, 1)
covMatr = AssetMgmt.cov(df)

univ = AssetMgmt.Universe(mus, covMatr)

###############
## real data ##
###############

dataFile = string(Pkg.dir("AssetMgmt"), "/data/discr_ret.csv")
data = readTimedata(dataFile)

## get universe
univ = AssetMgmt.Universe(data)

## get mvp
pf = AssetMgmt.mvp(univ)

## get moments for portfolio
AssetMgmt.getPMean(pf, univ)
AssetMgmt.getPVar(pf, univ)
AssetMgmt.getPMoments(pf, univ)

## get mu grid for efficient frontier
effMus = AssetMgmt.getMuGrid(univ)
effPfs = AssetMgmt.effPf(univ, effMus)

end
