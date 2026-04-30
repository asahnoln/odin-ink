package ink

import "core:strings"
collect :: proc(c: Container, path: ^[dynamic]int) -> string {
	b := strings.builder_make()

	process_container(c, path, &b, 0)

	return strings.to_string(b)
}

process_container :: proc(
	c: Container,
	path: ^[dynamic]int,
	b: ^strings.Builder,
	deep: int,
) -> (
	cont: bool,
) {
	if len(path) > deep + 1 {
		process_container(c[path[deep]].(Container), path, b, deep + 1) or_return
	}

	defer if path[deep] == len(c) {
		pop_safe(path)

		if deep > 0 {
			path[deep - 1] += 1
		}
	}

	base := path[deep]
	for e, i in c[base:] {
		if e, ok := e.(Container); ok {
			append(path, 0)
			process_container(e, path, b, len(path) - 1)
			continue
		}

		strings.write_string(b, e.(string))
		path[deep] = base + i + 1


		if e.(string) == "\n" {
			return false
		}
	}


	return true
}
