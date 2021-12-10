#This is temporary for test purpose.
#You should probably ignore it unless you're developing.

using Main
include("Main.jl")

A = Base_layer{Int, 32, <}()
push!(A,99)
push!(A, 25)
push!(A,47)
push!(A,72)
push!(A,29)
push!(A,3)
push!(A,152)
display(A)