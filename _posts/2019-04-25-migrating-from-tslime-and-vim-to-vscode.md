---
title: "Migrating from TSlime and Vim to VSCode"
tags: ['code', 'vscode']
date: 2019-04-25
layout: 'post'
---

I'm trying out VSCode. It's pretty good. Using the Vim extension, I can
recreate my [tslime workflow](/2011/08/20/vim-and-tmux-on-osx/) giving me one
command save-cancel-rerun behaviour in the integrated terminal. In
`Preferences -> Settings`, and JSON edit mode, add the following to the
existing:

```json
{
    "vim.leader": ";",
    "vim.normalModeKeyBindingsNonRecursive": [
        {
            "before": ["<leader>", "p"],
            "after": [],
            "commands": [
                {
                    "command": "workbench.action.quickOpen"
                }
            ],
        },
        {
            "before": ["<leader>", "s"],
            "after": [],
            "commands": [
                {
                    "command": "workbench.action.files.save"
                },
                {
                    "command": "workbench.action.terminal.sendSequence",
                    "args": {"text": "\u0003!!\u000d"}
                }
            ]
        }
    ],
}
```

Also includes a cheeky `<leader>p` binding to replace `command+P` for quick
open since it's more ergonomic on my layout. Relevant documentation:

* [Vim extension README](https://github.com/VSCodeVim/Vim) for overall configuration primer.
* [Vim extension issue
  comment](https://github.com/VSCodeVim/Vim/issues/2552#issuecomment-384401284)
  with exact incantation for remapping quick open.
* [VSCode default
  keybindings](https://code.visualstudio.com/docs/getstarted/keybindings) for
  finding out that `command+S` is actually `workbench.action.files.save`.