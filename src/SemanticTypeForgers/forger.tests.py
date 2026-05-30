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

    emailBehavior = AtomicBehavior("PersonEmail")
    assert emailBehavior["validate"]("test@example.com") is True
    assert emailBehavior["validate"]("invalid-email") is False

    try:
        emailBehavior["forge"]("invalid-email")
        assert False, "Should have thrown an exception"
    except Exception as e:
        assert "Validation failed" in str(e)

    print("Python tests passed")

if __name__ == "__main__":
    test()
