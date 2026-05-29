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

emailBehavior = AtomicBehavior{Any}("PersonEmail")
@assert Forger.validate(emailBehavior, "test@example.com") == true
@assert Forger.validate(emailBehavior, "invalid-email") == false

try
    Forger.forge(emailBehavior, "invalid-email")
    error("Test failed: should have thrown")
catch e
    @assert occursin("Validation failed", e.msg)
end

println("Julia tests passed")
