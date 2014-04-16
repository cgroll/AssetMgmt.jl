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

######################
## composeDataFrame ##
######################

df = DataFrame(rand(8, 4))
vals = array(df)
nams = names(df)
rename!(df, names(df), [:a1 :a2 :a3 :a4])
df2 = AssetMgmt.composeDataFrame(vals, [:a1 :a2 :a3 :a4])
@test (df == df2)

###############################################
## check matching investment and return data ##
###############################################

vals = AssetMgmt.randWgts(10, 5)
inv = AssetMgmt.Investments(DataFrame(vals))
rets = Timematr(DataFrame(rand(10, 5)))
AssetMgmt.chkMatchInvData(inv, rets)

## test invalid names
rets = Timematr(rand(10, 5), [:a1 :a2 :a3 :a4 :a5])
@test_throws AssetMgmt.chkMatchInvData(inv, rets)

## test invalid index
vals = AssetMgmt.randWgts(10, 5)
inv = AssetMgmt.Investments(DataFrame(vals), [20:29])
rets = Timematr(rand(10, 5))
@test_throws AssetMgmt.chkMatchInvData(inv, rets)

end
