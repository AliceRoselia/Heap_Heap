#This is temporary for test purpose.
#You should probably ignore it unless you're developing.




function binsearch_insert(X, data, cmp = <)
    mindex = 1
    maxdex = X.size
    while mindex < maxdex
        middex = (mindex+maxdex)>>1
        if cmp(content, X[middex])
            maxdex = middex
        else
            mindex = middex+1
        end
    end
    
end