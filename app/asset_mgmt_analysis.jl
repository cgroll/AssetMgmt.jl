###################
## load packages ##
###################







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

