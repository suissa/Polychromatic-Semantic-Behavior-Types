package forger

import (
	"testing"
)

func TestForger(t *testing.T) {
	behavior := NewAtomicBehavior[any]("test")

	if behavior.GetPrimitiveType(5) != 5 {
		t.Errorf("Test failed")
	}

	if behavior.ConvertToPrimitive(" 123 ") != 123 {
		t.Errorf("Test failed")
	}

	if behavior.ConvertToPrimitive("true") != true {
		t.Errorf("Test failed")
	}

	if behavior.ConvertToPrimitive("{}") != 0 {
		t.Errorf("Test failed")
	}

	val := behavior.ProcessValue(map[string]any{
		"productPrice":  "10.5",
		"deliveryPrice": 2.5,
	})

	if val != 13.0 {
		t.Errorf("Test failed: expected 13.0 got %v", val)
	}
}
