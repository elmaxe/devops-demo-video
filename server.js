const express = require('express')
const app = express()
const cors = require('cors')
const morgan = require('morgan')
const path = require('path')
const bodyParser = require('body-parser')

app.use(cors());
app.use(bodyParser.json())
app.use(morgan("common"))

app.use('/', express.static('build'))
app.get('*', (req, res) => res.sendFile(path.resolve(__dirname + "./build/index.html")))
const PORT = 3000
app.listen(PORT, () => console.log(`Listening on port ${PORT}!`))