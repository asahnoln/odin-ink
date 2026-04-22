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
	switch val in j {
	case json.String:
		return parse_str_into_elem(val)
	case json.Integer:
		return cast(f64)val, nil
	case json.Float:
		return val, nil
	case json.Boolean:
		return val, nil
	case json.Object:
		res := make(map[string]Element, len(val))
		for k, v in val {
			if s, ok := v.(string); ok {
				res[k] = s
			} else {
				res[k] = convert_json(v) or_return
			}
		}
		return res, nil
	case json.Array:
		res := make([]Element, len(val))
		for v, i in val {
			res[i] = convert_json(v) or_return
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

parse_str_into_elem :: proc(s: string) -> (e: Element, err: JSON_Conversion_Error) {
	if len(s) > 0 && s[0] == '^' {
		e = strings.clone(s[1:])
		return
	}

	if s == "\n" {
		e = strings.clone(s)
		return
	}

	switch s {
	case "ev":
		e = .Ev
	case "/ev":
		e = .EvEnd
	case "str":
		e = .Str
	case "/str":
		e = .StrEnd
	case "done":
		e = .Done
	case:
		err = Unknown_Cmd_Error{s}
	}

	return
}
