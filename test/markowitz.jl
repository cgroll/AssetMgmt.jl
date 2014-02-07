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
univ.mvp

end
