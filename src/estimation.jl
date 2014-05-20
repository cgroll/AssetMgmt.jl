function subsampleProducer(nObs, minObs; rolling=false)
    ## produce indices for changing subsamples over time
    ##
    ## Inputs:
    ## 	nObs			scalar value denoting overall number of
    ## 					observations
    ## 	minObs 		scalar value denoting minimum subsample size
    ## 	rolling		optional - boolean value, indicating whether
    ## 					subsample is each day or rolled over. Default is
    ## 					increasing subsamples.
    ##
    ## Outputs:
    ## 	(begInd, endInd) tuple of start and end indices of subsample,
    ## 	with last subsample ending at second last index, since
    ## 	estimated values of given subsample can only be used for the
    ## 	strategy at the next day
    
    for ii=minObs:(nObs-1)
        if rolling
            produce((ii-minObs+1, ii))
        else
            produce((1, ii))
        end
    end
end
