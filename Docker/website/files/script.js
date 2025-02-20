const slider = document.querySelector('.slider');

function activate(e) {
  const items = document.querySelectorAll('.item');

  if (e.target.matches('.right') || e.key === "ArrowRight") {
    // Move to the next slide
    slider.append(items[0]);
  } else if (e.target.matches('.left') || e.key === "ArrowLeft") {
    // Move to the previous slide
    slider.prepend(items[items.length - 1]);
  }
}

// Listen for clicks on the arrow buttons
document.querySelectorAll('.arrow-key').forEach(button => {
  button.addEventListener('click', activate);
});

// Listen for arrow key presses for slider navigation
window.addEventListener('keydown', activate);

// Handle arrow key visual effects
window.addEventListener('keydown', arrowDown);
window.addEventListener('keyup', arrowUp);

function arrowDown(e) {
  const key = document.querySelector(`.arrow-key[data-key="${e.keyCode}"]`);
  if (key) key.classList.add('press');
}

function arrowUp(e) {
  const key = document.querySelector(`.arrow-key[data-key="${e.keyCode}"]`);
  if (key) key.classList.remove('press');
}
