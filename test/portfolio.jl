module testPortfolio

using Base.Test
using DataFrames
using Datetime
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running portfolio tests\n")

simVals = rand(1, 8)
simVals = AssetMgmt.makeWeights(simVals)

pf = AssetMgmt.Portfolio(simVals)

end
