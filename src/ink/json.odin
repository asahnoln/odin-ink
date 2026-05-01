package ink

import "core:encoding/json"
import "core:strings"

convert_json :: proc(j: json.Value) -> Element {
	#partial switch val in j {
	case json.Array:
		c := make(Container, len(val))
		for v, i in val {
			c[i] = convert_json(v)
		}

		return c
	case json.String:
		switch val {
		case "done":
			return .Done
		}

		s := val
		if len(val) > 0 && val[0] == '^' {
			s = val[1:]
		}

		return strings.clone(s)
	}

	return nil
}

destroy_element :: proc(e: Element) {
	#partial switch val in e {
	case Container:
		for v, i in val {
			destroy_element(v)
		}
		delete(val)
	case string:
		delete(val)
	}
}
