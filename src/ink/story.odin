package ink

import "base:runtime"
import "core:encoding/json"
import "core:strings"

// Error when applying element to Story
Apply_Elem_Error :: union {
	Stack_Element_Cast_Error,
	Error,
	runtime.Allocator_Error,
}

// Error when applying math func to Story
Stack_Element_Cast_Error :: struct {
	T:    typeid,
	v, y: Stack_Element,
}

Error :: enum {
	Short_Stack_Error,
}

// Element of a Story.
// Parsed from JSON into understandable structs.
Element :: union {
	bool,
	string,
	f64,
	Cmd,
	Func,
	Container,
	Divert,
	DivertValue,
	VarAssignTemp,
	Choice,
	map[string]Element,
}

Container :: []Element

// Divert value which is pushed to the evaluation stack and then popped into a variable.
DivertValue :: struct {
	path: string,
}

// Divert to some path
Divert :: struct {
	path: string,
	var:  bool,
}

// A temp variable which takes value from evaluation stack
VarAssignTemp :: struct {
	name: string,
}

Choice_Flag :: enum {
	Has_Condition,
	Has_Start_Content,
	Has_Choice_Only_Content,
	Is_Invisible_Default,
	Once_Only,
}

Choice_Flags :: bit_set[Choice_Flag]

// Choice object
Choice :: struct {
	path: string,
	flag: Choice_Flags,
	text: string,
}

// Story mode changed with commands
Mode :: enum {
	Default,
	// Evaluation mode saves Elements to evaluation stack
	Evaluation,
	// Content mode appends Elements to one string
	Content,
	// Done mode is the final mode when the Story is finished
	Done,
}

// Cmd is a command which applies to the story and changes its modes
Cmd :: enum {
	Ev,
	EvEnd,
	Str,
	StrEnd,
	Done,
}

// Func is a math func which takes values from evaluation stack and does something with them
Func :: enum {
	Plus,
}

// Stack_Element is an element of evaluation stack
Stack_Element :: union {
	f64,
	string,
}

// Story is the main object of Ink. It hold all information about the Story.
Story :: struct {
	can_continue:       bool,
	current_choices:    [dynamic]Choice,
	root:               Element,
	mode:               Mode,
	ev_stack:           [dynamic]Stack_Element,
	current_text_array: [dynamic]string,
	current_text_index: uint,
	allocator:          runtime.Allocator,
}

// Story_Make_Error happens when there are JSON errors while parsing or converting
Story_Make_Error :: union {
	json.Error,
	JSON_Conversion_Error,
	Apply_Elem_Error,
}

story_make :: proc {
	story_make_empty,
	story_make_from_json,
}

// Makes empty Story
story_make_empty :: proc(allocator := context.allocator) -> Story {
	return Story {
		ev_stack = make([dynamic]Stack_Element, allocator),
		current_choices = make([dynamic]Choice, allocator),
		allocator = allocator,
	}
}

// Creates Story populated from given JSON data
story_make_from_json :: proc(
	json_data: []byte,
	allocator := context.allocator,
) -> (
	s: Story,
	err: Story_Make_Error,
) {
	j := json.parse(json_data, allocator = allocator) or_return
	defer json.destroy_value(j, allocator)

	s = story_make(allocator)
	s.root = convert_json(j.(json.Object)["root"], allocator) or_return
	s.can_continue = true

	apply_elem(&s, s.root) or_return

	return
}

// Deletes Story's evaluation stack, root container and builder
story_destroy :: proc(s: ^Story) -> runtime.Allocator_Error {
	delete(s.ev_stack) or_return
	destroy_element(s.root, s.allocator) or_return
	delete(s.current_text_array) or_return
	delete(s.current_choices) or_return

	return nil
}

// Continues Story. It's user's responsibility to deallocate given string
story_continue :: proc(s: ^Story, allocator := context.allocator) -> string {
	// NOTE: Don't destroy the builder as it destroys its buffer that we give to the user
	b := strings.builder_make(allocator)
	strings.builder_destroy(&b)

	for s.current_text_index < len(s.current_text_array) {
		text := s.current_text_array[s.current_text_index]
		strings.write_string(&b, text)
		s.current_text_index += 1

		if text == "\n" {
			break
		}
	}


	s.can_continue = s.current_text_index < len(s.current_text_array)
	return strings.to_string(b)
}

apply_elem :: proc(s: ^Story, el: Element) -> Apply_Elem_Error {
	#partial switch &v in el {
	case Container:
		return apply_elem_container(s, v)
	case string:
		return apply_elem_str(s, v)
	case Cmd:
		apply_elem_cmd(s, v)
	case Func:
		return apply_elem_func(s, v)
	case Choice:
		return apply_elem_choice(s, &v)
	}

	return nil
}

// Applies Container to Story
apply_elem_container :: proc(s: ^Story, el: Container) -> Apply_Elem_Error {
	for e in el {
		apply_elem(s, e) or_return
	}

	return nil
}

// Apply common text to Story
apply_elem_str :: proc(s: ^Story, el: string) -> Apply_Elem_Error {
	append(&s.current_text_array, el) or_return
	return nil
}

// Apply command to Story
apply_elem_cmd :: proc(s: ^Story, el: Cmd) {
	switch el {
	case .Ev:
		s.mode = .Evaluation
	case .EvEnd:
		s.mode = .Default
	case .Str:
		s.mode = .Content
	case .StrEnd:
		s.mode = .Evaluation
	case .Done:
		s.mode = .Done
	}
}

// Apply math func to Story
apply_elem_func :: proc(s: ^Story, el: Func) -> Apply_Elem_Error {
	x := ev_stack_pop(f64, &s.ev_stack) or_return
	y := ev_stack_pop(f64, &s.ev_stack) or_return

	append(&s.ev_stack, x + y) or_return

	return nil
}

// Pops f64 number from Story's evaluation stack
ev_stack_pop :: proc($T: typeid, st: ^[dynamic]Stack_Element) -> (x: T, err: Apply_Elem_Error) {
	el, ok := pop_safe(st)
	if !ok {
		return x, .Short_Stack_Error
	}

	x, ok = el.(T)
	if !ok {
		err = Stack_Element_Cast_Error {
			T = T,
			v = el,
		}
	}

	return x, err
}

// Populate choices of Story. Takes text from evaluation stack
apply_elem_choice :: proc(s: ^Story, c: ^Choice) -> Apply_Elem_Error {
	c.text = ev_stack_pop(string, &s.ev_stack) or_return
	append(&s.current_choices, c^) or_return

	return nil
}
