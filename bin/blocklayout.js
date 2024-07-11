#! /usr/bin/env node

import { convert } from "../dist/convert.js";
import { argv, exit, stdout, stderr } from 'node:process';
import fs from "node:fs";

if (argv.length < 3) {
  stderr.write("usage: blocklayout input_file\n");
  exit(1);
}

const data = fs.readFileSync(argv[2]).toString('utf-8');
var replaced = convert(data);
stdout.write(replaced.result);
exit(0);



