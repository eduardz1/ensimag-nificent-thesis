#import "@preview/tidy:0.4.3"
#import "@preview/alexandria:0.2.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/glossy:0.8.0": *
#import "@preview/algorithmic:1.0.3": style-algorithm
#import "cover.typ": cover

/// Template for a thesis document.
/// -> content
#let template(
  /// The specialization -> str
  specialization: "<Your Specialization>",
  /// The thesis' title. -> str
  title: "<Project Title>",
  /// The date of the thesis defense. -> datetime
  defense-date: datetime.today(),
  /// The candidate's name. -> str
  name: "<Your Name>",
  /// The lab in which you perfomed the research project. -> str
  lab: "<Your Lab>",
  /// The supervisor (or multiple supervisors) of the thesis. -> str | list(str)
  supervisor: "<Your Supervisor(s)>",
  /// The list of members of the jury. -> dictionary
  jury: (
    president: "<President of the Jury>",
    members: ("<Jury Member 1>", "<Jury Member 2>", "<Jury Member 3>"),
  ),
  /// The abstract of the thesis, both an English and a French version are
  /// required. -> dictionary
  abstract: (
    en: [],
    fr: [],
  ),
  /// The acknowledgments of the thesis -> content | none
  acknowledgements: none,
  /// Call to the bibliography function
  bib-func: none,
  /// Wether to include the list of tables. -> bool
  list-of-tables: false,
  /// Wether to include the list of figures. -> bool
  list-of-figures: false,
  /// Wether to include the list of code listings. -> bool
  list-of-listings: false,
  /// A glossary can be included in the document if needed. -> yaml | none
  glossary-entries: none,
  body,
) = {
  set document(title: title, author: name)

  set text(font: "New Computer Modern", lang: "en", size: 11pt)

  set page(paper: "a4", margin: 3.5cm)

  show figure.caption: emph
  // Floating figures appear as `place` instead of `block` so we
  // need this workaround, see https://github.com/typst/typst/issues/6095
  show figure: it => {
    if it.placement == none {
      block(it, inset: (y: .75em))
    } else {
      place(
        it.placement,
        float: true,
        block(it, inset: (y: .75em)),
      )
    }
  }

  set par(justify: true, first-line-indent: 1.8em)

  // TODO: disable link boxes when printing, possibly automatically
  // very hacky but it works
  show link: it => {
    if type(it.dest) != str {
      if it.body.has("text") {
        // glossy links
        it
      } else {
        // bibliography citations
        highlight(stroke: 0.5pt + red, fill: none, it)
      }
    } else { underline(it) } // web links
  }

  // sections, figures and equations
  show ref: it => { highlight(stroke: 0.5pt + green, fill: none, it) }

  show figure.where(kind: table): set figure.caption(position: top)
  show table.cell.where(y: 0): strong
  show table.cell.where(y: 0): smallcaps
  show table: it => {
    set par(justify: false)
    it
  }
  set table(
    stroke: (_, y) => (
      top: if y == 0 { 1pt } else if y == 1 { none } else { 0pt },
      bottom: .5pt,
    ),
    align: center + horizon,
  )

  set math.equation(numbering: "(1)")

  // Used to have numbering appear only on pages with actual content, kudos to
  // https://github.com/typst/typst/discussions/3122#discussioncomment-13936086
  let headings-on-odd-page(it) = {
    show heading.where(level: 1): it => {
      set par(justify: false)
      {
        set page(header: none, numbering: none)
        pagebreak(to: "odd")
      }
      it
    }
    it
  }
  set heading(numbering: "1.1")
  show heading: smallcaps
  show heading: set block(above: 1.4em, below: 1em)

  cover(
    specialization: specialization,
    title: title,
    defense-date: defense-date,
    name: name,
    lab: lab,
    supervisor: supervisor,
    jury: jury,
  )

  align(center)[
    #smallcaps(text(title, size: 1.5em, weight: "bold"))

    #smallcaps(text(name, size: 1.2em, weight: "bold"))
  ]

  v(1fr)

  heading(level: 2, numbering: none, outlined: false, "Abstract")
  abstract.en

  heading(level: 2, numbering: none, outlined: false, text(
    "Resumé",
    lang: "fr",
  ))
  abstract.fr

  v(4fr)

  pagebreak(weak: true, to: "odd")

  if acknowledgements != none {
    heading(level: 2, numbering: none, outlined: false, "Acknowledgments")
    acknowledgements
  }

  pagebreak(weak: true, to: "odd")

  set outline.entry(fill: repeat[ #sym.space #sym.dot.c ])
  show outline.entry.where(level: 1): it => {
    if it.element.func() != heading {
      return it
    }

    v(2em, weak: true)
    link(it.element.location(), strong(it.indented(it.prefix(), {
      (it.body() + h(1fr) + it.page())
    })))
  }
  outline(title: "Table of Contents")

  if list-of-tables {
    pagebreak(weak: true, to: "odd")
    outline(target: figure.where(kind: table), title: "List of Tables")
  }

  if list-of-figures {
    pagebreak(weak: true, to: "odd")
    outline(target: figure.where(kind: image), title: "List of Figures")
  }

  if list-of-listings {
    pagebreak(weak: true, to: "odd")
    outline(target: figure.where(kind: raw), title: "List of Listings")
  }

  show raw: set text(font: "Fira Code")
  show raw.where(block: true): set text(0.8em)
  show: codly-init.with()
  codly(
    languages: codly-languages,
    aliases: ("cuda": "c++"),
    zebra-fill: none,
    number-format: it => text(fill: luma(200), str(it)),
  )

  show: style-algorithm.with(hlines: (
    grid.hline(stroke: 1pt + black),
    grid.hline(stroke: .5pt + black),
    grid.hline(stroke: 1pt + black),
  ))

  show bibliography: it => {
    show text: it => {
      // we must not attempt to evaluate text that is not valid markup
      // thankfully most text _is_, but unbalanced closing brackets don't work
      if it.text == "]" { return it }

      // evaluate any formatting
      let result = eval(it.text, mode: "markup")
      // if nothing was formatted, return the original content
      // to avoid infinite recursion
      if result.func() == text { return it }

      // emit the formatted content
      result
    }
    it
  }

  show: alexandria(prefix: "x-")

  bib-func

  set page(numbering: "1")
  show: headings-on-odd-page

  counter(page).update(0)

  show: init-glossary.with(glossary-entries, term-links: true)

  body

  set page(numbering: none)

  heading(level: 1, "Bibliography")

  set heading(numbering: none, offset: 1)

  context {
    let (references, ..rest) = get-bibliography("x-")
    let tags = ("web", "blog", "repository")
    let is-internet-source(x) = {
      return (
        x.details.type in tags
          or if "parent" in x.details.keys() {
            x.details.parent.type in tags
          } else { false }
      )
    }

    [= Scientific Literature]

    {
      set text(0.8em)
      render-bibliography(title: none, (
        references: references.filter(x => not is-internet-source(x)),
        ..rest,
      ))
    }

    [= Internet Sources]

    {
      set text(0.8em)
      render-bibliography(title: none, (
        references: references.filter(x => is-internet-source(x)),
        ..rest,
      ))
    }
  }

  if (glossary != none) {
    glossary(title: "Glossary", theme: theme-basic)
  }
}
