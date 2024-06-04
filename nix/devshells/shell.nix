{ mkShellNoCC, formatters }:

mkShellNoCC { nativeBuildInputs = formatters; }
