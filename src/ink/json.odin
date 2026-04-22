package ink

import "core:encoding/json"
import "core:strings"

JSON_Conversion_Error :: union {
	Unknown_Cmd_Error,
}

Unknown_Cmd_Error :: struct {
	v: string,
}

convert_json :: proc(j: json.Value) -> (e: Element, err: JSON_Conversion_Error) {
	switch v in j {
	case json.String:
		return parse_str_into_elem(v)
	case json.Integer:
		return cast(f64)v, nil
	case json.Float:
		return v, nil
	case json.Boolean:
		return v, nil
	case json.Object:
		res := make(map[string]Element, len(v))
		for k, e in v {
			res[k] = convert_json(e) or_return
		}
		return res, nil
	case json.Array:
		res := make([]Element, len(v))
		for e, i in v {
			res[i] = convert_json(e) or_return
		}
		return res, nil
	case json.Null:
		return nil, nil
	}

	return nil, nil
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
	case bool, f64, Cmd:
	}
}

parse_str_into_elem :: proc(v: string) -> (e: Element, err: JSON_Conversion_Error) {
	if len(v) > 0 && v[0] == '^' {
		return strings.clone(v[1:]), nil
	}

	switch v {
	case "ev":
		return .Ev, nil
	case "/ev":
		return .EvEnd, nil
	case "str":
		return .Str, nil
	case "/str":
		return .StrEnd, nil
	case:
		return nil, Unknown_Cmd_Error{v}
	}

}
