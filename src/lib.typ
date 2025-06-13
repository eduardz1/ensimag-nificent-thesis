#import "@preview/tidy:0.4.3"
#import "@preview/alexandria:0.2.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/glossy:0.8.0": *
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
  bibliography: none,
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

  set text(font: "New Computer Modern", lang: "en", size: 12pt)

  set page(paper: "a4", margin: 3.5cm)

  show figure.caption: emph
  show figure.caption: set text(size: 0.8em)
  show figure: set block(above: 2em, below: 2em)

  set par(justify: true, first-line-indent: 1.8em)

  set heading(numbering: "1.1")
  show heading.where(level: 1, outlined: true): it => {
    state("content.switch").update(false)
    pagebreak(to: "odd", weak: true)
    state("content.switch").update(true)
    it
  }
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

  heading(
    level: 2,
    numbering: none,
    outlined: false,
    text("Resumé", lang: "fr"),
  )
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
    v(1.2em, weak: true)
    strong(it)
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
    zebra-fill: none,
    number-format: it => text(fill: luma(200), str(it)),
  )

  show: alexandria(prefix: "x-")

  bibliography

  // Show page number only on non-empty pages
  // TODO: need to fix this
  // set page(
  //   header: context {
  //     let page = here().page()
  //     let is-start-chapter = query(heading.where(level: 1))
  //       .map(it => it.location().page())
  //       .contains(page)
  //     if not state("content.switch", false).get() and not is-start-chapter {
  //       return
  //     }
  //     state("content.pages", (0,)).update(it => {
  //       it.push(page)
  //       return it
  //     })
  //   },
  //   footer: context {
  //     let has-content = state("content.pages", (0,))
  //       .get()
  //       .contains(here().page())
  //     if has-content {
  //       align(center, counter(page).display())
  //     }
  //   },
  // )

  counter(page).update(0)

  show: init-glossary.with(glossary-entries, term-links: true)

  body

  heading(level: 1, "Bibliography")

  set heading(numbering: none, offset: 1)

  context {
    let (references, ..rest) = get-bibliography("x-")
    let is-internet-source(x) = {
      return (
        x.details.type in ("web", "blog")
          or if "parent" in x.details.keys() {
            x.details.parent.type in ("web", "blog")
          } else { false }
      )
    }

    render-bibliography(
      title: [Scientific Literature],
      (
        references: references.filter(x => not is-internet-source(x)),
        ..rest,
      ),
    )

    render-bibliography(
      title: [Internet Sources],
      (
        references: references.filter(x => is-internet-source(x)),
        ..rest,
      ),
    )
  }

  if (glossary != none) {
    glossary(title: "Glossary", theme: theme-chicago-index)
  }
}
