module testInvestments

using Base.Test
using DataFrames
using Datetime
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running investments tests\n")

## using Markowitz

vals = rand(8, 4)
vals = AssetMgmt.makeWeights(vals)
valsDf = DataFrame(vals)

invs = AssetMgmt.Investments(valsDf, [1:8])


end
