#+feature dynamic-literals
package ink_test

import "core:testing"
import "src:ink"

@(test)
path :: proc(t: ^testing.T) {
	ink.get_container_by_path(
		ink.Container {
			ink.Container {
				"Hey",
				map[string]ink.Element {
					"s" = ink.Container { 	//
						"Wow",
					},
				},
			},
		},
		"0.0.s",
	)
}
