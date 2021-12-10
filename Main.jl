#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures

Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.

The purpose of this implementation:
    priority_queue, despite being one crucial data structure in many applications 
    (pathfinding, best-first-search, etc) has not been optimized for modern cpu architectures.
    Commonly used heaps (pairing heap, binary heap) has poor data locality. 
    Moreover, this makes heavy use of inlining, making it fast.

This is a minimum viable version. 

#Decrease_key is possible, but would require altering the elements/heaps to be aware of their locations.
There are several ways of doing this.
1) Making a handle class which contains the information and the data, then specialize the dispatch in case the heap stores that handle.
2) Making a pointer back to the parent heap.

=#



mutable struct Base_layer{Dtype, Base_size, cmp}
    data::Vector{Dtype}
    size::UInt8
    function Base_layer{Dtype, Base_size, cmp}() where {Dtype,Base_size, cmp}
        x = new{Dtype,Base_size, cmp}()
        x.data = Vector{Dtype}(undef,Base_size)
        x.size = 0
        x
    end
end



mutable struct Heap_layer{sub_layer}
    summary::sub_layer
    data::Vector{sub_layer}
end


Heap_Heap_type(Dtype, x::Integer) = x==0 ? Base_layer{Dtype} : Heap_layer{Heap_Heap_type(Dtype, x-1)}



@inline function need_splitting(X::Base_layer{Dtype, Base_size, cmp}) where {Dtype, Base_size, cmp}
    return X.size >= Base_size #Maybe replace this with == for improved performance? Considering that X.size only increases by one each time.
end
@inline function push!(X::Base_layer{Dtype, Base_size, cmp}, content::Dtype) where {Dtype, Base_size, cmp}
    #This does not need splitting.
    #Binary search the array to insert.
    println("Working in progress.")
    #Wait, can I also unroll this too? #Later. 
    #TODO: Fix cases for X being final element.
    if X.size == 0
        X.size = 1
        X.data[1] = content
        return
    elseif !cmp(content,X.data[X.size])
        X.size += 1
        X.data[X.size] = content
        return
    
    end

    mindex::UInt8 = 1
    maxdex::UInt8 = X.size
    #if x.size >= Base_size
        #println("Working in progress.")
        #Still working in progress. After this insert function is done, splitting is needed.
    #end

    while mindex < maxdex
        middex = (mindex+maxdex)>>1
        if cmp(content, X.data[middex])
            maxdex = middex
        else
            mindex = middex+1
        end
    end
    #TODO: test the binary search to ensure no mistake happens.
    #May replace "end" with "X.size"
    X.size += 1
    X.data[mindex+1:end] =  X.data[mindex:end-1]
    X.data[mindex] = content
end

@inline function length(X::Base_layer)
    return X.size 
end

@inline function pop!(X::Base_layer)
    data = X.data[1]
    #May replace "end" with "X.size"
    X[1:end-1] = X[2:end] #May need optimiza tion.I don't know how Julia arrays are implemented.
    X.size -= 1
    return data
    #return the first element.
end

@inline function peek(X::Base_layer)
    return X.data[1]
end
