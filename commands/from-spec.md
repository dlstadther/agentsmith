---
description: Convert a markdown spec or design doc into Beads issues (epic + tasks + dependencies + gap review)
argument-hint: "<path/to/spec.md> [existing-epic-bead-id]"
allowed-tools: Bash(bd *), Read
---

## Arguments

$ARGUMENTS

## Spec contents

!`ARGS="$ARGUMENTS"; FILE=$(echo $ARGS | awk '{print $1}'); cat "$FILE" 2>/dev/null || echo "⚠️  Could not read file: $FILE — please check the path"`

## Your task

Invoke the `agentsmith:from-spec` skill and follow it exactly to convert the spec above into Beads issues.

If a second argument was provided (a bead ID), treat that existing bead as the epic rather than creating a new one — update it with the spec path reference and create tasks beneath it.

Do not create any Beads issues until you have read the full spec and identified all tasks and their dependencies.
