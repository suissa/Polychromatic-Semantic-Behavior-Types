package forger

import (
	"strings"
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

	emailBehavior := NewAtomicBehavior[any]("PersonEmail")
	if emailBehavior.Validate("test@example.com") != true {
		t.Errorf("Test failed: valid email")
	}
	if emailBehavior.Validate("invalid-email") != false {
		t.Errorf("Test failed: invalid email")
	}

	defer func() {
		if r := recover(); r == nil {
			t.Errorf("Test failed: should have thrown on invalid forge")
		} else {
			if s, ok := r.(string); ok && !strings.Contains(s, "Validation failed") {
				t.Errorf("Test failed: wrong panic message: %v", s)
			}
		}
	}()
	emailBehavior.Forge("invalid-email")
}
