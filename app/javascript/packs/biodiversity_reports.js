import Elm from '../biodiversity_reports/Main'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('temperature_slider_input')
  const app = Elm.Main.embed(target)
})
