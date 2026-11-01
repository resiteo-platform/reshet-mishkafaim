import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({plugins:[react()],server:{host:'0.0.0.0',port:Number(process.env.PORT||5173),allowedHosts:['terminal.local'],proxy:{'/api':'http://127.0.0.1:3001'}},build:{outDir:'dist'}});
