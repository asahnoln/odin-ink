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
		if val[0] == '^' {
			return strings.clone(val[1:])
		}

		switch val {
		case "done":
			return .Done
		case "str":
			return .Str
		case "/str":
			return .Str_End
		case "ev":
			return .Ev
		case "/ev":
			return .Ev_End
		}
	case json.Object:
		if p, ok := val["->"]; ok {
			return Divert{path = strings.clone(p.(string)), var = val["var"].(bool) or_else false}
		}
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
	case Divert:
		delete(v.path)
	}
}
