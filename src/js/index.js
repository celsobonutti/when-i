const app = Elm.Main.init({
  node: document.querySelector('main'),
  flags: JSON.parse(localStorage.getItem('annotations')) || [],
});

app.ports.saveAnnotations.subscribe((annotations) => {
  localStorage.setItem('annotations', JSON.stringify(annotations));
});
