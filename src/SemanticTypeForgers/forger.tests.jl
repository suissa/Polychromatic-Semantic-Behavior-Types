include("forger.jl")
using .Forger

behavior = AtomicBehavior{Any}("test")

@assert Forger.getPrimitiveType(behavior, 5) == 5
@assert Forger.convertToPrimitive(behavior, " 123 ") == 123
@assert Forger.convertToPrimitive(behavior, "true") == true
@assert Forger.convertToPrimitive(behavior, "{}") == 0

val = Forger.proccessValue(behavior, Dict(
    "productPrice" => "10.5",
    "deliveryPrice" => 2.5
))

@assert val == 13.0 "Test failed: expected 13.0 got $val"

println("Julia tests passed")
