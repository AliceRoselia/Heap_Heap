#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures


Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.



=#


mutable struct Heap_Heap{Dtype}
    base_array::Union{Vector{Dtype}, Nothing}
    summary::Union{Heap_Heap{Dtype}, Nothing}
    data::Union{Vector{Heap_Heap{Dtype}},Nothing}

end



