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

######################
## evolving weights ##
######################

wgts = [0.4 0.3 0.3; 0.3 0.4 0.3]
rets = [0.08 0.02 0.06; 0.08 0.02 0.06]
pRets = AssetMgmt.invRetCore(wgts, rets)
expWgts = [0.4090909090909091 0.28977272727272724 0.30113636363636365;
           0.30857142857142855 0.38857142857142857 0.3028571428571428]
@test_approx_eq(expWgts, AssetMgmt.evolWgtsCore(wgts, rets))


end
