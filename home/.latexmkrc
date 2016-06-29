$latex = 'uplatex --kanji=utf8';
$biber = 'biber -u -U --output_safechars';
$bibtex = 'upbibtex';
$dvipdf ='dvipdfmx %O -o %D %S';
$makeindex = 'upmendex %O -o %D %S';
$max_repeat = 5;
$pdf_mode = 3;

if ($^O eq 'darwin') {
  $pdf_previewer = 'open';
} elsif ($^O eq 'linux') {
  $pdf_previewer = 'xdg-open';
}
