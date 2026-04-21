package ink

import "core:encoding/json"
import "core:strings"

convert_json :: proc(j: json.Value) -> Element {
	switch v in j {
	case json.String:
		return strings.clone(v[1:])
	// return v[1:]
	case json.Integer:
		return cast(f64)v
	case json.Float:
		return v
	case json.Boolean:
		return v
	case json.Object:
		res := make(map[string]Element, len(v))
		for k, e in v {
			res[k] = convert_json(e)
		}
		return res
	case json.Array:
		res := make([]Element, len(v))
		for e, i in v {
			res[i] = convert_json(e)
		}
		return res
	case json.Null:
		return nil
	}

	return nil
}

destroy_element :: proc(e: Element) {
	switch v in e {
	case []Element:
		for x in v {
			destroy_element(x)
		}
		delete(v)
	case map[string]Element:
		for _, x in v {
			destroy_element(x)
		}
		delete(v)
	case string:
		delete(v)
	case bool, f64:
	}
}
