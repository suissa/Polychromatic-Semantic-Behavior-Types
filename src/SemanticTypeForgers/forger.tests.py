import sys
from forger import AtomicBehavior

def test():
    behavior = AtomicBehavior("test")

    assert behavior["getPrimitiveType"](5) == 5
    assert behavior["convertToPrimitive"](" 123 ") == 123
    assert behavior["convertToPrimitive"]("true") is True

    # Empty object translates to 0
    assert behavior["convertToPrimitive"]({}) == 0

    val = behavior["proccessValue"]({"productPrice": "10.5", "deliveryPrice": 2.5})
    assert val == 13.0, f"Expected 13.0, got {val}"

    print("Python tests passed")

if __name__ == "__main__":
    test()
