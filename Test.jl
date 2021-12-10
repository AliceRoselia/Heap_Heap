#This is temporary for test purpose.
#You should probably ignore it unless you're developing.

using Main
include("Main.jl")

A = Base_layer{Int, 32, <}()

push!(A, 25)

display(A)