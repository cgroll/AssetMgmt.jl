using TimeData
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime

tm = TimeData.readTimedata("/home/chris/.julia/v0.3/TimeData/data/logRet.csv")

## create random weights

wgts = randWgts(10, 3)
AssetMgmt.chkEqualsOne(wgts)

    
wgts2 = randInvestments(tm)    


wgts3 = equWgtInvestments(tm)
display(wgts3)
