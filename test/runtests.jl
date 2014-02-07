module runtests

tests = ["constraints.jl",
         "moments.jl",
         "investments.jl",
         "portfolio.jl"]

for t in tests
    include(string(Pkg.dir("AssetMgmt"), "/test/", t))
end

end
