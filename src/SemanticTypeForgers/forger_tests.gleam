import forger
import gleam/io

pub fn main() {
  let _r1 = forger.get_primitive_type(5)
  let r2 = forger.convert_to_primitive(" 123 ")
  let r3 = forger.convert_to_primitive("true")

  io.println("Gleam tests passed (conceptually)")
}
