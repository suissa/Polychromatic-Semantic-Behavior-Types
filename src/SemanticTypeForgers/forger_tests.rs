mod forger;
use forger::{AtomicBehavior, PrimitiveValue};
use std::collections::HashMap;

fn main() {
    let behavior = AtomicBehavior::<i64>::new("test");

    assert_eq!(behavior.get_primitive_type(5), 5);

    let r1 = behavior.convert_to_primitive(&PrimitiveValue::String(" 123 ".to_string()));
    assert_eq!(r1, PrimitiveValue::Int(123));

    let r2 = behavior.convert_to_primitive(&PrimitiveValue::String("true".to_string()));
    assert_eq!(r2, PrimitiveValue::Bool(true));

    let r3 = behavior.convert_to_primitive(&PrimitiveValue::String("{}".to_string()));
    assert_eq!(r3, PrimitiveValue::Int(0));

    let mut map = HashMap::new();
    map.insert("productPrice", PrimitiveValue::String("10.5".to_string()));
    map.insert("deliveryPrice", PrimitiveValue::Float(2.5));

    let r4 = behavior.process_value_map(&map);
    assert_eq!(r4, PrimitiveValue::Float(13.0));

    println!("Rust tests passed");
}
