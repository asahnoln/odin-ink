package ink

import "base:runtime"
import "core:encoding/json"
import "core:strings"

json_convert :: proc(
	j: json.Value,
	allocator := context.allocator,
) -> (
	e: Element,
	err: runtime.Allocator_Error,
) #optional_allocator_error {
	context.allocator = allocator

	switch val in j {
	case json.Array:
		return _json_convert_array(val)
	case json.String:
		return _json_convert_string(val)
	case json.Object:
		return _json_convert_object(val)
	case json.Boolean:
		e = val
	case json.Integer:
		e = cast(f64)val
	case json.Float:
		e = val
	case json.Null:
	}

	return
}

@(private)
_json_convert_array :: proc(val: json.Array) -> (c: Container, err: runtime.Allocator_Error) {
	c = make(Container, len(val)) or_return
	for v, i in val {
		if i < len(val) - 1 {
			c[i] = json_convert(v) or_return
			continue
		}

		c[i] = _json_convert_info(v) or_return
	}

	return c, err
}

@(private)
_json_convert_info :: proc(v: json.Value) -> (e: Element, err: runtime.Allocator_Error) {
	if o, ok := v.(json.Object); ok {
		info := Container_Info {
			name  = strings.clone(o["#n"].(string) or_else "") or_return,
			flags = transmute(Container_Flag_Set)cast(u8)(o["#f"].(json.Integer) or_else 0),
			subs  = make(map[string]Container),
		}

		for n, sub in o {
			switch n {
			case "#n", "#f":
				continue
			}

			cnt := json_convert(sub) or_return
			info.subs[strings.clone(n) or_return] = cnt.(Container)
		}

		e = info
	}

	return
}

@(private)
_json_convert_string :: proc(val: json.String) -> (e: Element, err: runtime.Allocator_Error) {
	if val[0] == '^' {
		return strings.clone(val[1:])
	}

	switch val {
	case "\n":
		return strings.clone(val)
	case "done":
		e = .Done
	case "str":
		e = .Str
	case "/str":
		e = .Str_End
	case "ev":
		e = .Ev
	case "/ev":
		e = .Ev_End
	}

	return
}

@(private)
_json_convert_object :: proc(val: json.Object) -> (e: Element, err: runtime.Allocator_Error) {
	if p, ok := val["->"]; ok {
		return Divert {
				path = strings.clone(p.(string)) or_return,
				var = val["var"].(bool) or_else false,
			},
			nil
	}

	if p, ok := val["^->"]; ok {
		return Divert_Assign{path = strings.clone(p.(string)) or_return}, nil
	}

	if v, ok := val["temp="]; ok {
		return Temp_Var{name = strings.clone(v.(string)) or_return}, nil
	}

	if p, ok := val["*"]; ok {
		return Choice {
				path = strings.clone(p.(string)) or_return,
				flags = transmute(Choice_Flag_Set)cast(u8)val["flg"].(json.Float),
			},
			nil
	}

	return
}

destroy_element :: proc(el: Element, allocator := context.allocator) {
	context.allocator = allocator

	switch v in el {
	case Container:
		for e in v {
			destroy_element(e)
		}

		delete(v)
	case Container_Info:
		for n, c in v.subs {
			destroy_element(c)
			delete(n)
		}

		delete(v.subs)
		delete(v.name)
	case string:
		delete(v)
	case Divert:
		delete(v.path)
	case Divert_Assign:
		delete(v.path)
	case Temp_Var:
		delete(v.name)
	case Choice:
		delete(v.path)
	case Control_Command, f64, bool:
	}
}
