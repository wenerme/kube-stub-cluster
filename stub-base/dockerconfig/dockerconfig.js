let auths = JSON.parse(require('fs').readFileSync(process.env.AUTH_JSON).toString())
// flat server
auths = auths.flatMap(({server: s, ...v}) => (Array.isArray(s) ? s : [s]).map(server => Object.assign({}, v, {server})))

auths = auths.map(({server, username, password}) => {
  return [server, {
    "username": username,
    "password": password,
    "auth": btoa(`${username}:${password}`)
  }]
})

auths = Object.fromEntries(auths)

console.log(JSON.stringify({auths}, null, 2))

function btoa(str) {
  return Buffer.from(str).toString('base64');
}
