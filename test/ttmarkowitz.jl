module testMarkowitz

using Base.Test
using DataFrames
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running markowitz tests\n")

df = convert(DataFrame, rand(500, 4))
mus = AssetMgmt.mean(df, 1)
covMatr = AssetMgmt.cov(df)
wgts = AssetMgmt.gmv(mus, covMatr) # should be close to
											  # [0.25 0.25 0.25 0.25]

###############
## real data ##
###############

include("/home/chris/research/julia/EconDatasets/src/EconDatasets.jl")
logRet = EconDatasets.dataset("SP500")

## transform to discrete non-percentage returns
discRet = exp(logRet/100).-1

mus = mean(discRet, 1)
covMatr = cov(discRet)

wgts = AssetMgmt.gmv(mus, covMatr)

end
