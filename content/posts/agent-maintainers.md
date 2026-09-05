---
title: "Maintainer agents"
date: 2026-09-05
draft: false
tags: ["ai", "agents", "architecture"]
summary: "A wild idea I have not tried yet: give every package in a codebase its own maintainer agent, show the other agents only the interface, and route every change through the owner."
audio: ["https://blog-assets.bilus.dev/audio/agent-maintainers.mp3"]
---

I've been doing a lot of experiments lately, burning tokens like there's no tomorrow. Here is an idea I have not tried (yet). Every module (or package, or namespace, whatever your particular language calls them, or perhaps class or component) in a codebase gets its own maintainer agent. The maintainer owns every change to its module. Another agent wants a change to that module? It goes through the maintainer. Respect my authorita!

This idea has been circulated [before](https://addyosmani.com/blog/code-agent-orchestra/), [several](https://arxiv.org/abs/2602.20478) [times](https://code.claude.com/docs/en/agent-teams), as I found out after drafting the first version of this article.

Now, here's something I haven't read about. Other agents not only cannot modify the modules they don't own, they cannot look inside them either. That's right! All they get is the exposed interface and a description of how the module works, good enough to predict how it will behave. If they need to know anything more, they can ask the maintainer.

This makes the context of each individual agent smaller, because it holds the details of only the module it owns. Every other module is an interface and a paragraph. At least in theory. As I said, I haven't tried it.

> This "ask the maintainer" thing is interesting on its own. Hear me out: if somebody has to ask you something about your code which isn't obvious from its documentation, there's something wrong with either the documentation or the interface. As a human maintainer you would remember those questions, hopefully, and use them to create a v2. Right? Is there a reason an agent cannot do the same? But I digress.

Where it breaks down is when the agents become chatty. Or when the interfaces between packages require constant changes. If the packages are coupled rather than cohesive, you will end up with a lot of churn, chat and negotiations between the agents. At least that is what I imagine, having so often been in the position of negotiating interfaces between collaborating teams. Speaking of which, the solution here is probably the same as with teams: an architect agent?

In any case this will lead to a more rigid design, like with real teams: once interfaces are in place, changing them is costly, so sometimes it's better to accumulate technical debt and use workarounds. That's not objectively good for the architecture of the code, but it's better for the reviewing humans, because sweeping changes are harder to review than local changes inside a module.

Which brings me to my final point, which is this: the whole idea isn't really about making AI more efficient at filling hard disks with source code. It's about making it easier for humans to review the code AI produces. A change inside a module is local, and a reviewer can check it against the module's interface and its tests without holding the rest of the system in their head. A change to an interface is rare, because it costs a negotiation, and it arrives labeled as such, so the reviewer knows which changes deserve the slow look. What is inside a module may even be ugly, as long as the interface keeps its promises and the tests say so. Whether the agents actually stay this disciplined, and how much chat a real codebase produces, is what I want to find out.
