/// Generates the cover page for the thesis.
/// -> content
#let cover(
  /// The specialization -> str
  specialization: "",
  /// The thesis' title. -> str
  title: "",
  /// The date of the thesis defense. -> datetime
  defense-date: datetime.today(),
  /// The candidate's name. -> str
  name: "",
  /// The lab in which you perfomed the research project. -> str
  lab: "",
  /// The supervisor (or multiple supervisors) of the thesis. -> str | list(str)
  supervisor: "",
  /// The list of members of the jury. -> dictionary
  jury: (
    president: "",
    members: (""),
  ),
) = {
  set align(center + horizon)

  grid(
    columns: 3,
    image("assets/uga-logo.svg", height: 10%),
    h(1fr),
    image("assets/inp-logo.svg", height: 10%),
  )

  v(0.2fr)
  
  [
    Master of Science in Informatics at Grenoble\
    #text([Master Informatique, Université Grenoble Alpes], lang: "fr")\
    Specialization #specialization
  ]

  v(1fr)

  smallcaps(text(title, size: 2em, weight: "bold"))

  v(0.2fr)

  smallcaps(text(name, size: 1.2em, weight: "bold"))

  v(0.5fr)

  defense-date.display("[month repr:long] [day], [year]")

  v(0.5fr)

  [
    Master research project performed at

    #lab
  ]

  v(0.2fr)

  [
   Under the supervision of

   #supervisor
  ]

  v(1fr)

  [
    Defended before a jury composed of

    #jury.president, President

    #for member in jury.members [
      #member\
    ]
  ]

  pagebreak(to: "odd", weak: true)
}
