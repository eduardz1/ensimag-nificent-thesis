#import "@preview/alexandria:0.2.0": load-bibliography
#import "@local/ensimag-nificent-thesis:0.1.0": template
#import "abstract.typ": abstract-en, abstract-fr
#import "acknowledgements.typ": acknowledgements

#show: template.with(
  specialization: "<Your Specialization>",
  title: "<Project Title>",
  defense-date: datetime(year: 2025, month: 9, day: 1),
  name: "<Your Name>",
  lab: "<Your Lab>",
  supervisor: "<Your Supervisor(s)>",
  jury: (
    president: "<President of the Jury>",
    members: ("<Jury Member 1>", "<Jury Member 2>", "<Jury Member 3>"),
  ),
  abstract: (en: abstract-en, fr: abstract-fr),
  acknowledgements: acknowledgements,
  bibliography: load-bibliography(read("works.bib", encoding: none)),
  list-of-figures: true,
  list-of-tables: true,
  list-of-listings: true,
)

#include "chapters/introduction.typ"

#include "chapters/sota.typ"

#include "chapters/theory.typ"

#include "chapters/implementation.typ"

#include "chapters/evaluation.typ"

#include "chapters/results.typ"

#include "chapters/conclusion.typ"