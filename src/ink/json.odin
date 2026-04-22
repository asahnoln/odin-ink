package ink

import "core:encoding/json"
import "core:strings"

JSON_Conversion_Error :: union {
	Unknown_Cmd_Error,
}

Unknown_Cmd_Error :: struct {
	v: string,
}

convert_json :: proc(
	j: json.Value,
	allocator := context.allocator,
) -> (
	e: Element,
	err: JSON_Conversion_Error,
) {
	switch val in j {
	case json.String:
		return parse_str_into_elem(val, allocator)
	case json.Integer:
		return cast(f64)val, nil
	case json.Float:
		return val, nil
	case json.Boolean:
		return val, nil
	case json.Object:
		return parse_obj_into_elem(val, allocator)
	case json.Array:
		res := make([]Element, len(val), allocator)
		for v, i in val {
			res[i] = convert_json(v, allocator) or_return
		}
		return res, nil
	case json.Null:
		return nil, nil
	}

	return nil, nil
}

destroy_element :: proc(e: Element, allocator := context.allocator) {
	switch v in e {
	case []Element:
		for x in v {
			destroy_element(x, allocator)
		}
		delete(v, allocator)
	case map[string]Element:
		for _, x in v {
			destroy_element(x, allocator)
		}
		delete(v)
	case string:
		delete(v, allocator)
	case DivertValue:
		destroy_element(v.path)
	case Divert:
		destroy_element(v.path)
	case VarAssignTemp:
		destroy_element(v.name)
	case bool, f64, Cmd:
	}
}

parse_str_into_elem :: proc(
	s: string,
	allocator := context.allocator,
) -> (
	e: Element,
	err: JSON_Conversion_Error,
) {
	switch {
	case s == "\n":
		return strings.clone(s, allocator), err
	case len(s) > 0 && s[0] == '^':
		return strings.clone(s[1:], allocator), err
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

	return e, err
}

parse_obj_into_elem :: proc(
	obj: json.Object,
	allocator := context.allocator,
) -> (
	e: Element,
	err: JSON_Conversion_Error,
) {
	if path, ok := obj["^->"].(string); ok {
		return DivertValue{path = strings.clone(path, allocator)}, nil
	}
	if path, ok := obj["->"].(string); ok {
		return Divert{path = strings.clone(path, allocator)}, nil
	}
	if name, ok := obj["temp="].(string); ok {
		return VarAssignTemp{name = strings.clone(name, allocator)}, nil
	}

	res := make(map[string]Element, len(obj), allocator)
	for k, v in obj {
		if s, ok := v.(string); ok {
			res[k] = strings.clone(s, allocator)
		} else {
			res[k] = convert_json(v, allocator) or_return
		}
	}
	return res, nil
}
