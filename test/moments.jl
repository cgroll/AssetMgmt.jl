module testMoments

using Base.Test
using DataFrames
using Datetime
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running moments tests\n")

#########################
## test portfolio mean ##
#########################

pf = AssetMgmt.Portfolio(ones(1, 8)/8)
mus = DataFrame(rand(4, 8))

## test getPMean for portfolios
AssetMgmt.getPMean(pf, mus)

## test getPMean for investments
vals = rand(8, 4)
valsDf = DataFrame(AssetMgmt.makeWeights(vals))
invs = AssetMgmt.Investments(valsDf, [1:8])

mus = DataFrame(rand(8, 4))

AssetMgmt.getPMean(invs, mus)


#############################
## test portfolio variance ##
#############################

pf = AssetMgmt.Portfolio(ones(1, 4)/4)
covMatr = cov(Timematr(rand(50, 4)))
AssetMgmt.getPVar(pf, covMatr)

valsDf = DataFrame(ones(10, 4)/4)
invs = AssetMgmt.Investments(valsDf, [1:10])
AssetMgmt.getPVar(invs, covMatr)

end
