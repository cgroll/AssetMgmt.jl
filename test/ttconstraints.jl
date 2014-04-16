module testConstraints

using Base.Test
using DataFrames
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running constraints tests\n")

##############################
## chkEqualsOne for vectors ##
##############################

## test valid portfolio weights
simVals = rand(8, 1)
simVals = simVals./sum(simVals)

AssetMgmt.chkEqualsOne(simVals)
AssetMgmt.chkEqualsOne(simVals[:])

## test invalid portfolio weights
simVals[2] = simVals[2] - 1e-8

@test_throws AssetMgmt.chkEqualsOne(simVals)
@test_throws AssetMgmt.chkEqualsOne(simVals[:])


##########################
## makeWeights function ##
##########################

## test valid investment weights
simVals = rand(1, 10)
wgts = AssetMgmt.makeWeights(simVals)
AssetMgmt.chkEqualsOne(wgts)

###############################
## chkEqualsOne for matrices ##
###############################

simVals = rand(10, 5)
simVals = AssetMgmt.makeWeights(simVals)

## chkEquals meanwhile defined for matrices
AssetMgmt.chkEqualsOne(simVals)

tm = Timematr(simVals)
AssetMgmt.chkEqualsOne(tm)

## test invalid input
simVals[1, 1] = simVals[1, 1] + 1e-8

tm = Timematr(simVals)
@test_throws AssetMgmt.chkEqualsOne(tm)

end
