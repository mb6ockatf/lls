#!/usr/bin/node
var args = process.argv.slice(2);
var file_path = args[0]
var pattern = args[1]
console.log(pattern)
if (typeof file_path === 'undefined' && file_path !== null || typeof pattern === 'undefined' && pattern !== null){
   console.log("Usage: ./main.js <filename> <string>");
   process.exit(1);
}
const fs = require('fs');
const readline = require('readline');
const file = readline.createInterface({
    input: fs.createReadStream(file_path),
    output: process.stdout,
    terminal: false
});

file.on('line', (line) => {
    if (line.includes(pattern)){
        console.log(line);
    }
});
