alias SemanticTypeForgers.Forger.AtomicBehavior

behavior = AtomicBehavior.new("test")

if AtomicBehavior.get_primitive_type(5) !== 5 do
  raise "Test failed"
end

if AtomicBehavior.convert_to_primitive(" 123 ") !== 123 do
  raise "Test failed"
end

if AtomicBehavior.convert_to_primitive("true") !== true do
  raise "Test failed"
end

if AtomicBehavior.convert_to_primitive("{}") !== 0 do
  raise "Test failed"
end

val = AtomicBehavior.proccess_value(behavior, %{
  "productPrice" => "10.5",
  "deliveryPrice" => 2.5
})

if val !== 13.0 do
  raise "Test failed: expected 13.0 got #{inspect(val)}"
end

email_behavior = AtomicBehavior.new("PersonEmail")
if AtomicBehavior.validate(email_behavior, "test@example.com") !== true do
  raise "Test failed: valid email"
end

if AtomicBehavior.validate(email_behavior, "invalid-email") !== false do
  raise "Test failed: invalid email"
end

try do
  AtomicBehavior.forge(email_behavior, "invalid-email")
  raise "Test failed: should have thrown on invalid forge"
rescue
  e in RuntimeError ->
    unless String.contains?(e.message, "Validation failed") do
      raise e
    end
end

IO.puts("Elixir tests passed")
