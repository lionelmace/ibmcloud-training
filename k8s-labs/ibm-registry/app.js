const express = require('express')
const app = express()
var name = process.env.user || "someone"
app.get('/', (req, res) => res.send('Hello World from ' + name + '!'))
app.listen(3000, () => console.log('Server ready'))
