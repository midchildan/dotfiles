$latex = 'platex --kanji=utf8';
$bibtex = 'pbibtex';
$biber = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf ='dvipdfmx %O -o %D %S';
$makeindex = 'mendex %O -o %D %S';
$max_repeat = 5;
$pdf_mode = 3;

if ($^O eq 'darwin') {
  $pdf_previewer = 'open';
} elseif ($^O eq 'linux') {
  $pdf_previewer = 'xdg-open';
}
