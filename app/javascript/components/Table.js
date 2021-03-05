export function Table(table) {
  const link = table.querySelectorAll(".table-cell-link")
  if (link) {
    const linkAdjacent = table.querySelectorAll(".table-cell-link ~ td:not(.table-cell-actions")
    linkAdjacent.forEach(cell => {
      cell.addEventListener("click", event => {
        console.log("farts")
        link.dispatchEvent(event)
      })
    })
  }
}
