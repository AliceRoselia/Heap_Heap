#This is temporary for test purpose.
#You should probably ignore it unless you're developing.


include("Main.jl")
using Main.Heap_Heap


A = New_heap(Int)



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





