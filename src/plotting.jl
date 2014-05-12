function datsAsStrings(tm::Timematr)
    nObs = size(tm, 1)
    datsAsStr = Array(ASCIIString, nObs)
    idxes = idx(tm)
    for ii=1:nObs
        datsAsStr[ii] = string(idxes[ii])
    end
    return datsAsStr
end

import Gadfly.plot
function plot(tm::Timematr, settings...)
    ## plot Timematr object
    ## - multi-line plot
    ## - index must be dates convertible to strings
    ## - plot only some maximum number of randomly picked paths
    ## - plot some statistics
    
    dats = AssetMgmt.datsAsStrings(tm)
    (nObs, nAss) = size(tm)
    
    ## maximum number of paths plotted
    maxPaths = 10

    ## get values for paths
    if nAss > maxPaths
        ## get randomly drawn paths

        chosenAssets = randperm(nAss)[1:maxPaths]
        randPaths = core(tm)[:, chosenAssets]
        nams = names(tm)[chosenAssets]

        ## get statistics
        allVals = core(tm)
        averagePath = mean(allVals, 2)
        lowestEndingPath = indmin(allVals[end, :])
        lowPath = allVals[:, lowestEndingPath]
        highestEndingPath = indmax(allVals[end, :])
        highPath = allVals[:, highestEndingPath]

        vals = [averagePath lowPath highPath randPaths]
        valsDf = AssetMgmt.composeDataFrame(vals,
                                            [:mean, :low, :high,
                                             nams])  
    else
        valsDf = copy(tm.vals)
    end

    nams = names(valsDf)
    valsDf[:Idx] = dats
    
    stackedData = stack(valsDf, nams)

    plot(stackedData, x="Idx", y="value",
         color="variable", Geom.line, settings...)
end


function plotWithBMs(pfRets::Timematr, bmIndex...) 
    ## plot portfolio price evolution with benchmarks
    ##
    ## Inputs:
    ## 	pfRets 	nObs x 1 Timematr containing portfolio returns
    ## 	bmIndex	tuple of nObs x 1 Timematr objects containing time
    ## 				series of benchmarks

    data = pfRets
    
    nBMs = length(bmIndex)
    for ii=1:nBMs
        data = [data bmIndex[ii]]
    end

    ## calculate cumulated prices
    prices = cumprod(data .+ 1, 1)

    AssetMgmt.plot(prices, Guide.xlabel("time"),
                   Guide.ylabel("price"),
                   Guide.title("portfolio evolution with benchmarks")) 
end


function plotStrategy(wgts::Investments,
                      fltWgts::Investments,
                      discRet::Timematr; 
                      strName = :strategy)

    ## plot performance indicators for strategy with fixed benchmarks 
    (nObs, nAss) = size(discRet)

    ## get portfolio returns for strategy
    pfRet = AssetMgmt.invRet(wgts, discRet, name=strName)

    ## create equally weighted investments as benchmark
    eqInvs = AssetMgmt.equWgtInvestments(discRet);
    eqRet = AssetMgmt.invRet(eqInvs, discRet, name=:equallyWeighted);
    
    ## get random portfolio returns as benchmarks
    randInvs = AssetMgmt.randInvestments(discRet)
    randRet1 = AssetMgmt.invRet(randInvs, discRet, name=:randPort1)
    randInvs = AssetMgmt.randInvestments(discRet)
    randRet2 = AssetMgmt.invRet(randInvs, discRet, name=:randPort2)

    ############################
    ## asset price evolutions ##
    ############################

    ## get cumulated prices for individual assets
    cumPrices = log(cumprod(discRet .+ 1, 1))

    pricePlot = AssetMgmt.plot(cumPrices, Guide.xlabel("time"),
                               Guide.ylabel("price"),
                               Guide.title("normalized asset prices"));

    ################################################
    ## portfolio price evolutions with benchmarks ##
    ################################################

    ## plot portfolio evolution with benchmarks
    
    bmPlot = AssetMgmt.plotWithBMs(pfRet, [eqRet randRet1 randRet2]);


    #################################
    ## plot returns and volatility ##
    #################################

    returnPlot = AssetMgmt.plot(pfRet, Guide.xlabel("time"),
                                Guide.ylabel("return"),
                                Guide.title("portfolio returns")); 

    ## get squared portfolio returns as proxy for volatility
    volaPlot = AssetMgmt.plot(pfRet.^2, Guide.xlabel("time"),
                              Guide.ylabel("squared returns"),
                              Guide.title("squared portfolio
returns"));

    ################################
    ## putting the parts together ##
    ################################

    pfEvolution = vstack(pricePlot, bmPlot, returnPlot, volaPlot)
    filename = string("pics/pfEvolution_", strName, ".pdf")
    draw(PDF(filename, 10inch, 20inch), pfEvolution)
end

function plotPfPerformance(wgts::Investments,
                           discRet::Timematr,
                           BMs...; 
                           strName = :strategy)
    ## plot strategy performance indicators
    
    display(BMs)
    
    (nObs, nAss) = size(discRet)
    nBMs = length(BMs)
    
    ## get portfolio returns
    pfRet = AssetMgmt.invRet(wgts, discRet, name=strName)

    ## get cumulated prices for individual assets
    cumPrices = cumprod(discRet .+ 1, 1)

    ############################
    ## asset price evolutions ##
    ############################

    pricePlot = AssetMgmt.plot(cumPrices, Guide.xlabel("time"),
                               Guide.ylabel("price"),
                               Guide.title("normalized asset prices"));

    ################################################
    ## portfolio price evolutions with benchmarks ##
    ################################################

    ## plot portfolio evolution with benchmarks
    ## display(typeof(BMs))
    ## display(BMs)
    bmPlot = AssetMgmt.plotWithBMs(pfRet, BMs...);


    #################################
    ## plot returns and volatility ##
    #################################

    returnPlot = AssetMgmt.plot(pfRet, Guide.xlabel("time"),
                                Guide.ylabel("return"),
                                Guide.title("portfolio returns")); 

    ## get squared portfolio returns as proxy for volatility
    volaPlot = AssetMgmt.plot(pfRet.^2, Guide.xlabel("time"),
                              Guide.ylabel("squared returns"),
                              Guide.title("squared portfolio
returns")); 

    ################################
    ## putting the parts together ##
    ################################

    pfEvolution = vstack(pricePlot, bmPlot, returnPlot, volaPlot)
    filename = string("pics/pfEvolution_", strName, ".pdf")
    draw(PDF(filename, 10inch, 20inch), pfEvolution)

    ###################
    ## plot turnover ##
    ###################

    ## get investment turnover
    tOver = AssetMgmt.turnover(wgts, discRet)
    intTOver = AssetMgmt.intendedTurnover(wgts)

    tOData = [tOver intTOver]
    
    tOPlot = AssetMgmt.plot(tOData, Guide.xlabel("time"),
               Guide.ylabel("turnover"),
               Guide.title("actual turnover vs intended turnover")); 

    ## get diversification measures
    divIndicators = AssetMgmt.diversification(wgts)

    ## plot diversification measures related to number of assets
    divNAssets = divIndicators[[:nAss, :nSignAss, :nShort]]
    divNAssetsPlot = AssetMgmt.plot(divNAssets, Guide.xlabel("time"),
                                    Guide.ylabel("number"),
                                    Guide.title("diversification measures"));

    ## plot diversification measures expressed as fractions 
    divFractions = divIndicators[[:maxWgt, :Gini, :stdWgt]]
    divFractionsPlot = AssetMgmt.plot(divFractions, Guide.xlabel("time"),
               Guide.ylabel("value"),
               Guide.title("diversification measures"));

    divPlot = vstack(tOPlot, divNAssetsPlot, divFractionsPlot)
    filename = string("pics/pfDiversif_", strName, ".pdf")
    draw(PDF(filename, 10inch, 12inch), divPlot)

    #################################
    ## portfolio return statistics ##
    #################################

    retStats = AssetMgmt.returnStatistics(pfRet)

    distrPlots = Array(Any, (nBMs+1))
    
    distrPlots[1] = plot(pfRet.vals, x=string(strName),
         xintercept = [retStats.mu, retStats.VaR95, retStats.VaR99],
         Geom.histogram(minbincount=80),
         Geom.vline(color="orange"),
         Guide.xlabel("returns"),
         Guide.ylabel("frequency"),
         Guide.title("portfolio return distribution"));

    for ii=1:nBMs
        ## currBM = Timematr(BMs[ii].vals, idx(BMs[ii]))
        currBM = BMs[ii]
        title = string(string(names(currBM)), " return distribution")
        retStats = AssetMgmt.returnStatistics(currBM)
        distrPlots[ii+1] = plot(currBM.vals, x=string(names(currBM.vals)[1]),
                             xintercept = [retStats.mu, retStats.VaR95, retStats.VaR99],
                             Geom.histogram(minbincount=80),
                             Geom.vline(color="orange"),
                             Guide.xlabel("returns"),
                             Guide.ylabel("frequency"),
                             Guide.title(title));
    end
    
    ###################
    ## mu-sigma-plot ##
    ###################

    retStats = AssetMgmt.returnStatistics(pfRet)
    
    ## get moments of assets
    assetMus = mean(core(discRet), 1)
    assetSigmas = std(core(discRet), 1)
    ## covs = cov(discRet)
    ## for ii=1:nAss
    ##     assetSigmas[names(discRet)[ii]] = sqrt(covs[ii, ii]) 
    ## end
    assetNames = Array(ASCIIString, nAss)
    for ii=1:nAss
        assetNames[ii] = string(names(discRet)[ii])
    end
    assetTyps = ["asset" for ii=1:nAss]
    
    ## get moments for benchmark strategies
    bmMus = Array(Float64, nBMs)
    bmSigmas = Array(Float64, nBMs)
    bmNames = Array(ASCIIString, nBMs)
    for ii=1:nBMs
        currBM = BMs[ii]
        bmMus[ii] = mean(core(currBM))
        bmSigmas[ii] = std(core(currBM))
        bmNames[ii] = string(names(currBM)[1])
    end
    bmTyps = ["Benchm" for ii=1:nBMs]
    
    ## get moments for portfolio return
    pfMu = retStats.mu
    pfSigma = retStats.sigma
    pfName = string(strName)
    pfTyp = "portf"

    moments = DataFrame()
    ## moments[:mus] = [assetMus[:], bmMus[:], pfMu]
    ## moments[:sigmas] = [assetSigmas[:], bmSigmas[:], pfSigma]
    ## moments[:names] = [assetNames[:], bmNames[:], pfName]
    ## moments[:typ] = [assetTyps[:], bmTyps[:], pfTyp]

    ## for debugging
    ## display(moments)
        
    ## new version should prioritize labels of portfolios over assets
    moments[:mus] = [bmMus[:], pfMu, assetMus[:]]
    moments[:sigmas] = [bmSigmas[:], pfSigma, assetSigmas[:]]
    moments[:names] = [bmNames[:], pfName, assetNames[:]]
    moments[:typ] = [bmTyps[:], pfTyp, assetTyps[:]]
    
    muSigmaPlot = plot(layer(moments,
                             x="sigmas", y="mus", color="typ",
                             Geom.point),
                       layer(moments, x="sigmas", y="mus",
                             label="names", Geom.label),
                       Guide.xlabel("sigma"),
                       Guide.ylabel("mu"),
                       Guide.title("mu-sigma combinations"))

    distrPlots = vstack(muSigmaPlot, distrPlots...)
    filename = string("pics/pfDistrib_", strName, ".pdf")
    draw(PDF(filename, 10inch, 25inch), distrPlots)

end

