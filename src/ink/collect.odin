package ink

import "core:strings"

collect :: proc(c: Container, idx_path: ^[dynamic]int) -> string {
	b := strings.builder_make()

	traverse_container(c, idx_path, 0, proc(e: Element, data: ^strings.Builder) -> (cont: bool) {
			if str, ok := e.(string); ok {
				b := data
				strings.write_string(b, str)

				if str == "\n" {
					return false
				}
			}

			return true
		}, &b)

	return strings.to_string(b)
}
