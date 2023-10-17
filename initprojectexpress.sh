#!/bin/bash

clear
echo Removendo pastas...
rm -rf ./node_modules
rm -rf ./src
rm -rf ./dist
rm -f ./package.json
rm -f ./package-lock.json
rm -f ./tsconfig.json
echo

echo Iniciando o node...
npm init -y
echo

echo instalando o typescript...
npm install -D typescript @types/node
npx tsc --init
echo

echo instalando o express...
npm install express
npm install -D @types/express
echo

echo instalando cors
npm install cors
npm install -D @types/cors

nodemon -v
if [ ! $? -eq 0 ]; then
    echo instalando o nodemon...
    npm install -D nodemon
    echo
fi

ts-node -v
if [ ! $? -eq 0 ]; then
    echo instalando o ts-node...
    npm install -g ts-node
    echo
fi

echo criando os diretórios
mkdir src
cd src

echo 'import { Request, Response, NextFunction } from "express";
import { App } from "./app";
import { RequestError } from "./interfaces/RequestError";
import { PORT } from "./config";
import { Logs } from "./utils/Logs";
import { HTTPError } from "./error/HTTPError";

App.get("/", (req,res) => {
    res.send("Hello world!!!");
})

App.get("/error", (req,res) => {
    throw new Error("internal test error");
})

App.use((err:RequestError, req:Request, res:Response, next:NextFunction) => {
    if (err instanceof HTTPError) {
        const code = err.status || 500;
        res.status(code).send(`<b>${code}</b> - ` + err.message);
        return;
    }
    Logs.log(err.stack);
    res.status(err.status || 500).send("Erro interno do servidor.");
})

App.use((req:Request, res:Response, next:NextFunction) => {
    res.status(404).send("<h1>404 - page not found</h1>");
})

App.listen(PORT, () => console.log(`RUN IN http://localhost:${PORT}`));
'>index.ts

echo 'export const PORT = 5005;
'>config.ts

mkdir app
cd app
echo 'import express from "express";
import cors from "cors";

export const App = express();

App.use(
    cors({
        origin: true,
        methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
        credentials: true,
    })
);

App.use(express.json({
    inflate:false,
    limit: "1mb",
}));
'>index.ts

cd ..

mkdir error
cd error
echo 'import { RequestError } from "../interfaces/RequestError";

export class HTTPError extends Error implements RequestError {
    constructor(
        msg:string,
        private readonly _status:number = 500
    ){
        super(msg)
    }

    get status():number {
        return this._status
    }
}
'>HTTPError.ts

cd ..

mkdir interfaces
cd interfaces

echo '
export interface RequestError extends Error {
    status?: number
}
'>RequestError.ts

cd ..

mkdir utils
cd utils

echo '
export class Logs {
    static log(msg:any){
        console.log(msg);
    }

    static error(msg:any) {
        console.error(msg);
    }
}
'>Logs.ts

cd ..

cd ..
echo

echo definindo arquivos de configuração...
echo '{
  "compilerOptions": {
    "esModuleInterop": true,
    "target": "ESNext",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true
  },
  "include": [
    "src/**/*.ts"
  ],
  "exclude": [
    "node_modules"
  ]
}'>./tsconfig.json
replacetext="\"scripts\": \{
    \"build\": \"tsc\",
    \"rebuild\": \"rm -fr .\/dist \&\& tsc\",
    \"start\": \"node .\/dist\/index.js\",
    \"dev\": \"nodemon --watch '.\/src\/\*\*\/\*.ts' --exec 'ts-node' '.\/src\/index.ts'\"
  \}"

perl -0777 -pi -e "s/\"scripts\": \{[^}]*\}/$replacetext/g" ./package.json

echo
echo execute:
echo "npm run dev"

rm -fr ./.git

echo 'node_modules
package-lock.json
dist'>.gitignore

git init
