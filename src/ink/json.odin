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
		return _json_convert_string(val)
	case json.Object:
		return _json_convert_object(val)
	}

	return nil
}

_json_convert_string :: proc(val: json.String) -> Element {
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

	return nil
}

_json_convert_object :: proc(val: json.Object) -> Element {
	if p, ok := val["->"]; ok {
		return Divert{path = strings.clone(p.(string)), var = val["var"].(bool) or_else false}
	}

	if p, ok := val["^->"]; ok {
		return Divert_Assign{path = strings.clone(p.(string))}
	}

	if v, ok := val["temp="]; ok {
		return Temp_Var{name = strings.clone(v.(string))}
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
	case Divert_Assign:
		delete(v.path)
	case Temp_Var:
		delete(v.name)
	}
}
