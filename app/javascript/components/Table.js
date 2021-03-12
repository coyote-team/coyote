export function Table(table) {
  table.querySelectorAll(".table-cell-link > a").forEach(link => {
    const row = link.parentNode.parentNode
    row.querySelectorAll(".table-cell-link ~ td:not(.table-cell-actions").forEach(cell => {
      cell.addEventListener("click", event => {
        setTimeout(() => {
          link.dispatchEvent(event)
        }, 0)
      })
    })
  })
}
