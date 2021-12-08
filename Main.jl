#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures


Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.



=#


mutable struct Heap_Heap{Dtype}
    base_array::Union{Vector{Dtype}, Nothing}
    summary::Union{Heap_Heap{Base_size, Layer-1, Dtype}, Nothing}
    data::Union{Vector{Heap_Heap{Base_size, Layer-1, Dtype, Nothing}}}

end

Heap_Heap(;base_size=32, In_layer = 2, dtype::Type) = Heap_Heap{base_size, In_layer, dtype}()


