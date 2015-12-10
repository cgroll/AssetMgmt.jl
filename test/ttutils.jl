module testUtils

using Base.Test
using DataFrames
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running utils tests\n")


testMus = [0.000399905;
           0.000883977;
           0.000967358;
           0.00215034 ;
           0.00132068 ;
           0.000903217;
           0.00130242 ;
           0.00116732 ;
           0.00245227 ;
           0.00213858 ;
           0.00135902 ;
           0.00142933 ;
           0.00117371 ;
           0.00228266 ;
           0.00116749 ];

testSigmas = [0.000317419;
              0.00363872 ;
              0.00512444 ;
              0.0175377  ;
              0.0165166  ;
              0.00427322 ;
              0.0159598  ;
              0.0265965  ;
              0.0255393  ;
              0.0304155  ;
              0.0288717  ;
              0.0336391  ;
              0.0311551  ;
              0.0259919  ;
              0.023314];


############################
## grossMomentsLogMoments ##
############################

## transformation from gross to log to gross should be identity

nAss = size(testMus, 1)
for ii=1:nAss
    muGross = 1 + testMus[ii]
    sigma = sqrt(testSigmas[ii])

    ## to log moments
    muLog, sigmaLog =
        AssetMgmt.grossRetMomentsToLogRetMoments(muGross, sigma)
    
    ## and back
    muGrossOut, sigmaOut =
        AssetMgmt.logRetMomentsToGrossRetMoments(muLog, sigmaLog)

    @test muGross == muGrossOut
    @test_approx_eq_eps sigma sigmaOut 1e-14
end

#######################
## scaling functions ##
#######################

## at least shouldn't throw errors
scaledMus, scaledSigmas =
    AssetMgmt.defaultMuSigmaScaling(testMus, testSigmas)


##############################
## symbol string conversion ##
##############################

testSymbs = [:hello; :world]
expOut = ["hello"; "world"]
actOut = AssetMgmt.symbToStr(testSymbs)
@test expOut == actOut

testStr = UTF8String["hello"; "world"]
expOut = [:hello; :world]
actOut = AssetMgmt.strToSymb(testStr)
@test actOut == expOut



## EMACS_STOPPER_EMACS_STOPPER_EMACS_STOPPER

##############
## old code ##
##############


## ##################
## ## column means ##
## ##################

## df = DataFrame(rand(4, 2))
## tmp = AssetMgmt.mean(df, 1)
## @test isa(tmp, DataFrame)

## df = DataFrame(rand(4, 1))
## AssetMgmt.mean(df, 1)

## df = DataFrame(rand(1, 8))
## AssetMgmt.mean(df, 1)

## ## throw error for row sums
## @test_throws AssetMgmt.mean(df, 2)

## df = DataFrame(rand(50, 4))
## tmp = AssetMgmt.cov(df)
## @test isa(tmp, DataFrame)

## #########
## ## cov ##
## #########

## covMatr = AssetMgmt.cov(df)

## #############
## ## corrcov ##
## #############

## AssetMgmt.corrcov(covMatr)

## ##############
## ## randWgts ##
## ##############

## wgts = AssetMgmt.randWgts(10, 8)
## AssetMgmt.chkEqualsOne(wgts)

## ######################
## ## composeDataFrame ##
## ######################

## df = DataFrame(rand(8, 4))
## vals = array(df)
## nams = names(df)
## rename!(df, names(df), [:a1 :a2 :a3 :a4])
## df2 = AssetMgmt.composeDataFrame(vals, [:a1 :a2 :a3 :a4])
## @test (df == df2)

## ###############################################
## ## check matching investment and return data ##
## ###############################################

## vals = AssetMgmt.randWgts(10, 5)
## inv = AssetMgmt.Investments(DataFrame(vals))
## rets = Timematr(DataFrame(rand(10, 5)))
## AssetMgmt.chkMatchInvData(inv, rets)

## ## test invalid names
## rets = Timematr(rand(10, 5), [:a1 :a2 :a3 :a4 :a5])
## @test_throws AssetMgmt.chkMatchInvData(inv, rets)

## ## test invalid index
## vals = AssetMgmt.randWgts(10, 5)
## inv = AssetMgmt.Investments(DataFrame(vals), [20:29])
## rets = Timematr(rand(10, 5))
## @test_throws AssetMgmt.chkMatchInvData(inv, rets)

end
