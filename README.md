# Odin port of Ink

## API

Adapt original Ink API

```odin
// 1) Load story
story := ink.make_story(source_json_bytes);

// 2) Game content, line by line
for story.can_continue {
    fmt.println(ink.story_continue(&story));
}

// 3) Display story.current_choices list, allow player to choose one
fmt.println(story.current_choices[0].text);
ink.choose_choice_index(&story, 0);
```

## TODO

- [ ] Parse different JSON objects into different types
- [ ] Apply choice elements

## Technical details

- Text lines should be optimized: "^line" and next "\n" concatenated
