package ink

import "core:encoding/json"
import "core:slice"
import "core:strconv"
import "core:strings"

Element :: union {
	string,
	f64,
	bool,
	Container,
	Container_Info,
	Control_Command,
	Choice,
	Divert,
	Divert_Assign,
	Temp_Var,
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
	Nop,
	Ev,
	Str,
	Str_End,
	Ev_End,
	Done,
}

Divert :: struct {
	path: string,
	var:  bool,
}

Divert_Assign :: struct {
	path: string,
}

Temp_Var :: struct {
	name: string,
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
	path:     string,
	flags:    Choice_Flag_Set,
	text:     string,
	idx_path: []Idx,
}

Mode :: enum {
	Default,
	Evaluation,
	Content,
}

Idx :: union #no_nil {
	int,
	string,
}

Idx_Path :: [dynamic]Idx

Story :: struct {
	root:            Container,
	current_choices: [dynamic]Choice,
	can_continue:    bool,
	str_builder:     strings.Builder,
	stack:           [dynamic]string,
	mode:            Mode,
	idx_path:        Idx_Path,
	vars:            map[string]string,
	root_allocated:  bool,
	_last_idx:       int,
}

IDX_PATH_SEP :: "."
REL_PATH_START :: '.'
REL_PATH_PARENT :: "^"

story_make :: proc {
	story_make_empty,
	story_make_from_struct,
	story_make_from_json,
}

story_make_empty :: proc() -> Story {
	s := Story {
		str_builder     = strings.builder_make(),
		current_choices = make([dynamic]Choice),
		stack           = make([dynamic]string),
		idx_path        = make(Idx_Path),
		vars            = make(map[string]string),
		can_continue    = true,
	}

	return s
}

story_make_from_struct :: proc(c: Container) -> Story {
	s := story_make_empty()
	s.root = c
	return s
}

story_make_from_json :: proc(data: []byte) -> (s: Story, err: json.Error) {
	s = story_make_empty()

	j := json.parse(data) or_return
	defer json.destroy_value(j)

	c := json_convert(j.(json.Object)["root"])

	s.root = c.(Container)
	s.root_allocated = true

	return
}

story_destroy :: proc(s: ^Story) {
	delete(s.current_choices)
	delete(s.stack)
	delete(s.idx_path)
	delete(s.vars)
	strings.builder_destroy(&s.str_builder)

	if s.root_allocated {
		destroy_element(s.root)
	}

}

story_continue :: proc(s: ^Story) -> string {
	_process_container(s, s.root)

	s.can_continue = len(s.idx_path) > 0
	if s.can_continue {
		if _, ok := s.idx_path[len(s.idx_path) - 1].(string); ok {
			s.can_continue = false
		}
	}

	l := strings.clone(strings.trim(strings.to_string(s.str_builder), " "))
	strings.builder_reset(&s.str_builder)

	return l
}

choose_choice_index :: proc(s: ^Story, i: int) {
	// TODO: Check index bound? Return error?
	append(&s.idx_path, ..s.current_choices[i].idx_path)
	_convert_path(s.current_choices[i].path, &s.idx_path)

	for c in s.current_choices {
		delete(c.idx_path)
	}
	resize(&s.current_choices, 0)

	s.can_continue = true
}


_process_container :: proc(s: ^Story, c: Container, depth: int = 0) -> (cont: bool) {
	if len(s.idx_path) == depth {
		append(&s.idx_path, 0)
	}

	// Check string index for a named container (in or by info)
	from := 0
	switch v in s.idx_path[depth] {
	case int:
		from = v
	case string:
		if info, ok := _container_info(c); ok {
			// TODO: What happens if this container not found? Error?
			if cnt, ok := info.subs[v]; ok {
				_process_container(s, cnt, depth + 1)
				return false
			}
		}

		for e, i in c {
			if cnt, ok := e.(Container); ok {
				// TODO:: What happens if container not found? Error?
				if info, ok := _container_info(cnt); ok && info.name == v {
					from = i
					// TODO: Check for a second container with the same name?
					break
				}
			}
		}
	}

	// Travese the contents of the container
	for e, i in c[from:] {
		s.idx_path[depth] = i + from

		#partial switch v in e {
		case Container:
			_process_container(s, v, depth + 1) or_return

		case string:
			if s.mode == .Content {
				append(&s.stack, v)
				continue
			}

			if v == "\n" && strings.builder_len(s.str_builder) == 0 {
				continue
			}

			strings.write_string(&s.str_builder, v)
			if v == "\n" {
				s.idx_path[depth] = s.idx_path[depth].(int) + 1
				return false
			}

		case Divert:
			p := v.path if !v.var else s.vars[v.path]
			_convert_path(p, &s.idx_path)
			_process_container(s, s.root)
			return false

		case Divert_Assign:
			append(&s.stack, v.path)

		case Temp_Var:
			s.vars[v.name] = pop(&s.stack)

		case Choice:
			ch := v
			ch.text = pop(&s.stack)
			ch.idx_path = make([]Idx, len(s.idx_path))
			copy(ch.idx_path, s.idx_path[:])
			append(&s.current_choices, ch)

		case Control_Command:
			#partial switch v {
			case .Str:
				s.mode = .Content
			case .Ev_End:
				s.mode = .Default
			case .Done:
				// TODO: Test for .Done - is this ok to stop like that???
				return false
			}
		}
	}

	pop(&s.idx_path)
	return true
}

_container_info :: proc(c: Container) -> (Container_Info, bool) {
	return c[len(c) - 1].(Container_Info)
}

_convert_path :: proc(path: string, idxs: ^Idx_Path) {
	p_idx := 0
	if path[0] == REL_PATH_START {
		p_idx = 1
	}

	p := strings.split(path[p_idx:], IDX_PATH_SEP)
	defer delete(p)

	idx_path_resize := 0
	if p_idx == 1 {
		idx_path_resize = slice.count(p, REL_PATH_PARENT)
	}

	pop_safe(idxs)

	resize(idxs, 0 if idx_path_resize == 0 else len(idxs) - idx_path_resize + 1)

	for i in p[idx_path_resize:] {
		iu: Idx
		ix, ok := strconv.parse_int(i, 10)
		iu = ix if ok else i
		append(idxs, iu)
	}
}
