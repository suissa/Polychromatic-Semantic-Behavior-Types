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

val = AtomicBehavior.proccess_value(%{
  "productPrice" => "10.5",
  "deliveryPrice" => 2.5
})

if val !== 13.0 do
  raise "Test failed: expected 13.0 got #{inspect(val)}"
end

IO.puts("Elixir tests passed")
