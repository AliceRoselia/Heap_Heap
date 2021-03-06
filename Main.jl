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



There are also many ways to "defrag", such as by "transposing", merging, etc... but not doing it here either.
Even merging likely not implemented.
=#




struct summary_key{sub_heap_type,Dtype}
    key::sub_heap_type
    data::Dtype
    summary_key(a::sub_heap_type, b::Dtype) where{sub_heap_type, Dtype} = new{sub_heap_type,Dtype}(a,b)
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
    #data::Vector{sub_layer} Fixing the issue.
    #size::UInt
    function Heap_layer{sub_layer, summary_layer}() where {sub_layer, summary_layer}
        x = new{sub_layer, summary_layer}()
        x.summary = summary_layer()
        #x.data = Vector{sub_layer}(undef, max_size(x.summary))
        #x.size = 0
        x
    end
end


function Heap_Heap_type(Dtype::Type, x::Integer, cmp::Function, Base_size::Integer = UInt8(32))
    #TODO: Fix summary key thing.
    if x==0
        return Base_layer{Dtype, Base_size, cmp}
    else
        @inline cmp_key(a,b) = cmp(a.data, b.data)
        sub_heap_type = Heap_Heap_type(Dtype, x-1, cmp, Base_size)
        return Heap_layer{sub_heap_type, Heap_Heap_type(summary_key{sub_heap_type,Dtype}, x-1, cmp_key, Base_size)}
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
    return length(X) == 0
end

@inline function pop!(X::Base_layer)
    data = X.data[1]
    #May replace "end" with "X.size"
    X.data[1:end-1] = X.data[2:end] #May need optimiza tion.I don't know how Julia arrays are implemented.
    X.size -= 1
    #X.data[end] = undef #Free the memory.
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

@inline function split!(X::Base_layer{Dtype, Base_size, cmp}) where {Dtype, Base_size, cmp}
    #create one new base layers.
    #Assumes full X.
    new_one = Base_layer{Dtype, Base_size, cmp}()
    cutoff = div(Base_size, 2)
    new_one.size = Base_size-cutoff
    new_one.data[1:new_one.size] = X.data[cutoff+1:end]
    X.size = cutoff
    return new_one
end

@inline function need_splitting(X::Heap_layer)
    return need_splitting(X.summary)
end


@inline function push!(X::Heap_layer{sub_layer, summary_layer}, content) where {sub_layer, summary_layer}
    #X.size += 1
    if empty(X.summary)
        new_one = sub_layer()
        push!(new_one, content)
        push!(X.summary, summary_key(new_one, content))
        return
        #println("Working in progress.")
    end
    
    summary_peek = peek(X.summary)
    sub_heap = summary_peek.key
    if need_splitting(sub_heap)
        #Do_something
        new_one = split!(sub_heap)
        push!(sub_heap, content)
        #Get new summary key.
        
        push!(X.summary, summary_key(new_one, peek(new_one)))
        #println("Working in progress")
    else
        push!(sub_heap, content)
    end
    return
end


@inline function length(X::Heap_layer)
    #Might not even store X, in which case, it is 0.
    #return X.size
end

@inline function empty(X::Heap_layer)
    return empty(X.summary)
end

@inline function pop!(X::Heap_layer)
    #Pop the 1st one, then the summary heap.
    #X.size -= 1
    summary_peek = peek(X.summary)
    sub_heap = summary_peek.key
    out = pop!(sub_heap)
    if empty(sub_heap)
        pop!(X.summary)
        #println("Working in progress")
        #Todo: make sure the data stays in place. 
    else
        #println(X.summary)
        replace!(X.summary, summary_key(sub_heap, peek(sub_heap)))
    end
    return out

end

@inline function peek(X::Heap_layer)
    return peek(X.summary).data
end

@inline function replace!(X::Heap_layer, content)
    summary_peek = peek(X.summary)
    sub_heap = summary_peek.key
    out = replace!(sub_heap, content)
    replace!(X.summary, summary_key(sub_heap, peek(sub_heap)))
    return out
    # Replace the pointed heap then replace the summary.
end

@inline function split!(X::Heap_layer{sub_layer, summary_layer}) where {sub_layer, summary_layer}
    new_summary = split!(X.summary)
    new_heap = Heap_layer{sub_layer, summary_layer}()
    new_heap.summary = new_summary
    return new_heap
end


#Trust the compiler.
@inline function debug_print(X)
    print(X, " ")
end
@inline function debug_print(X::summary_key)
    #println("Summary key with key:")
    #print("key = ")
    #debug_print(X.key)
    print("data = ")
    debug_print(X.data)
end
@inline function debug_print(X::Base_layer)
    #println("Base layer:")
    #println(typeof(X))
    println("[")
    for i in 1:X.size
        debug_print(X.data[i])
        print(",")
    end
    println("]")
end

@inline function debug_print(X::Heap_layer)
    #println("Heap layer with summary:")
    print("summary = ")
    debug_print(X.summary)
end

function New_heap(Dtype::Type; layer::Integer=2, cmp::Function = <, base_size::Integer = 64)
    type = Heap_Heap_type(Dtype,layer, cmp, base_size)
    return type()
end