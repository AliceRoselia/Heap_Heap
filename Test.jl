#This is temporary for test purpose.
#You should probably ignore it unless you're developing.

using Main
include("Main.jl")



Fst_layer_type = Heap_Heap_type(Int, 2, <, 32)

A = Fst_layer_type()



#Issue: pushing into empty heap

for i in 1:4000
    println("pushing", i)
    push!(A,i)
    #display(peek(peek(A.summary.summary).key).key)
    #debug_print(A)
end

#display(A)


for i in 1:2000
    println("popping",pop!(A))
    #display(peek(peek(A.summary.summary).key).key)
    #debug_print(A)
end





