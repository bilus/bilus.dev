---
title: "Oh no, not again, or: Porting Phoenix LiveView to Go"
date: 2026-08-20
draft: false
audio: ["https://blog-assets.bilus.dev/audio/porting-liveview-to-go.mp3"]
tags: ["go", "elixir", "liveview", "templ"]
summary: "Why I'm porting Phoenix LiveView to Go, the rules I'm setting to avoid stalling like the attempts before mine, and the first four milestones."
---

I've been using [Ergo](https://github.com/ergo-services/ergo) at work lately. It brings the Erlang actor model to Go: processes, mailboxes, supervision trees. Working with it reminded me how much I liked Elixir, and one thing led to another. I decided to port [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) to Go. Crazy, right?

If you haven't run into LiveView before (it comes from Phoenix, the Elixir web framework), here's the short version:

> LiveView keeps a bit of state on the server for each open browser tab and renders the HTML there. A click sends an event over a WebSocket, your handler updates that state, and the server sends back only the parts of the page that changed. You write no JavaScript, there's no JSON API in the middle, and the page still behaves like a single-page app.

For a Go developer that means an interactive UI without a separate frontend app to build and deploy.

LiveView is really two halves: a server that holds the state and renders, and a small JavaScript client that opens the WebSocket and patches the DOM. I only want to write the server half. The client stays as it is, the official Phoenix [client library](https://www.npmjs.com/package/phoenix_live_view) straight from npm. That works because the only thing connecting the two halves is the wire protocol. If my server speaks it correctly, the client can't tell what's on the other end.

I'm not the [first one](https://github.com/jfyne/live) to try this, not even [the second one](https://github.com/go-live-view/go-live-view). Both projects have gone quiet. Will I give up too? We'll find out. I'm trying to stack the odds by (a) speaking about it publicly (this post) to keep me motivated and (b) with a few rules (below) to hopefully generate some traction.

The library has to be idiomatic Go, so no bending Go into Elixir. It has to be minimal and stay out of your way: a library, not another web framework, so you keep whatever router and server you already have. I'm adapting Phoenix's own tests into a conformance suite, to make sure my server really does speak the protocol. And I have a real use case at work, an internal project that's complex and important enough to be a proper test once the library is mature.

For rendering I'm betting on [templ](https://templ.guide), which is popular with Go developers and, more usefully, already does half the job. It compiles HTML templates into Go code, and it exposes its parser. So I don't have to invent a template language. I walk templ's AST and emit a second backend next to its own. Where templ generates code that writes HTML to an `io.Writer`, mine generates code that produces the diffs the client knows how to apply.

Enough talking, time to put my money where my mouth is. Here are the first four milestones on my roadmap.

<ol class="roadmap">
  <li>
    <strong>Foundations and conformance tests</strong>
    <p>Design the API, at least in broad strokes, and build a test harness with a set of reference tests, mostly adapted from Phoenix's own Playwright specs.</p>
  </li>
  <li>
    <strong>Static rendering and layouts</strong>
    <p>A modest one. At the end of it you can render a simple component with no dynamic parts, what Phoenix calls a dead render: the server sends HTML on the first page load, before the WebSocket connects. Static layouts come along for the ride, they're easy enough.</p>
  </li>
  <li>
    <strong>The differ</strong>
    <p>Elixir data is immutable, so Phoenix can lean on identity to see what changed between two renders. Go gives you no such guarantee, so I have to diff the render tree myself to find the changed parts.</p>
  </li>
  <li>
    <strong>Dynamics, events, and the session runtime</strong>
    <p>This is where it gets interesting. The goal is to be able to build <a href="https://todomvc.com/">TodoMVC</a> with the library as a proof that it covers the bare minimum.</p>
  </li>
</ol>

That's the initial plan.
