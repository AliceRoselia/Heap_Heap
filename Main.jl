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
3) Storing the information of the position somewhere.
4) Make a lookup table storing position for key positions.
2) is likely the most efficient option, but not gonna do it here.
=#




struct summary_key{Dtype}
    key::UInt
    data::Dtype
    summary_key(a::Integer, b::Dtype) where{Dtype} = new{Dtype}(a,b)
end

#=
syms = [:<, :(==) , :>, :<=, :>=]
for i in syms
    @eval Base.$i(a::summary_key, b::summary_key) = $i(a.data, b.data)
end
No longer needed, the cmp function will now be generated during type compute.
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


mutable struct Heap_layer{sub_layer, summary_layer}
    #TODO, fix summary to make it point to appropriate vector.
    summary::summary_layer
    data::Vector{sub_layer}
    size::UInt
    function Heap_layer{sub_layer, summary_layer}() where {sub_layer, summary_layer}
        x = new{sub_layer, summary_layer}()
        x.summary = summary_layer()
        x.data = Vector{sub_layer}(undef, max_size(x.summary))
        x.size = 0
        x
    end
end


function Heap_Heap_type(Dtype::Type, x::Integer, cmp::Function, Base_size::Integer = UInt8(32))
    if x==0
        return Base_layer{Dtype, Base_size, cmp}
    else
        @inline cmp_key(a,b) = cmp(a.data, b.data)
        return Heap_layer{Heap_Heap_type(Dtype, x-1, cmp, Base_size), Heap_Heap_type(summary_key{Dtype}, x-1, cmp_key, Base_size)}
    end
end

@inline function max_size(::Base_layer{Dtype, Base_size, cmp})::UInt where {Dtype, Base_size, cmp}
    return Base_size
end

@inline function max_size(A::Heap_layer{sub_layer, summary_layer})::UInt where {sub_layer, summary_layer}
    return max_size(A.summary)^2
end


@inline function need_splitting(X::Base_layer{Dtype, Base_size, cmp}) where {Dtype, Base_size, cmp}
    return X.size >= Base_size #Maybe replace this with == for improved performance? Considering that X.size only increases by one each time.
end
@inline function push!(X::Base_layer{Dtype, Base_size, cmp}, content::Dtype) where {Dtype, Base_size, cmp}
    #This does not need splitting.
    #Binary search the array to insert.
    #println("Working in progress.")
    #Wait, can I also unroll this too? #Later. 
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
    while mindex < maxdex
        middex = (mindex+maxdex)>>1
        if cmp(content, X.data[middex])
            maxdex = middex
        else
            mindex = middex+1
        end
    end
    #May replace "end" with "X.size" (careful consideration needed)
    X.size += 1
    X.data[mindex+1:end] =  X.data[mindex:end-1]
    X.data[mindex] = content
    return
end

@inline function length(X::Base_layer)
    return X.size 
end

@inline function empty(X::Base_layer)
    return length(X)
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

@inline function replace!(X::Base_layer{Dtype, Base_size, cmp}, content::Dtype) where {Dtype, Base_size, cmp}
    #pop one element, then push one element in, like python's heapq.
    Out::Dtype = X.data[1]
    if !cmp(content,X.data[X.size])
        #In last element, needs to be taken care of separately.
        X.data[1:X.size-1] = X.data[2:X.size]
        X.data[X.size] = content
        return Out
    end
    
    mindex::UInt8 = 2 #The 1st element will be popped out regardless. The element this can come before is the 2nd element onward.
    #No need for special case of size 1: this will be tackled.
    maxdex::UInt8 = X.size
    #The 1st element shouldn't matter because it gets popped anyway?
    while mindex < maxdex
        middex = (mindex+maxdex)>>1
        if cmp(content, X.data[middex])
            maxdex = middex
        else
            mindex = middex+1
        end
    end
    X.data[1:mindex-2] = X.data[2:mindex-1]
    X.data[mindex-1] = content
    #What to do next?
    return Out
end

@inline function push!(X::Heap_layer)
    println("Working in progress")
end


@inline function length(X::Heap_layer)
    #Might not even store X, in which case, it is 0.
    println("Working in progress")
end

@inline function empty(X::Heap_layer)
    return empty(X.summary)
end

@inline function pop!(X::Heap_layer)
    #Pop the 1st one, then the summary heap.
    summary_peek = peek(X.summary)
    sub_heap = X.data[summary_peek.key]
    out = pop!(sub_heap)
    if empty(sub_heap)
        pop!(X.summary)
    else
        replace!(X.summary, summary_key(summary_peek.key, peek(sub_heap)))
    end
    return out

end

@inline function peek(X::Heap_layer)
    return peek(X.summary).data
end

@inline function replace!(X::Heap_layer, content)
    summary_peek = peek(X.summary)
    sub_heap = X.data[summary_peek.key]
    out = replace!(sub_heap, content)
    replace!(X.summary, summary_key(summary_peek.key, content))
    return out
    # Replace the pointed heap then replace the summary.
end




#Trust the compiler.