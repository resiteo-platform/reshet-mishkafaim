import {spawn} from 'node:child_process';
const api=spawn(process.execPath,['server/index.mjs'],{stdio:'inherit',env:{...process.env,API_PORT:'3001',PUBLIC_ORIGIN:process.env.PUBLIC_ORIGIN||'http://terminal.local:'+ (process.argv.includes('--port')?process.argv[process.argv.indexOf('--port')+1]:'5173')}});
const vite=spawn(process.execPath,['node_modules/vite/bin/vite.js',...process.argv.slice(2)],{stdio:'inherit',env:process.env});
function stop(){api.kill();vite.kill()};process.on('SIGTERM',stop);process.on('SIGINT',stop);vite.on('exit',code=>{api.kill();process.exit(code||0)});
