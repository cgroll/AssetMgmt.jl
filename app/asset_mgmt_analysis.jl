###################
## load packages ##
###################




########################
## specify parameters ##
########################

## choose starting point to pick subsample, maximum 4607
cutoff = 1

## choose mu-sigma-estimator and parameters
muSigmaEstimator = AssetMgmt.empiricalEstimator
minObs = 100
rollingWindow = false

## choose response strategy
responseFunc = AssetMgmt.gmv


(nObs, nAss) = size(discRet)

t = Task(() -> AssetMgmt.produceMoments(discRet,
                                        muSigmaEstimator,
                                        (),
                                        minObs=minObs,
                                        rolling=rollingWindow))

############################
## get associated weights ##
############################

wgts = NaN*ones(size(discRet))
dates = rep(false, nObs)
for x in t
    (mus, covMatr, index) = x
    println(index)
    dates[index] = true
    wgts[index, :] = responseFunc(mus, covMatr)
end

wgtsDf = AssetMgmt.composeDataFrame(wgts[dates, :], names(discRet))
invs = AssetMgmt.Investments(wgtsDf, idx(discRet)[dates])

writeInvestments("data/emp_gmvWgts.csv", invs)

## get equally weighted portfolio wgts
eqWgts = AssetMgmt.equWgtInvestments(discRet)
sectorWgts = AssetMgmt.groupAssets(invs, assetsInSector)

sectPerf = AssetMgmt.sectorPerformances(invs,
                                        discRet[idx(invs), :],
                                        assetsInSector)


#########################
## sector performances ##
#########################


eqWgtedSectorPortf = AssetMgmt.groupVars(discRet, assetsInSector,
                                         x -> mean(x, 2))


plot(x=[1:size(sectorRets, 1)], y=core(sectorRets)[:, 1])

k = plot(x=rand(10), y=rand(10), Geom.line)

k = AssetMgmt.plot(sectorRets)


###################################
## transform to discrete returns ##
###################################



(nObs, nAss) = size(discRet)

## create equally weighted investments
eqInvs = AssetMgmt.equWgtInvestments(discRet);
AssetMgmt.str(eqInvs)

## get portfolio returns
pfRet = AssetMgmt.invRet(eqInvs, discRet, name=:equallyWeighted);
str(pfRet)

## get random portfolio returns as benchmarks
randInvs = AssetMgmt.randInvestments(discRet)
randRet1 = AssetMgmt.invRet(randInvs, discRet, name=:randPort1)
randInvs = AssetMgmt.randInvestments(discRet)
randRet2 = AssetMgmt.invRet(randInvs, discRet, name=:randPort2)

## create visual analysis
## AssetMgmt.plotPfPerformance(eqInvs, discRet, randRet1, randRet2, strName=:equWgts)

## get filtered weights
fltWgts = AssetMgmt.regularRB(eqInvs, discRet, freq=250)
AssetMgmt.plotPfPerformance(fltWgts, discRet, pfRet, randRet1, strName=:equWgts_flt250)

## enlargen default plot size
set_default_plot_size(24cm, 14cm)



########################
## plots using plotly ##
########################

using Plotly
Plotly.signin("cgroll", "2it4121bd9")

(x0,y0) = [1,2,3,4], [10,15,13,17]
(x1,y1) = [2,3,4,5], [16,5,11,9]
response = Plotly.plot([[x0 y0] [x1 y1]])
url = response["url"]
filename = response["filename"]


dats = datsAsStrings(discRet)

Plotly.plot({dats, core(discRet[:, 1])[:]},
            ["filename"=>"Plot from Julia API (6)",
             "fileopt"=>"overwrite"])

# plot:
# maxweights / significant weights

