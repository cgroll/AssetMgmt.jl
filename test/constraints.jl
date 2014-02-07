module testConstraints

using Base.Test
using TimeData
## using Markowitz

##############################
## chkEqualsOne for vectors ##
##############################

## test valid portfolio weights
simVals = rand(8, 1)
simVals = simVals./sum(simVals)

chkEqualsOne(simVals)
chkEqualsOne(simVals[:])

## test invalid portfolio weights
simVals[2] = simVals[2] - 1e-8

@test_throws chkEqualsOne(simVals)
@test_throws chkEqualsOne(simVals[:])


##########################
## makeWeights function ##
##########################

## test valid investment weights
simVals = rand(1, 10)
wgts = makeWeights(simVals)
chkEqualsOne(wgts)

###############################
## chkEqualsOne for matrices ##
###############################

simVals = rand(10, 5)
simVals = makeWeights(simVals)

## chkEquals not define for matrices
@test_throws chkEqualsOne(simVals)

tm = Timematr(simVals)
chkEqualsOne(tm)

## test invalid input
simVals[1, 1] = simVals[1, 1] + 1e-8

tm = Timematr(simVals)
chkEqualsOne(tm)

end
