#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures


Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.



=#

module Heap_Heap



mutable struct Heap_Heap{base_size, layer, dtype}
    base_array::Union{Vector{dtype}, Nothing}
    summary::Union{Heap_Heap{base_size, layer-1, dtype}, Nothing}
    data::Union{Vector{Heap_Heap{base_size, layer-1, dtype, Nothing}}}
    function Heap_Heap{size, layer, dtype}() where{layer == 0}
        x = new()
        x.base_array = Vector{dtype}()
    end
end





end