import gleam/string
import gleam/int
import gleam/float
import gleam/result
import gleam/dict

pub fn get_primitive_type(v) {
  v
}

pub fn validate(name: String, v: String) {
  case name {
    "PersonEmail" -> {
      let prim = convert_to_primitive(v)
      // simplified email regex matching logic (gleam standard library lacks full regex out of the box without JS/Erlang FFI, simulating basic check)
      string.contains(prim, "@") && string.contains(prim, ".")
    }
    _ -> False
  }
}

fn primitive_string_to_value(val: String) {
  let trimmed = string.trim(val)
  let lower = string.lowercase(trimmed)

  case trimmed {
    "" -> val
    "{}" | "[]" -> "0"
    "true" -> "true"
    "false" -> "false"
    "null" | "undefined" -> "null"
    _ -> {
      let is_float = string.contains(trimmed, ".") || string.contains(lower, "e")
      case is_float {
        True -> {
          case float.parse(trimmed) {
            Ok(_) -> trimmed
            Error(_) -> val
          }
        }
        False -> {
          case int.parse(trimmed) {
            Ok(_) -> trimmed
            Error(_) -> val
          }
        }
      }
    }
  }
}

pub fn convert_to_primitive(val: String) {
  primitive_string_to_value(val)
}

pub fn forge(name: String, v: String) {
  case name == "PersonEmail" && !validate(name, v) {
    True -> panic as "Validation failed for SemanticType: PersonEmail"
    False -> v
  }
}

// Gleam is strongly typed and doesn't easily support arbitrary nested dynamic
// objects like JS without using the dynamic module extensively. We provide a simplified implementation.
pub fn process_value(name: String, val: String) {
  let prim = convert_to_primitive(val)
  forge(name, prim)
}
