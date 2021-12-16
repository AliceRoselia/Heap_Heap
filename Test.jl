#This is temporary for test purpose.
#You should probably ignore it unless you're developing.

using Main
include("Main.jl")

A = Base_layer{Int, 32, <}()
push!(A,99)
push!(A, 25)
push!(A,47)
push!(A,1)
push!(A,29)
push!(A,3)
push!(A,152)
println(replace!(A,37))
println(replace!(A,99))
println(replace!(A,-1))
println(replace!(A,-3))
println(replace!(A, 77))
display(A)

Fst_layer_type = Heap_Heap_type(Int, 2, <)

A = Fst_layer_type()

display(A.data)