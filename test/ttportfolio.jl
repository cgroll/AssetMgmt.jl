module testPortfolio

using Base.Test
using DataFrames
using DataArrays
using Datetime
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running portfolio tests\n")

simVals = rand(1, 8)
simVals = AssetMgmt.makeWeights(simVals)

df = DataFrame(simVals)
pf = AssetMgmt.Portfolio(df)
pf = AssetMgmt.Portfolio(simVals)

simVals = rand(4, 3)
simVals = AssetMgmt.makeWeights(simVals)
pf = AssetMgmt.Portfolio(simVals)


simVals = rand(1, 8)
@test_throws AssetMgmt.Portfolio(simVals)

simVals = rand(1, 8)
simVals = AssetMgmt.makeWeights(simVals)
df = DataFrame(simVals)
df[1, 2] = NA
@test_throws AssetMgmt.Portfolio(df)

end
