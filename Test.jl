#This is temporary for test purpose.
#You should probably ignore it unless you're developing.

using Main
include("Main.jl")



Fst_layer_type = Heap_Heap_type(Int, 2, <)

A = Fst_layer_type()

display(A)


for i in 1:35
    push!(A,i)
end
display(A)