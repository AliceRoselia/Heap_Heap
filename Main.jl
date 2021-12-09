#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures


Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.



=#



mutable struct Base_layer{Dtype}
    data::Vector{Dtype}
    function Base_layer{Dtype}() where {Dtype}
        x = new{Dtype}()
        x.data = Vector{Dtype}()
    end
end


mutable struct Heap_layer{sub_layer}
    summary::sub_layer
    data::Vector{sub_layer}
end


Heap_Heap_type(Dtype, x::Integer) = x==0 ? Base_layer{Dtype} : Heap_layer{Heap_Heap_type(Dtype, x-1)}



function push!(X::Base_layer)
    #Binary search the array to insert.
    println("Working in progress.")
end

function pop!(X::Base_layer)
    data = X.data[1]
    X = X[2:end] #May need optimization. I don't know how Julia arrays are implemented.
    return data
    #return the first element.
end

function peek(X::Base_layer)
    return X.data[1]
end
