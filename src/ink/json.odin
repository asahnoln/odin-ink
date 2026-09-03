package ink

import "core:encoding/json"
import "core:strings"

json_convert :: proc(j: json.Value) -> Element {
	#partial switch val in j {
	case json.Array:
		c := make(Container, len(val))
		for v, i in val {
			c[i] = json_convert(v)
		}

		return c
	case json.Integer:
		return f64(val)
	case json.String:
		s := strings.clone(val[1:])

		return s
	}

	return nil
}

destroy_element :: proc(el: Element) {
	#partial switch v in el {
	case Container:
		for e in v {
			destroy_element(e)
		}

		delete(v)
	case string:
		delete(v)
	}
}
