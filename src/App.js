import './App.css';
import { useState } from 'react';

function App() {

  const [audio, playAudio] = useState(false)

  const play = _ => {
      const a = new Audio('./music.mp3')
      if (!audio) {
        a.play()
        playAudio(a)
      }

  }

  return (
    <div className="App">
      <header className="App-header">
        <button onClick={play}>Click me</button>
        {audio &&
          <img src="https://i.pinimg.com/originals/88/82/bc/8882bcf327896ab79fb97e85ae63a002.gif" alt="You got rickrolled" style={{width: "90%", height: "90%"}} />
        }
      </header>
    </div>
  );
}

export default App;
