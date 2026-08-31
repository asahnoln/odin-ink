package ink

import "core:log"
import "core:strconv"
import "core:strings"
Element :: union {
	Container,
	Container_Info,
	string,
	Control_Command,
	Choice,
	Divert,
}

Container :: []Element

Container_Flag :: enum {
	Visits,
	Turns,
	Count_Start_Only,
}

Container_Flag_Set :: bit_set[Container_Flag]

Container_Info :: struct {
	flags: Container_Flag_Set,
	name:  string,
	subs:  map[string]Container,
}

Control_Command :: enum {
	Ev,
	Str,
	Str_End,
	Ev_End,
	Done,
}

Divert :: struct {
	path: string,
}

Choice_Flag :: enum {
	Has_Condition,
	Has_Start_Content,
	Has_ChoiceOnly_Content,
	Is_Invisible_Default,
	Once_Only,
}

Choice_Flag_Set :: bit_set[Choice_Flag]

Choice :: struct {
	path:  string,
	flags: Choice_Flag_Set,
	text:  string,
}

Mode :: enum {
	Default,
	Evaluation,
	Content,
}

Story :: struct {
	root:            Container,
	current_choices: [dynamic]Choice,
	str_builder:     strings.Builder,
	stack:           [dynamic]string,
	mode:            Mode,
	_last_index:     Maybe(uint),
}

story_make :: proc {
	story_make_empty,
	story_make_from_struct,
}

story_make_empty :: proc() -> Story {
	return {}
}

story_make_from_struct :: proc(c: Container) -> Story {
	return {root = c, str_builder = strings.builder_make()}
}

story_destroy :: proc(s: ^Story) {
	delete(s.current_choices)
	delete(s.stack)
	strings.builder_destroy(&s.str_builder)
}

story_continue :: proc(s: ^Story) -> string {
	if _, ok := s._last_index.?; !ok {
		_process_container(s, s.root)
	} else {
		p := strings.split(s.current_choices[0].path, ".")
		defer delete(p)

		i, _ := strconv.parse_uint(p[0])
		c := s.root[i].(Container)
		_process_container(s, c[len(c) - 1].(Container_Info).subs[p[1]])
	}

	return strings.to_string(s.str_builder)
}

choose_choice_index :: proc(s: ^Story, i: uint) {
	s._last_index = i
}

_process_container :: proc(s: ^Story, c: Container) -> (cont: bool) {
	for e in c {
		#partial switch v in e {
		case Container:
			_process_container(s, v) or_return
		case string:
			if s.mode == .Content {
				append(&s.stack, v)
				break
			}

			if len(s.str_builder.buf) == 0 && strings.trim(v, " \n") == "" {
				break
			}

			strings.write_string(&s.str_builder, v)

			if v == "\n" {
				return false
			}
		case Choice:
			append(&s.current_choices, Choice{path = v.path, text = pop(&s.stack)})
		case Control_Command:
			#partial switch v {
			case .Str:
				s.mode = .Content
			case .Ev_End:
				s.mode = .Default
			}

		}

	}

	return true
}
