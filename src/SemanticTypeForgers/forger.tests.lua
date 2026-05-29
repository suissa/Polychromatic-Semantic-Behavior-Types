local forger = require("forger")

local behavior = forger.AtomicBehavior("test")

assert(behavior.getPrimitiveType(5) == 5, "Test failed")
assert(behavior.convertToPrimitive(" 123 ") == 123, "Test failed")
assert(behavior.convertToPrimitive("true") == true, "Test failed")
assert(behavior.convertToPrimitive("{}") == 0, "Test failed")

local val = behavior.proccessValue({
    productPrice = "10.5",
    deliveryPrice = 2.5
})

assert(val == 13.0, "Test failed: expected 13.0 got " .. tostring(val))

print("Lua tests passed")
