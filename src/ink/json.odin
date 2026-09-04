package ink

import "core:encoding/json"
import "core:strings"

json_convert :: proc(j: json.Value) -> Element {
	#partial switch val in j {
	case json.Array:
		return _json_convert_array(val)
	case json.Integer:
		return f64(val)
	case json.String:
		return _json_convert_string(val)
	case json.Object:
		return _json_convert_object(val)
	}

	return nil
}

_json_convert_array :: proc(val: json.Array) -> Container {
	c := make(Container, len(val))
	for v, i in val {
		if i < len(val) - 1 {
			c[i] = json_convert(v)
			continue
		}

		if o, ok := v.(json.Object); ok {
			info := Container_Info {
				name  = strings.clone(o["#n"].(string) or_else ""),
				flags = transmute(Container_Flag_Set)cast(u8)(o["#f"].(json.Integer) or_else 0),
				subs  = make(map[string]Container),
			}

			for n, sub in o {
				switch n {
				case "#n", "#f":
					continue
				}

				info.subs[strings.clone(n)] = json_convert(sub).(Container)
			}

			c[i] = info
		}
	}

	return c
}

_json_convert_string :: proc(val: json.String) -> Element {
	if val[0] == '^' {
		return strings.clone(val[1:])
	}

	switch val {
	case "\n":
		return strings.clone(val)
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

	if p, ok := val["*"]; ok {
		return Choice {
			path = strings.clone(p.(string)),
			flags = transmute(Choice_Flag_Set)cast(u8)val["flg"].(json.Float),
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
	}
}
