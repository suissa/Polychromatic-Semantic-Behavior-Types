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

local emailBehavior = forger.AtomicBehavior("PersonEmail")
assert(emailBehavior.validate("test@example.com") == true, "Test failed")
assert(emailBehavior.validate("invalid-email") == false, "Test failed")

local status, err = pcall(function() emailBehavior.forge("invalid-email") end)
assert(not status, "Test failed: should have thrown")
assert(err:match("Validation failed"), "Test failed: wrong error")

print("Lua tests passed")
