module testMuSigmaFunctions

using Base.Test
using DataFrames
using TimeData
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running mu-sigma function tests\n")

####################
## load test data ##
####################

include(joinpath(homedir(),
                 "research/julia/AssetMgmt/test/createTestData.jl"))
## scacapE6Names and mus20011202 and covMatr20011202 

#############################
## test efficient frontier ##
#############################

## create mu-sigma model
mod = AssetMgmt.SampleMoments(mus20011202,
                              covMatr20011202,
                              scacapE6Names)

## get moments of efficient portfolios directly
nPfs = 50
effMus, effSigmas = AssetMgmt.getEffFrontier(mod, nPoints = nPfs)

## no asset may be better in both first and second moment
nAss = size(mod.mu, 1)
for ii=1:nPfs
    for jj=1:nAss
        betterMu = effMus[ii] < mod.mu[jj]
        betterVola = effSigmas[ii] > sqrt(mod.sigma[jj,jj])
        @test !(betterMu & betterVola)
    end
end

## get efficient portfolio weights
xEff = AssetMgmt.getEffPortfolios(mod, nPoints = nPfs)

## calculate moments for efficient portfolios 
effMus2 = zeros(nPfs)
effSigmas2 = zeros(nPfs)
for ii=1:nPfs
    effMus2[ii] = AssetMgmt.getPMean(xEff[ii, :][:], mod.mu)
    effSigmas2[ii] =
        sqrt(AssetMgmt.getPVar(xEff[ii, :][:], mod.sigma))
end

## test equality of both approaches
@test_approx_eq_eps effMus effMus2 1e-14
@test_approx_eq_eps effSigmas effSigmas2 1e-14

## test that efficient portfolios are weights
@test_approx_eq_eps sum(xEff, 2) ones(Float64, nPfs) 1e-12

end
