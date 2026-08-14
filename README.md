# Bridgetown Website README

Welcome to your new Bridgetown website! You can update this README file to provide additional context and setup information for yourself or other contributors.

## Table of Contents

- [Bridgetown Website README](#bridgetown-website-readme)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Development](#development)
    - [Commands](#commands)
  - [The baseline build](#the-baseline-build)
    - [Where things live](#where-things-live)
    - [Tweaking it](#tweaking-it)
    - [Things to know](#things-to-know)
  - [Deployment](#deployment)
  - [Contributing](#contributing)

## Prerequisites

- [Ruby](https://www.ruby-lang.org/en/downloads/)
  - `>= 3.3`
- [Bridgetown gem](https://gems.bridgetownrb.com/)
  - `gem install bridgetown -N`
- [Node](https://nodejs.org)
  - `>= 22`

## Install

```sh
cd bridgetown-site-folder
bundle install && npm install
```
> Learn more: [Bridgetown Getting Started Documentation](https://www.bridgetownrb.com/docs/).

## Development

To start your site in development mode, run `bin/bridgetown start` and navigate to [localhost:4000](https://localhost:4000/)!

Check out [plugins](https://www.bridgetownrb.com/plugins/) if you're looking to add functionality or a theme to your site.

### Commands

```sh
# running locally
bin/bridgetown start

# build & deploy to production
bin/bridgetown deploy

# load the site up within a Ruby console (IRB)
bin/bridgetown console
```

> Learn more: [Bridgetown CLI Documentation](https://www.bridgetownrb.com/docs/command-line-usage)

## The baseline build

The site ships in two versions from one source. The real site is the finished
work; the **baseline** is the same site rendered badly on purpose, so the two can
be put side by side under Lighthouse to show what the work was worth.

The baseline is *derived* from the real site on every build rather than kept as a
second set of templates. Change the site and the baseline changes with it — it
can never drift into being a different site that merely looks worse.

```sh
# both: the real site into output/, the baseline into output/baseline/
bundle exec rake deploy_with_baseline

# the real site on its own
bin/bridgetown deploy
```

Locally that gives you `/` and `/baseline/`; deployed, `meadowbrookbakery.com/`
and `meadowbrookbakery.com/baseline/`. The GitHub Pages workflow runs
`deploy_with_baseline`, so both go up together as one artifact.

Point Lighthouse at `?disclaimer=off` on **both** URLs. Lighthouse uses a fresh
profile every run, so it meets the disclaimer modal every time, and auditing a
page under a blurred scrim skews the comparison.

### Where things live

| File | What it does |
| ---- | ------------ |
| `plugins/baseline.rb` | The degradations themselves. One method each, named for the Lighthouse audit it aims at. Knows nothing about Bridgetown — it takes a parsed document and mutates it. |
| `plugins/builders/baseline_build.rb` | Runs them over every rendered page via the Inspectors API. Does nothing at all unless `BLOOMLIGHT_BASELINE` is set, so ordinary builds are untouched. |
| `config/initializers.rb` | Sets `base_path` and the destination when that variable is present. |
| `Rakefile` | `deploy_with_baseline` builds the real site, then the baseline beside it. |
| `test/test_baseline.rb` | Each degradation against a scrap of HTML, so a failure names the transform that broke. |

### Tweaking it

**Add or remove a degradation.** Write a method in `Baseline` that takes the
parsed document, then add a call to it in `Baseline.degrade`. Removing one means
deleting its line from `degrade`. The methods are deliberately small and
independent of each other.

**Change how bad the contrast is.** `WASHED_TEXT` and `WASHED_BUTTON_TEXT` at the
top of `plugins/baseline.rb`, with `BODY_FONT_SIZE` for the type. Contrast is
applied as an inline style rather than by swapping in a paler Tailwind class, and
that matters: Tailwind only compiles classes it can find in the source, so an
unknown class yields no style at all and would degrade nothing.

**Change which images get swapped.** `serve_oversized_images` reaches for a
`.png` of the same name when one sits beside the shipped image in
`src/images/photos`. Drop a heavy PNG in next to an existing photo and the
baseline picks it up on the next build; the real site keeps using the webp.

**Change the URL.** `base_path` and `destination` in `config/initializers.rb`,
plus the `cp_r` target in the `deploy_with_baseline` Rake task.

### Things to know

- Baseline pages carry `<meta name="robots" content="noindex">` so the degraded
  copy is never indexed in place of the real site. Lighthouse scores that against
  it, which is fair enough here, but it does mean one SEO mark is structural
  rather than earned. Drop `ask_not_to_be_indexed` from `degrade` if you want the
  comparison purely on merit.
- `output/baseline/robots.txt` and `output/baseline/sitemap.xml` are build
  artifacts describing the baseline's own URLs. Nothing links to them and the
  root sitemap excludes `/baseline/` — don't submit them anywhere.
- `keep_files` in the config stops a plain `bin/bridgetown build` sweeping the
  baseline away as an orphan of the main build. `rake clean` still removes it.

## Deployment

You can deploy Bridgetown sites on hosts like statichost.eu and Render as well as traditional web servers by simply building and copying the output folder to your HTML root.

> Read the [Bridgetown Deployment Documentation](https://www.bridgetownrb.com/docs/deployment) for more information.

## Contributing

If repo is on GitHub:

1. Fork it
2. Clone the fork using `git clone` to your local development machine.
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
