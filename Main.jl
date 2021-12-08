#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures


Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.



=#



mutable struct Base_layer{Dtype}
    data::Vector{Dtype}
end


mutable struct Heap_layer{sub_layer}
    summary::sub_layer
    data::Vector{sub_layer}
end


Heap_Heap_type(Dtype, x::Integer) = x==0 ? Base_layer{Dtype} : Heap_layer{Heap_Heap_type(Dtype, x-1)}


