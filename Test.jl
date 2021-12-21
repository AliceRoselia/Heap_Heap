#This is temporary for test purpose.
#You should probably ignore it unless you're developing.

using Main
include("Main.jl")



Fst_layer_type = Heap_Heap_type(Int, 1, <)

A = Fst_layer_type()

display(A)


#Issue: pushing into empty heap
for i in 1:35
    push!(A,i)
end
display(A)