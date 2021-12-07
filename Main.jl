#= 
This is an implementation of a priority_queue data structure, customized for modern cpu architectures


Special Thanks to Gandalf and other people in the Hoj discord server for helping me out.



=#

module My_Heap_Heap



mutable struct Heap_Heap{base_size, layer, dtype}
    base_array::Union{Vector{dtype}, Nothing}
    summary::Union{Heap_Heap{base_size, layer-1, dtype}, Nothing}
    data::Union{Vector{Heap_Heap{base_size, layer-1, dtype, Nothing}}}
    @inline function Heap_Heap{base_size, layer, dtype}()
        #I will change this to generated function later if the compiler fails to optimize away the branches
        x = new()
        if layer == 0

            x.base_array = Vector{dtype}()
            x.summary = Nothing
            x.data = Nothing
        else
            x.base_array = Nothing
            x.summary = new{base_size, layer-1, dtype}()
            
        end
    end
end





end