module testUtils

using Base.Test
using DataFrames
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running utils tests\n")

##################
## column means ##
##################

df = DataFrame(rand(4, 2))
tmp = AssetMgmt.mean(df, 1)
@test isa(tmp, DataFrame)

df = DataFrame(rand(4, 1))
AssetMgmt.mean(df, 1)

df = DataFrame(rand(1, 8))
AssetMgmt.mean(df, 1)

## throw error for row sums
@test_throws AssetMgmt.mean(df, 2)

df = DataFrame(rand(50, 4))
tmp = AssetMgmt.cov(df)
@test isa(tmp, DataFrame)

#########
## cov ##
#########

covMatr = AssetMgmt.cov(df)

#############
## corrcov ##
#############

AssetMgmt.corrcov(covMatr)

##############
## randWgts ##
##############

wgts = AssetMgmt.randWgts(10, 8)
AssetMgmt.chkEqualsOne(wgts)

end
