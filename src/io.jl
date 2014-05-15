function readInvestments(filename::String)

    df = readtable(filename, nastrings=[".", "", "NA"])
    
    # find columns that have been parsed as Strings by readtable
    col_to_test = Array(Symbol, 0)

    nCols = size(df, 2)
    for ii=1:nCols
        typeof(df[1, ii]) == UTF8String?
        push!(col_to_test, names(df)[ii]):
        nothing
    end

    # test each column's data to see if Datetime will parse it
    col_that_pass = Array(Symbol, 0)

    for colname in col_to_test
        d = match(r"[-|\s|\/|.]", df[1, colname])
        d !== nothing? (bar = split(df[1, colname], d.match)): (bar = [])
        if length(bar) == 3
            push!(col_that_pass, colname)
        end
    end

    # parse first column that passes the Datetime regex test
    idx = Date{ISOCalendar}[date(d) for d in
                                 df[col_that_pass[1]]] # without
                                        # Date it would fail chkIdx
                                        # in constructor
    
    delete!(df, [col_that_pass[1]])

    ## try whether DataFrame fits subtypes
    invs = AssetMgmt.Investments(df, idx)

    return invs
end

function writeInvestments(filename::String, invs::Investments)
    ## create large dataframe
    idxDf = DataFrame(idx = idx(invs));
    df = [idxDf invs.vals];
    writetable(filename, df)
end


