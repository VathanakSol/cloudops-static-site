document.addEventListener("DOMContentLoaded", () => {
  const filterButtons = document.querySelectorAll(".filter-btn");
  const projectCards = document.querySelectorAll(".project-item");

  if (!filterButtons.length || !projectCards.length) {
    return;
  }

  filterButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const selectedType = button.dataset.filter;

      filterButtons.forEach((item) => item.classList.remove("active"));
      button.classList.add("active");

      projectCards.forEach((card) => {
        const type = card.dataset.type;
        const shouldShow = selectedType === "all" || selectedType === type;
        card.style.display = shouldShow ? "block" : "none";
      });
    });
  });
});