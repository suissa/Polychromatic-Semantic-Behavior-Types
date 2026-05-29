require_relative 'forger'
require 'set'

behavior = SemanticTypeForgers::AtomicBehavior.new("test")

raise "Test failed" unless behavior.getPrimitiveType(5) == 5
raise "Test failed" unless behavior.convertToPrimitive(" 123 ") == 123
raise "Test failed" unless behavior.convertToPrimitive("true") == true
raise "Test failed" unless behavior.convertToPrimitive("{}") == 0

val = behavior.proccessValue({
  "productPrice" => "10.5",
  "deliveryPrice" => 2.5
})

raise "Test failed: expected 13.0 got #{val}" unless val == 13.0

puts "Ruby tests passed"
